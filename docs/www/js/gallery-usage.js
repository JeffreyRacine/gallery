const numberFormatter = new Intl.NumberFormat(undefined, { maximumFractionDigits: 0 });
const dateFormatter = new Intl.DateTimeFormat(undefined, {
  dateStyle: "medium",
  timeStyle: "short"
});
const dateOnlyFormatter = new Intl.DateTimeFormat(undefined, {
  dateStyle: "medium",
  timeZone: "UTC"
});
const trackedPackages = ["np", "npRmpi", "crs"];

function requireObject(value, label) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new TypeError(`${label} is invalid`);
  }
  return value;
}

function requireCount(value, label) {
  if (typeof value !== "number" || !Number.isFinite(value) || value < 0) {
    throw new TypeError(`${label} is invalid`);
  }
  return value;
}

function validateSummary(value) {
  const summary = requireObject(value, "summary");
  if (summary.schemaVersion !== 1 || !Number.isFinite(Date.parse(summary.generatedAt))) {
    throw new TypeError("summary metadata is invalid");
  }
  if (summary.status !== "current" && summary.status !== "stale") {
    throw new TypeError("summary status is invalid");
  }
  const totals = requireObject(summary.totals, "summary totals");
  ["last7Days", "last30Days"].forEach((period) => {
    const values = requireObject(totals[period], period);
    requireCount(values.visits, `${period} visits`);
    requireCount(values.pageViews, `${period} page views`);
  });
  [summary.topPages, summary.topCountries, summary.topReferrers].forEach((rows) => {
    if (!Array.isArray(rows)) {
      throw new TypeError("summary table is invalid");
    }
  });
  const sampling = requireObject(summary.sampling, "summary sampling");
  if (typeof sampling.applied !== "boolean"
      || typeof sampling.sampleInterval !== "number"
      || !Number.isFinite(sampling.sampleInterval)
      || sampling.sampleInterval < 1) {
    throw new TypeError("summary sampling is invalid");
  }
  return summary;
}

function requireInteger(value, label) {
  const count = requireCount(value, label);
  if (!Number.isSafeInteger(count)) {
    throw new TypeError(`${label} is invalid`);
  }
  return count;
}

function requireDate(value, label) {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/u.test(value)) {
    throw new TypeError(`${label} is invalid`);
  }
  const parsed = new Date(`${value}T00:00:00Z`);
  if (!Number.isFinite(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== value) {
    throw new TypeError(`${label} is invalid`);
  }
  return value;
}

function validatePackageReach(value) {
  const summary = requireObject(value, "package reach summary");
  if (summary.schemaVersion !== 1 || !Number.isFinite(Date.parse(summary.generatedAt))) {
    throw new TypeError("package reach metadata is invalid");
  }
  if (summary.status !== "current" && summary.status !== "stale") {
    throw new TypeError("package reach status is invalid");
  }
  requireDate(summary.sourceThrough, "source-through date");
  requireDate(summary.rankDate, "rank date");
  if (summary.sourceThrough !== summary.rankDate || !Array.isArray(summary.packages)) {
    throw new TypeError("package reach dates or rows are invalid");
  }
  if (summary.packages.length !== trackedPackages.length) {
    throw new TypeError("package reach rows are incomplete");
  }
  summary.packages.forEach((item, index) => {
    const row = requireObject(item, `package row ${index}`);
    if (row.package !== trackedPackages[index]) {
      throw new TypeError("package reach rows are unsupported or out of order");
    }
    ["downloads30", "downloads365", "downloadsOnRankDate", "dailyRank", "dailyRankTotal"]
      .forEach((field) => requireInteger(row[field], `${row.package} ${field}`));
    if (row.dailyRank < 1 || row.dailyRank > row.dailyRankTotal
        || typeof row.dailyPercentile !== "number"
        || !Number.isFinite(row.dailyPercentile)
        || row.dailyPercentile < 0
        || row.dailyPercentile > 100) {
      throw new TypeError(`${row.package} daily position is invalid`);
    }
    const reverse = requireObject(row.reverseDependencies, `${row.package} reverse dependencies`);
    requireInteger(reverse.required, `${row.package} required reverse dependencies`);
    requireInteger(reverse.all, `${row.package} all reverse dependencies`);
    if (reverse.required > reverse.all) {
      throw new TypeError(`${row.package} reverse dependencies are invalid`);
    }
  });
  return summary;
}

function setMetric(root, name, value) {
  const element = root.querySelector(`[data-metric="${name}"]`);
  if (element) {
    element.textContent = numberFormatter.format(value);
  }
}

function emptyRow(message) {
  const row = document.createElement("tr");
  const cell = document.createElement("td");
  cell.colSpan = 2;
  cell.className = "gallery-usage__empty";
  cell.textContent = message;
  row.append(cell);
  return row;
}

function fillTable(root, selector, rows, labelKey, metricKey, paths = false) {
  const body = root.querySelector(selector);
  if (!body) {
    return;
  }
  body.replaceChildren();
  if (rows.length === 0) {
    body.append(emptyRow("No rows meet the public reporting threshold."));
    return;
  }

  rows.forEach((item) => {
    const row = document.createElement("tr");
    const labelCell = document.createElement("td");
    const countCell = document.createElement("td");
    const label = item[labelKey];
    if (typeof label !== "string" || !label.trim()) {
      throw new TypeError("summary label is invalid");
    }
    if (paths && !label.startsWith("/gallery/")) {
      throw new TypeError("summary path is outside the Gallery");
    }
    const count = requireCount(item[metricKey], `${label} count`);

    if (paths) {
      const link = document.createElement("a");
      link.href = label;
      link.textContent = label.replace(/^\/gallery\//u, "");
      labelCell.append(link);
    } else {
      labelCell.textContent = label;
    }
    countCell.textContent = numberFormatter.format(count);
    countCell.className = "gallery-usage__number";
    row.append(labelCell, countCell);
    body.append(row);
  });
}

async function renderUsage(root) {
  const status = root.querySelector("[data-usage-status]");
  const content = root.querySelector("[data-usage-content]");
  if (!status) {
    return;
  }

  try {
    const endpoint = root.dataset.endpoint;
    if (!endpoint || !content) {
      throw new TypeError("Gallery usage component is not configured");
    }
    const response = await fetch(endpoint, {
      headers: { Accept: "application/json" },
      cache: "no-cache"
    });
    if (!response.ok) {
      throw new Error(`usage endpoint returned ${response.status}`);
    }
    const summary = validateSummary(await response.json());

    setMetric(root, "visits-7", summary.totals.last7Days.visits);
    setMetric(root, "pageviews-7", summary.totals.last7Days.pageViews);
    setMetric(root, "visits-30", summary.totals.last30Days.visits);
    setMetric(root, "pageviews-30", summary.totals.last30Days.pageViews);
    fillTable(root, "[data-table='pages']", summary.topPages, "path", "pageViews", true);
    fillTable(root, "[data-table='countries']", summary.topCountries, "country", "visits");
    fillTable(root, "[data-table='referrers']", summary.topReferrers, "host", "visits");

    const refreshed = dateFormatter.format(new Date(summary.generatedAt));
    status.textContent = summary.status === "stale"
      ? `Last successful refresh: ${refreshed}. The current refresh is delayed.`
      : `Last refreshed: ${refreshed}.`;
    status.classList.toggle("gallery-usage__status--stale", summary.status === "stale");

    const sampling = root.querySelector("[data-usage-sampling]");
    if (sampling) {
      sampling.hidden = !summary.sampling?.applied;
    }
    content.hidden = false;
  } catch {
    status.textContent = "The usage summary is temporarily unavailable. The rest of the Gallery is unaffected.";
    status.classList.add("gallery-usage__status--unavailable");
  }
}

function appendProfileLink(cell, label, href) {
  const link = document.createElement("a");
  link.href = href;
  link.textContent = label;
  cell.append(link);
}

function fillPackageTable(root, summary) {
  const body = root.querySelector("[data-package-table]");
  if (!body) {
    return;
  }
  body.replaceChildren();
  summary.packages.forEach((item) => {
    const row = document.createElement("tr");
    const packageCell = document.createElement("th");
    packageCell.scope = "row";
    const packageName = document.createElement("strong");
    packageName.className = "gallery-package-reach__package-name";
    packageName.textContent = item.package;
    const profileLinks = document.createElement("div");
    profileLinks.className = "gallery-package-reach__profile-links";
    appendProfileLink(profileLinks, "CRAN", `https://CRAN.R-project.org/package=${item.package}`);
    appendProfileLink(profileLinks, "R Observatory", `https://observe.rstats.dev/cran/${item.package}`);
    appendProfileLink(profileLinks, "R-universe", `https://jeffreyracine.r-universe.dev/${item.package}`);
    packageCell.append(packageName, profileLinks);

    const downloads30 = document.createElement("td");
    downloads30.className = "gallery-usage__number";
    downloads30.textContent = numberFormatter.format(item.downloads30);

    const downloads365 = document.createElement("td");
    downloads365.className = "gallery-usage__number";
    downloads365.textContent = numberFormatter.format(item.downloads365);

    const percentile = document.createElement("td");
    percentile.className = "gallery-usage__number";
    percentile.textContent = `${item.dailyPercentile.toFixed(1)}%`;

    const rank = document.createElement("td");
    rank.className = "gallery-package-reach__rank-value";
    rank.textContent = `${numberFormatter.format(item.dailyRank)} of ${numberFormatter.format(item.dailyRankTotal)}`;

    const required = document.createElement("td");
    required.className = "gallery-usage__number";
    required.textContent = numberFormatter.format(item.reverseDependencies.required);

    const all = document.createElement("td");
    all.className = "gallery-usage__number";
    all.textContent = numberFormatter.format(item.reverseDependencies.all);

    row.append(packageCell, downloads30, downloads365, percentile, rank,
      required, all);
    body.append(row);
  });
}

async function renderPackageReach(root) {
  const status = root.querySelector("[data-package-status]");
  const content = root.querySelector("[data-package-content]");
  if (!status) {
    return;
  }

  try {
    const endpoint = root.dataset.endpoint;
    if (!endpoint || !content) {
      throw new TypeError("Package reach component is not configured");
    }
    const response = await fetch(endpoint, {
      headers: { Accept: "application/json" },
      cache: "no-cache"
    });
    if (!response.ok) {
      throw new Error(`package reach endpoint returned ${response.status}`);
    }
    const summary = validatePackageReach(await response.json());
    fillPackageTable(root, summary);

    const through = dateOnlyFormatter.format(new Date(`${summary.sourceThrough}T00:00:00Z`));
    status.textContent = summary.status === "stale"
      ? `Figures through ${through}. The daily refresh is delayed.`
      : `Figures through ${through}.`;
    status.classList.toggle("gallery-usage__status--stale", summary.status === "stale");
    content.hidden = false;
  } catch {
    status.textContent = "The package summary is temporarily unavailable. The Gallery and package profiles are unaffected.";
    status.classList.add("gallery-usage__status--unavailable");
  }
}

document.querySelectorAll("[data-gallery-usage]").forEach((root) => {
  renderUsage(root);
});

document.querySelectorAll("[data-package-reach]").forEach((root) => {
  renderPackageReach(root);
});
