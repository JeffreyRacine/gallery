import assert from "node:assert/strict";
import test from "node:test";

import {
  handleRequest,
  loadPackageReach,
  loadSnapshot,
  refreshSnapshot
} from "../src/index.js";
import { validatePackageReach } from "../src/package-reach-schema.js";
import { buildSummary, validateSummary } from "../src/schema.js";

const generatedAt = new Date("2026-11-21T18:00:00Z");
const ingestToken = "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc";

function group({ count, visits, dimensions = {}, sampleInterval = 1 }) {
  return {
    count,
    sum: { visits },
    avg: { sampleInterval },
    dimensions
  };
}

function graphQLPayload() {
  return {
    data: {
      viewer: {
        accounts: [{
          totals7: [group({ count: 120, visits: 72 })],
          totals30: [group({ count: 480, visits: 260, sampleInterval: 2 })],
          pages30: [
            group({ count: 90, visits: 40, dimensions: { requestPath: "/gallery/quickstarts.html" } }),
            group({ count: 35, visits: 20, dimensions: { requestPath: "/gallery/regression.html" } }),
            group({ count: 500, visits: 300, dimensions: { requestPath: "/research/index.html" } }),
            group({ count: 4, visits: 4, dimensions: { requestPath: "/gallery/rare.html" } })
          ],
          countries30: [
            group({ count: 100, visits: 50, dimensions: { countryName: "Canada" } }),
            group({ count: 9, visits: 4, dimensions: { countryName: "France" } })
          ],
          referrers30: [
            group({ count: 60, visits: 30, dimensions: { refererHost: "CRAN.R-project.org" } }),
            group({ count: 25, visits: 12, dimensions: { refererHost: "" } }),
            group({ count: 8, visits: 3, dimensions: { refererHost: "small.example" } })
          ]
        }]
      }
    }
  };
}

function emptyGraphQLPayload() {
  return {
    data: {
      viewer: {
        accounts: [{
          totals7: [],
          totals30: [],
          pages30: [],
          countries30: [],
          referrers30: []
        }]
      }
    }
  };
}

function packageReachSnapshot() {
  return {
    schemaVersion: 1,
    generatedAt: generatedAt.toISOString(),
    status: "current",
    sourceThrough: "2026-11-20",
    rankDate: "2026-11-20",
    windows: {
      last30Days: { from: "2026-10-22", to: "2026-11-20" },
      last365Days: { from: "2025-11-21", to: "2026-11-20" }
    },
    packages: [
      {
        package: "np",
        downloads30: 8858,
        downloads365: 118129,
        downloadsOnRankDate: 312,
        dailyRank: 920,
        dailyRankTotal: 18800,
        dailyPercentile: 95.1,
        reverseDependencies: { required: 28, all: 50 }
      },
      {
        package: "npRmpi",
        downloads30: 531,
        downloads365: 3312,
        downloadsOnRankDate: 18,
        dailyRank: 7300,
        dailyRankTotal: 18800,
        dailyPercentile: 61.2,
        reverseDependencies: { required: 0, all: 0 }
      },
      {
        package: "crs",
        downloads30: 7327,
        downloads365: 81993,
        downloadsOnRankDate: 270,
        dailyRank: 1100,
        dailyRankTotal: 18800,
        dailyPercentile: 94.1,
        reverseDependencies: { required: 32, all: 54 }
      }
    ]
  };
}

class MemoryKV {
  constructor(initial = {}) {
    this.values = new Map(Object.entries(initial));
    this.putCount = 0;
  }

  async get(key) {
    return this.values.has(key) ? this.values.get(key) : null;
  }

  async put(key, value) {
    this.putCount += 1;
    this.values.set(key, value);
  }
}

function environment(kv = new MemoryKV()) {
  return {
    CF_ACCOUNT_TAG: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    CF_SITE_TAG: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    CF_ANALYTICS_API_TOKEN: "private-test-token",
    GALLERY_HOST: "jeffreyracine.github.io",
    GALLERY_PATH_PREFIX: "/gallery/",
    GALLERY_ORIGIN: "https://jeffreyracine.github.io",
    LOCAL_ORIGINS: "http://127.0.0.1:8765,http://localhost:8765",
    MIN_PUBLIC_COUNT: "5",
    TOP_LIMIT: "10",
    STALE_AFTER_HOURS: "12",
    PACKAGE_STALE_AFTER_HOURS: "48",
    PACKAGE_REACH_INGEST_TOKEN: ingestToken,
    GALLERY_ANALYTICS_CACHE: kv
  };
}

test("buildSummary applies scope, suppression, and sampling rules", () => {
  const summary = buildSummary(graphQLPayload(), {
    minimumCount: "5",
    limit: "10",
    pathPrefix: "/gallery/"
  }, generatedAt);

  assert.deepEqual(summary.totals.last7Days, { visits: 72, pageViews: 120 });
  assert.deepEqual(summary.totals.last30Days, { visits: 260, pageViews: 480 });
  assert.deepEqual(summary.topPages, [
    { path: "/gallery/quickstarts.html", pageViews: 90 },
    { path: "/gallery/regression.html", pageViews: 35 }
  ]);
  assert.deepEqual(summary.topCountries, [{ country: "Canada", visits: 50 }]);
  assert.deepEqual(summary.topReferrers, [
    { host: "cran.r-project.org", visits: 30 },
    { host: "Direct or unavailable", visits: 12 }
  ]);
  assert.deepEqual(summary.sampling, { applied: true, sampleInterval: 2 });
  assert.equal(JSON.stringify(summary).includes("private-test-token"), false);
});

test("buildSummary accepts a valid account with no analytics events yet", () => {
  const summary = buildSummary(emptyGraphQLPayload(), {
    minimumCount: "5",
    limit: "10",
    pathPrefix: "/gallery/"
  }, generatedAt);

  assert.deepEqual(summary.totals.last7Days, { visits: 0, pageViews: 0 });
  assert.deepEqual(summary.totals.last30Days, { visits: 0, pageViews: 0 });
  assert.deepEqual(summary.topPages, []);
  assert.deepEqual(summary.topCountries, []);
  assert.deepEqual(summary.topReferrers, []);
  assert.deepEqual(summary.sampling, { applied: false, sampleInterval: 1 });
});

test("buildSummary rejects an invalid multi-row aggregate", () => {
  const payload = graphQLPayload();
  payload.data.viewer.accounts[0].totals7.push(
    group({ count: 1, visits: 1 })
  );

  assert.throws(() => buildSummary(payload, {
    minimumCount: "5",
    limit: "10",
    pathPrefix: "/gallery/"
  }, generatedAt), /at most one aggregate row/u);
});

test("refreshSnapshot writes only a complete validated response", async () => {
  const kv = new MemoryKV();
  const env = environment(kv);
  const fetchImplementation = async (_url, options) => {
    assert.equal(options.headers.Authorization, "Bearer private-test-token");
    const body = JSON.parse(options.body);
    assert.equal(body.variables.requestHost, "jeffreyracine.github.io");
    return new Response(JSON.stringify(graphQLPayload()), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });
  };

  const summary = await refreshSnapshot(env, generatedAt, fetchImplementation);
  assert.equal(kv.putCount, 1);
  assert.deepEqual(await loadSnapshot(env), summary);
});

test("refreshSnapshot preserves the previous snapshot after a GraphQL error", async () => {
  const previous = buildSummary(graphQLPayload(), {
    minimumCount: "5",
    limit: "10",
    pathPrefix: "/gallery/"
  }, generatedAt);
  const kv = new MemoryKV({ "gallery-analytics:summary:v1": JSON.stringify(previous) });
  const env = environment(kv);
  const fetchImplementation = async () => new Response(JSON.stringify({
    data: null,
    errors: [{ message: "not authorized" }]
  }), { status: 200, headers: { "Content-Type": "application/json" } });

  await assert.rejects(refreshSnapshot(env, generatedAt, fetchImplementation));
  assert.equal(kv.putCount, 0);
  assert.deepEqual(await loadSnapshot(env), previous);
});

test("handleRequest returns a stale last-known-good snapshot", async () => {
  const summary = buildSummary(graphQLPayload(), {
    minimumCount: "5",
    limit: "10",
    pathPrefix: "/gallery/"
  }, generatedAt);
  const kv = new MemoryKV({ "gallery-analytics:summary:v1": JSON.stringify(summary) });
  const env = environment(kv);
  const request = new Request("https://gallery-analytics.example.workers.dev/v1/summary", {
    headers: { Origin: "https://jeffreyracine.github.io" }
  });

  const response = await handleRequest(request, env, new Date("2026-11-22T12:01:00Z"));
  const payload = await response.json();
  assert.equal(response.status, 200);
  assert.equal(payload.status, "stale");
  assert.equal(response.headers.get("Access-Control-Allow-Origin"), "https://jeffreyracine.github.io");
  assert.equal(response.headers.get("X-Content-Type-Options"), "nosniff");
});

test("handleRequest fails closed for missing data and unapproved origins", async () => {
  const env = environment();
  const missing = await handleRequest(
    new Request("https://gallery-analytics.example.workers.dev/v1/summary"),
    env,
    generatedAt
  );
  assert.equal(missing.status, 503);

  const preflight = await handleRequest(new Request(
    "https://gallery-analytics.example.workers.dev/v1/summary",
    { method: "OPTIONS", headers: { Origin: "https://unapproved.example" } }
  ), env, generatedAt);
  assert.equal(preflight.status, 403);
  assert.equal(preflight.headers.has("Access-Control-Allow-Origin"), false);
});

test("validateSummary rejects an unsupported public schema", () => {
  assert.throws(() => validateSummary({ schemaVersion: 99 }), /schema version/u);
});

test("validatePackageReach accepts the fixed package contract", () => {
  assert.deepEqual(validatePackageReach(packageReachSnapshot()), packageReachSnapshot());
  const invalid = packageReachSnapshot();
  invalid.packages.reverse();
  assert.throws(() => validatePackageReach(invalid), /unsupported or out of order/u);
  const wrongWindow = packageReachSnapshot();
  wrongWindow.windows.last30Days.from = "2026-10-21";
  assert.throws(() => validatePackageReach(wrongWindow), /fixed rolling window/u);
});

test("package reach ingestion authenticates and stores only valid snapshots", async () => {
  const kv = new MemoryKV();
  const env = environment(kv);
  const endpoint = "https://gallery-analytics.example.workers.dev/v1/package-reach";
  const missingSecretEnv = environment(kv);
  delete missingSecretEnv.PACKAGE_REACH_INGEST_TOKEN;
  const missingSecret = await handleRequest(new Request(endpoint, {
    method: "PUT",
    body: JSON.stringify(packageReachSnapshot())
  }), missingSecretEnv, generatedAt);
  assert.equal(missingSecret.status, 401);
  assert.equal(kv.putCount, 0);

  const unauthorized = await handleRequest(new Request(endpoint, {
    method: "PUT",
    body: JSON.stringify(packageReachSnapshot())
  }), env, generatedAt);
  assert.equal(unauthorized.status, 401);
  assert.equal(kv.putCount, 0);

  const invalid = packageReachSnapshot();
  invalid.packages[0].downloads30 = -1;
  const rejected = await handleRequest(new Request(endpoint, {
    method: "PUT",
    headers: { Authorization: `Bearer ${ingestToken}` },
    body: JSON.stringify(invalid)
  }), env, generatedAt);
  assert.equal(rejected.status, 400);
  assert.equal(kv.putCount, 0);

  const accepted = await handleRequest(new Request(endpoint, {
    method: "PUT",
    headers: { Authorization: `Bearer ${ingestToken}` },
    body: JSON.stringify(packageReachSnapshot())
  }), env, generatedAt);
  assert.equal(accepted.status, 200);
  assert.equal(kv.putCount, 1);
  assert.deepEqual(await loadPackageReach(env), packageReachSnapshot());
});

test("package reach returns a stale last-known-good snapshot independently", async () => {
  const snapshot = packageReachSnapshot();
  const kv = new MemoryKV({
    "gallery-analytics:package-reach:v1": JSON.stringify(snapshot)
  });
  const env = environment(kv);
  const response = await handleRequest(new Request(
    "https://gallery-analytics.example.workers.dev/v1/package-reach",
    { headers: { Origin: "https://jeffreyracine.github.io" } }
  ), env, new Date("2026-11-24T18:01:00Z"));
  const payload = await response.json();
  assert.equal(response.status, 200);
  assert.equal(payload.status, "stale");
  assert.equal(payload.packages.length, 3);
  assert.equal(response.headers.get("Access-Control-Allow-Origin"), "https://jeffreyracine.github.io");
});

test("package reach ingestion rejects an old snapshot without replacing storage", async () => {
  const snapshot = packageReachSnapshot();
  const kv = new MemoryKV({
    "gallery-analytics:package-reach:v1": JSON.stringify(snapshot)
  });
  const env = environment(kv);
  const request = new Request(
    "https://gallery-analytics.example.workers.dev/v1/package-reach",
    {
      method: "PUT",
      headers: { Authorization: `Bearer ${ingestToken}` },
      body: JSON.stringify(snapshot)
    }
  );
  const response = await handleRequest(request, env, new Date("2026-11-23T18:01:00Z"));
  assert.equal(response.status, 400);
  assert.equal(kv.putCount, 0);
  assert.deepEqual(await loadPackageReach(env), snapshot);
});
