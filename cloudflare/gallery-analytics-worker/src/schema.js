export const SCHEMA_VERSION = 1;

function requireObject(value, label) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new TypeError(`${label} must be an object`);
  }
  return value;
}

function requireArray(value, label) {
  if (!Array.isArray(value)) {
    throw new TypeError(`${label} must be an array`);
  }
  return value;
}

function finiteCount(value, label) {
  if (typeof value !== "number" || !Number.isFinite(value) || value < 0) {
    throw new TypeError(`${label} must be a non-negative finite number`);
  }
  return Math.round(value);
}

function boundedInteger(value, fallback, minimum, maximum) {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isInteger(parsed) || parsed < minimum || parsed > maximum) {
    return fallback;
  }
  return parsed;
}

function cleanText(value, label, maximumLength) {
  if (typeof value !== "string") {
    throw new TypeError(`${label} must be a string`);
  }
  const cleaned = value.trim();
  if (!cleaned || cleaned.length > maximumLength || /[\u0000-\u001f\u007f]/u.test(cleaned)) {
    throw new TypeError(`${label} is invalid`);
  }
  return cleaned;
}

function cleanPath(value, prefix) {
  const path = cleanText(value, "page path", 300);
  if (!path.startsWith(prefix) || path.includes("?") || path.includes("#")) {
    throw new TypeError("page path is outside the Gallery scope");
  }
  return path;
}

function cleanHost(value) {
  if (value === "") {
    return "Direct or unavailable";
  }
  const host = cleanText(value, "referrer host", 255).toLowerCase().replace(/\.$/u, "");
  if (!/^[a-z0-9.-]+$/u.test(host)) {
    throw new TypeError("referrer host is invalid");
  }
  return host;
}

function groupMetric(group, metric, label) {
  const current = requireObject(group, label);
  if (metric === "pageViews") {
    return finiteCount(current.count, `${label}.count`);
  }
  const sum = requireObject(current.sum, `${label}.sum`);
  return finiteCount(sum.visits, `${label}.sum.visits`);
}

function groupSampleInterval(group, label) {
  const current = requireObject(group, label);
  const avg = requireObject(current.avg, `${label}.avg`);
  const interval = avg.sampleInterval;
  if (typeof interval !== "number" || !Number.isFinite(interval) || interval < 1) {
    throw new TypeError(`${label}.avg.sampleInterval must be at least one`);
  }
  return interval;
}

function totalFrom(groups, label) {
  const rows = requireArray(groups, label);
  if (rows.length === 0) {
    return {
      pageViews: 0,
      visits: 0,
      sampleInterval: 1
    };
  }
  if (rows.length > 1) {
    throw new TypeError(`${label} must contain at most one aggregate row`);
  }
  const row = rows[0];
  return {
    pageViews: groupMetric(row, "pageViews", `${label}[0]`),
    visits: groupMetric(row, "visits", `${label}[0]`),
    sampleInterval: groupSampleInterval(row, `${label}[0]`)
  };
}

function topRows(groups, options) {
  const rows = requireArray(groups, options.label);
  const collected = [];
  let maximumSampleInterval = 1;

  rows.forEach((group, index) => {
    const label = `${options.label}[${index}]`;
    const current = requireObject(group, label);
    const dimensions = requireObject(current.dimensions, `${label}.dimensions`);
    const count = groupMetric(current, options.metric, label);
    maximumSampleInterval = Math.max(maximumSampleInterval, groupSampleInterval(current, label));

    if (count < options.minimumCount) {
      return;
    }

    try {
      const value = options.clean(dimensions[options.dimension]);
      collected.push({ value, count });
    } catch {
      // Invalid or out-of-scope dimensions are omitted from the public result.
    }
  });

  collected.sort((left, right) => right.count - left.count || left.value.localeCompare(right.value));

  return {
    rows: collected.slice(0, options.limit),
    sampleInterval: maximumSampleInterval
  };
}

export function buildSummary(payload, configuration, generatedAt = new Date()) {
  const root = requireObject(payload, "GraphQL response");
  const data = requireObject(root.data, "GraphQL response.data");
  const viewer = requireObject(data.viewer, "GraphQL response.data.viewer");
  const accounts = requireArray(viewer.accounts, "GraphQL response.data.viewer.accounts");
  if (accounts.length !== 1) {
    throw new TypeError("GraphQL response must contain exactly one account");
  }

  const account = requireObject(accounts[0], "GraphQL account");
  const minimumCount = boundedInteger(configuration.minimumCount, 5, 2, 1000);
  const limit = boundedInteger(configuration.limit, 10, 1, 25);
  const pathPrefix = cleanText(configuration.pathPrefix, "Gallery path prefix", 100);
  const last7Days = totalFrom(account.totals7, "totals7");
  const last30Days = totalFrom(account.totals30, "totals30");

  const pages = topRows(account.pages30, {
    label: "pages30",
    metric: "pageViews",
    dimension: "requestPath",
    minimumCount,
    limit,
    clean: (value) => cleanPath(value, pathPrefix)
  });
  const countries = topRows(account.countries30, {
    label: "countries30",
    metric: "visits",
    dimension: "countryName",
    minimumCount,
    limit,
    clean: (value) => cleanText(value, "country", 100)
  });
  const referrers = topRows(account.referrers30, {
    label: "referrers30",
    metric: "visits",
    dimension: "refererHost",
    minimumCount,
    limit,
    clean: cleanHost
  });

  const sampleInterval = Math.max(
    last7Days.sampleInterval,
    last30Days.sampleInterval,
    pages.sampleInterval,
    countries.sampleInterval,
    referrers.sampleInterval
  );

  const summary = {
    schemaVersion: SCHEMA_VERSION,
    generatedAt: generatedAt.toISOString(),
    status: "current",
    totals: {
      last7Days: {
        visits: last7Days.visits,
        pageViews: last7Days.pageViews
      },
      last30Days: {
        visits: last30Days.visits,
        pageViews: last30Days.pageViews
      }
    },
    topPages: pages.rows.map(({ value, count }) => ({ path: value, pageViews: count })),
    topCountries: countries.rows.map(({ value, count }) => ({ country: value, visits: count })),
    topReferrers: referrers.rows.map(({ value, count }) => ({ host: value, visits: count })),
    sampling: {
      applied: sampleInterval > 1,
      sampleInterval
    }
  };

  return validateSummary(summary);
}

function validateMetricPair(value, label) {
  const pair = requireObject(value, label);
  finiteCount(pair.visits, `${label}.visits`);
  finiteCount(pair.pageViews, `${label}.pageViews`);
}

function validateRows(value, label, key, metric) {
  const rows = requireArray(value, label);
  rows.forEach((row, index) => {
    const current = requireObject(row, `${label}[${index}]`);
    cleanText(current[key], `${label}[${index}].${key}`, 300);
    finiteCount(current[metric], `${label}[${index}].${metric}`);
  });
}

export function validateSummary(value) {
  const summary = requireObject(value, "summary");
  if (summary.schemaVersion !== SCHEMA_VERSION) {
    throw new TypeError("summary schema version is unsupported");
  }
  if (!Number.isFinite(Date.parse(summary.generatedAt))) {
    throw new TypeError("summary generatedAt must be an ISO timestamp");
  }
  if (summary.status !== "current" && summary.status !== "stale") {
    throw new TypeError("summary status is unsupported");
  }
  const totals = requireObject(summary.totals, "summary.totals");
  validateMetricPair(totals.last7Days, "summary.totals.last7Days");
  validateMetricPair(totals.last30Days, "summary.totals.last30Days");
  validateRows(summary.topPages, "summary.topPages", "path", "pageViews");
  validateRows(summary.topCountries, "summary.topCountries", "country", "visits");
  validateRows(summary.topReferrers, "summary.topReferrers", "host", "visits");
  const sampling = requireObject(summary.sampling, "summary.sampling");
  if (typeof sampling.applied !== "boolean") {
    throw new TypeError("summary.sampling.applied must be boolean");
  }
  if (typeof sampling.sampleInterval !== "number" || !Number.isFinite(sampling.sampleInterval) || sampling.sampleInterval < 1) {
    throw new TypeError("summary.sampling.sampleInterval must be at least one");
  }
  return summary;
}
