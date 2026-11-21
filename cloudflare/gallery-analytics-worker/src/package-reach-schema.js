export const PACKAGE_REACH_SCHEMA_VERSION = 1;

const PACKAGES = ["np", "npRmpi", "crs"];

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

function requireDate(value, label) {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/u.test(value)) {
    throw new TypeError(`${label} must be an ISO date`);
  }
  const parsed = new Date(`${value}T00:00:00Z`);
  if (!Number.isFinite(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== value) {
    throw new TypeError(`${label} must be a valid ISO date`);
  }
  return value;
}

function requireInteger(value, label) {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new TypeError(`${label} must be a non-negative integer`);
  }
  return value;
}

function requirePercentile(value, label) {
  if (typeof value !== "number" || !Number.isFinite(value) || value < 0 || value > 100) {
    throw new TypeError(`${label} must be between zero and 100`);
  }
  return value;
}

function dateBefore(date, days) {
  const parsed = new Date(`${date}T00:00:00Z`);
  parsed.setUTCDate(parsed.getUTCDate() - days);
  return parsed.toISOString().slice(0, 10);
}

function validateWindow(value, label, sourceThrough, days) {
  const window = requireObject(value, label);
  const from = requireDate(window.from, `${label}.from`);
  const to = requireDate(window.to, `${label}.to`);
  if (from !== dateBefore(sourceThrough, days - 1) || to !== sourceThrough) {
    throw new TypeError(`${label} must match its fixed rolling window`);
  }
}

function validatePackage(value, index) {
  const label = `packageReach.packages[${index}]`;
  const current = requireObject(value, label);
  if (current.package !== PACKAGES[index]) {
    throw new TypeError(`${label}.package is unsupported or out of order`);
  }
  requireInteger(current.downloads30, `${label}.downloads30`);
  requireInteger(current.downloads365, `${label}.downloads365`);
  requireInteger(current.downloadsOnRankDate, `${label}.downloadsOnRankDate`);
  const rank = requireInteger(current.dailyRank, `${label}.dailyRank`);
  const rankTotal = requireInteger(current.dailyRankTotal, `${label}.dailyRankTotal`);
  if (rank < 1 || rankTotal < rank) {
    throw new TypeError(`${label} daily rank is invalid`);
  }
  requirePercentile(current.dailyPercentile, `${label}.dailyPercentile`);
  const reverseDependencies = requireObject(
    current.reverseDependencies,
    `${label}.reverseDependencies`
  );
  const required = requireInteger(
    reverseDependencies.required,
    `${label}.reverseDependencies.required`
  );
  const all = requireInteger(reverseDependencies.all, `${label}.reverseDependencies.all`);
  if (required > all) {
    throw new TypeError(`${label}.reverseDependencies.required cannot exceed all`);
  }
}

export function validatePackageReach(value) {
  const packageReach = requireObject(value, "packageReach");
  if (packageReach.schemaVersion !== PACKAGE_REACH_SCHEMA_VERSION) {
    throw new TypeError("packageReach schema version is unsupported");
  }
  if (!Number.isFinite(Date.parse(packageReach.generatedAt))) {
    throw new TypeError("packageReach.generatedAt must be an ISO timestamp");
  }
  if (packageReach.status !== "current" && packageReach.status !== "stale") {
    throw new TypeError("packageReach.status is unsupported");
  }
  const sourceThrough = requireDate(packageReach.sourceThrough, "packageReach.sourceThrough");
  const rankDate = requireDate(packageReach.rankDate, "packageReach.rankDate");
  if (rankDate !== sourceThrough) {
    throw new TypeError("packageReach.rankDate must equal sourceThrough");
  }
  const windows = requireObject(packageReach.windows, "packageReach.windows");
  validateWindow(windows.last30Days, "packageReach.windows.last30Days", sourceThrough, 30);
  validateWindow(windows.last365Days, "packageReach.windows.last365Days", sourceThrough, 365);
  const packages = requireArray(packageReach.packages, "packageReach.packages");
  if (packages.length !== PACKAGES.length) {
    throw new TypeError("packageReach.packages must contain exactly three packages");
  }
  packages.forEach(validatePackage);
  return packageReach;
}
