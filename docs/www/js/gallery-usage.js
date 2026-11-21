const numberFormatter = new Intl.NumberFormat(undefined, { maximumFractionDigits: 0 });
const dateFormatter = new Intl.DateTimeFormat(undefined, {
  dateStyle: "medium",
  timeStyle: "short"
});

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

document.querySelectorAll("[data-gallery-usage]").forEach((root) => {
  renderUsage(root);
});
