import { buildScopedSummary, buildSummary, validateSummary } from "./schema.js";
import { validatePackageReach } from "./package-reach-schema.js";

const GRAPHQL_ENDPOINT = "https://api.cloudflare.com/client/v4/graphql";
const SNAPSHOT_KEY = "gallery-analytics:summary:v1";
const RESEARCH_SNAPSHOT_KEY = "research-analytics:summary:v1";
const PACKAGE_REACH_KEY = "gallery-analytics:package-reach:v1";
const REQUEST_TIMEOUT_MS = 15000;
const MAX_INGEST_BYTES = 20000;

export const GALLERY_ANALYTICS_QUERY = `
query GalleryAnalytics(
  $accountTag: string!
  $siteTag: string!
  $requestHost: string!
  $since7: Time!
  $since30: Time!
  $until: Time!
) {
  viewer {
    accounts(filter: { accountTag: $accountTag }) {
      totals7: rumPageloadEventsAdaptiveGroups(
        limit: 1
        filter: {
          siteTag: $siteTag
          requestHost: $requestHost
          bot: 0
          datetime_geq: $since7
          datetime_lt: $until
        }
      ) {
        count
        sum { visits }
        avg { sampleInterval }
      }
      totals30: rumPageloadEventsAdaptiveGroups(
        limit: 1
        filter: {
          siteTag: $siteTag
          requestHost: $requestHost
          bot: 0
          datetime_geq: $since30
          datetime_lt: $until
        }
      ) {
        count
        sum { visits }
        avg { sampleInterval }
      }
      pages30: rumPageloadEventsAdaptiveGroups(
        limit: 100
        orderBy: [count_DESC]
        filter: {
          siteTag: $siteTag
          requestHost: $requestHost
          bot: 0
          datetime_geq: $since30
          datetime_lt: $until
        }
      ) {
        count
        dimensions { requestPath }
        sum { visits }
        avg { sampleInterval }
      }
      countries30: rumPageloadEventsAdaptiveGroups(
        limit: 100
        orderBy: [sum_visits_DESC]
        filter: {
          siteTag: $siteTag
          requestHost: $requestHost
          bot: 0
          datetime_geq: $since30
          datetime_lt: $until
        }
      ) {
        count
        dimensions { countryName }
        sum { visits }
        avg { sampleInterval }
      }
      referrers30: rumPageloadEventsAdaptiveGroups(
        limit: 100
        orderBy: [sum_visits_DESC]
        filter: {
          siteTag: $siteTag
          requestHost: $requestHost
          bot: 0
          datetime_geq: $since30
          datetime_lt: $until
        }
      ) {
        count
        dimensions { refererHost }
        sum { visits }
        avg { sampleInterval }
      }
    }
  }
}`;

export const RESEARCH_ANALYTICS_QUERY = `
query ResearchAnalytics(
  $accountTag: string!
  $siteTag: string!
  $requestHost: string!
  $since7: Time!
  $since30: Time!
  $until: Time!
) {
  viewer {
    accounts(filter: { accountTag: $accountTag }) {
      pages7: rumPageloadEventsAdaptiveGroups(
        limit: 5000
        filter: {
          siteTag: $siteTag
          requestHost: $requestHost
          bot: 0
          datetime_geq: $since7
          datetime_lt: $until
        }
      ) {
        count
        dimensions { requestPath }
        sum { visits }
        avg { sampleInterval }
      }
      pages30: rumPageloadEventsAdaptiveGroups(
        limit: 5000
        filter: {
          siteTag: $siteTag
          requestHost: $requestHost
          bot: 0
          datetime_geq: $since30
          datetime_lt: $until
        }
      ) {
        count
        dimensions { requestPath }
        sum { visits }
        avg { sampleInterval }
      }
      countries30: rumPageloadEventsAdaptiveGroups(
        limit: 5000
        filter: {
          siteTag: $siteTag
          requestHost: $requestHost
          bot: 0
          datetime_geq: $since30
          datetime_lt: $until
        }
      ) {
        count
        dimensions { requestPath countryName }
        sum { visits }
        avg { sampleInterval }
      }
      referrers30: rumPageloadEventsAdaptiveGroups(
        limit: 5000
        filter: {
          siteTag: $siteTag
          requestHost: $requestHost
          bot: 0
          datetime_geq: $since30
          datetime_lt: $until
        }
      ) {
        count
        dimensions { requestPath refererHost }
        sum { visits }
        avg { sampleInterval }
      }
    }
  }
}`;

function requiredText(value, label) {
  if (typeof value !== "string" || !value.trim()) {
    throw new TypeError(`${label} is required`);
  }
  return value.trim();
}

function requiredTag(value, label) {
  const tag = requiredText(value, label);
  if (!/^[a-f0-9]{32}$/u.test(tag)) {
    throw new TypeError(`${label} must be a 32-character hexadecimal tag`);
  }
  return tag;
}

function dateBefore(date, days) {
  return new Date(date.getTime() - days * 24 * 60 * 60 * 1000).toISOString();
}

function allowedOrigins(env) {
  const configured = [env.GALLERY_ORIGIN, ...(env.LOCAL_ORIGINS || "").split(",")];
  return new Set(configured.map((value) => value.trim()).filter(Boolean));
}

function responseHeaders(request, env, cacheControl = "public, max-age=900, s-maxage=21600") {
  const headers = new Headers({
    "Cache-Control": cacheControl,
    "Content-Security-Policy": "default-src 'none'; frame-ancestors 'none'",
    "Content-Type": "application/json; charset=utf-8",
    "Referrer-Policy": "no-referrer",
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY"
  });
  const origin = request.headers.get("Origin");
  if (origin && allowedOrigins(env).has(origin)) {
    headers.set("Access-Control-Allow-Origin", origin);
    headers.set("Access-Control-Allow-Methods", "GET, OPTIONS");
    headers.set("Access-Control-Allow-Headers", "Content-Type");
  }
  headers.set("Vary", "Origin");
  return headers;
}

function jsonResponse(request, env, body, status = 200, cacheControl) {
  return new Response(`${JSON.stringify(body)}\n`, {
    status,
    headers: responseHeaders(request, env, cacheControl)
  });
}

function staleAfterMilliseconds(env) {
  const hours = Number.parseInt(env.STALE_AFTER_HOURS || "12", 10);
  return (Number.isInteger(hours) && hours >= 6 && hours <= 168 ? hours : 12) * 60 * 60 * 1000;
}

function packageStaleAfterMilliseconds(env) {
  const hours = Number.parseInt(env.PACKAGE_STALE_AFTER_HOURS || "48", 10);
  return (Number.isInteger(hours) && hours >= 24 && hours <= 168 ? hours : 48) * 60 * 60 * 1000;
}

function publicSnapshot(snapshot, env, now) {
  const checked = validateSummary(snapshot);
  const age = now.getTime() - Date.parse(checked.generatedAt);
  return validateSummary({
    ...checked,
    status: age > staleAfterMilliseconds(env) ? "stale" : "current"
  });
}

function publicPackageReach(snapshot, env, now) {
  const checked = validatePackageReach(snapshot);
  const age = now.getTime() - Date.parse(checked.generatedAt);
  return validatePackageReach({
    ...checked,
    status: age > packageStaleAfterMilliseconds(env) ? "stale" : "current"
  });
}

async function matchingSecret(candidate, expected) {
  if (typeof candidate !== "string" || typeof expected !== "string"
      || candidate.length < 32 || expected.length < 32) {
    return false;
  }
  const encoder = new TextEncoder();
  const [candidateHash, expectedHash] = await Promise.all([
    crypto.subtle.digest("SHA-256", encoder.encode(candidate)),
    crypto.subtle.digest("SHA-256", encoder.encode(expected))
  ]);
  const left = new Uint8Array(candidateHash);
  const right = new Uint8Array(expectedHash);
  let difference = left.length ^ right.length;
  for (let index = 0; index < Math.min(left.length, right.length); index += 1) {
    difference |= left[index] ^ right[index];
  }
  return difference === 0;
}

async function ingestAuthorized(request, env) {
  const authorization = request.headers.get("Authorization") || "";
  const candidate = authorization.startsWith("Bearer ") ? authorization.slice(7) : "";
  return matchingSecret(candidate, env.PACKAGE_REACH_INGEST_TOKEN || "");
}

function validateIngestFreshness(snapshot, now) {
  const age = now.getTime() - Date.parse(snapshot.generatedAt);
  const maximumAge = 24 * 60 * 60 * 1000;
  const maximumClockSkew = 10 * 60 * 1000;
  if (age > maximumAge || age < -maximumClockSkew) {
    throw new TypeError("package reach snapshot is not fresh");
  }
}

async function queryCloudflareWith(query, env, now, fetchImplementation) {
  const accountTag = requiredTag(env.CF_ACCOUNT_TAG, "CF_ACCOUNT_TAG");
  const siteTag = requiredTag(env.CF_SITE_TAG, "CF_SITE_TAG");
  const requestHost = requiredText(env.GALLERY_HOST, "GALLERY_HOST");
  const token = requiredText(env.CF_ANALYTICS_API_TOKEN, "CF_ANALYTICS_API_TOKEN");
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const response = await fetchImplementation(GRAPHQL_ENDPOINT, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        query,
        variables: {
          accountTag,
          siteTag,
          requestHost,
          since7: dateBefore(now, 7),
          since30: dateBefore(now, 30),
          until: now.toISOString()
        }
      }),
      signal: controller.signal
    });

    if (!response.ok) {
      throw new Error(`Cloudflare Analytics returned HTTP ${response.status}`);
    }

    const payload = await response.json();
    if (Array.isArray(payload.errors) && payload.errors.length > 0) {
      throw new Error("Cloudflare Analytics returned a GraphQL error");
    }
    return payload;
  } finally {
    clearTimeout(timeout);
  }
}

export async function queryCloudflare(env, now = new Date(), fetchImplementation = fetch) {
  return queryCloudflareWith(GALLERY_ANALYTICS_QUERY, env, now, fetchImplementation);
}

export async function queryResearchCloudflare(env, now = new Date(), fetchImplementation = fetch) {
  return queryCloudflareWith(RESEARCH_ANALYTICS_QUERY, env, now, fetchImplementation);
}

export async function refreshSnapshot(env, now = new Date(), fetchImplementation = fetch) {
  if (!env.GALLERY_ANALYTICS_CACHE || typeof env.GALLERY_ANALYTICS_CACHE.put !== "function") {
    throw new TypeError("GALLERY_ANALYTICS_CACHE binding is required");
  }
  const payload = await queryCloudflare(env, now, fetchImplementation);
  const summary = buildSummary(payload, {
    minimumCount: env.MIN_PUBLIC_COUNT,
    limit: env.TOP_LIMIT,
    pathPrefix: env.GALLERY_PATH_PREFIX || "/gallery/"
  }, now);
  await env.GALLERY_ANALYTICS_CACHE.put(SNAPSHOT_KEY, JSON.stringify(summary));
  return summary;
}

export async function refreshResearchSnapshot(env, now = new Date(), fetchImplementation = fetch) {
  if (!env.GALLERY_ANALYTICS_CACHE || typeof env.GALLERY_ANALYTICS_CACHE.put !== "function") {
    throw new TypeError("GALLERY_ANALYTICS_CACHE binding is required");
  }
  const payload = await queryResearchCloudflare(env, now, fetchImplementation);
  const summary = buildScopedSummary(payload, {
    minimumCount: env.MIN_PUBLIC_COUNT,
    limit: env.TOP_LIMIT,
    pathPrefix: env.RESEARCH_PATH_PREFIX || "/research/"
  }, now);
  await env.GALLERY_ANALYTICS_CACHE.put(RESEARCH_SNAPSHOT_KEY, JSON.stringify(summary));
  return summary;
}

export async function loadSnapshot(env) {
  if (!env.GALLERY_ANALYTICS_CACHE || typeof env.GALLERY_ANALYTICS_CACHE.get !== "function") {
    throw new TypeError("GALLERY_ANALYTICS_CACHE binding is required");
  }
  const stored = await env.GALLERY_ANALYTICS_CACHE.get(SNAPSHOT_KEY);
  if (stored === null || stored === undefined) {
    return null;
  }
  return validateSummary(JSON.parse(stored));
}

export async function loadResearchSnapshot(env) {
  if (!env.GALLERY_ANALYTICS_CACHE || typeof env.GALLERY_ANALYTICS_CACHE.get !== "function") {
    throw new TypeError("GALLERY_ANALYTICS_CACHE binding is required");
  }
  const stored = await env.GALLERY_ANALYTICS_CACHE.get(RESEARCH_SNAPSHOT_KEY);
  if (stored === null || stored === undefined) {
    return null;
  }
  return validateSummary(JSON.parse(stored));
}

export async function loadPackageReach(env) {
  if (!env.GALLERY_ANALYTICS_CACHE || typeof env.GALLERY_ANALYTICS_CACHE.get !== "function") {
    throw new TypeError("GALLERY_ANALYTICS_CACHE binding is required");
  }
  const stored = await env.GALLERY_ANALYTICS_CACHE.get(PACKAGE_REACH_KEY);
  if (stored === null || stored === undefined) {
    return null;
  }
  return validatePackageReach(JSON.parse(stored));
}

export async function ingestPackageReach(request, env, now = new Date()) {
  if (!await ingestAuthorized(request, env)) {
    return jsonResponse(request, env, { error: "Not authorized" }, 401, "no-store");
  }
  if (!env.GALLERY_ANALYTICS_CACHE || typeof env.GALLERY_ANALYTICS_CACHE.put !== "function") {
    return jsonResponse(request, env, { error: "Package reach storage is unavailable" }, 503, "no-store");
  }
  const body = await request.text();
  if (body.length > MAX_INGEST_BYTES) {
    return jsonResponse(request, env, { error: "Payload too large" }, 413, "no-store");
  }

  try {
    const snapshot = validatePackageReach(JSON.parse(body));
    validateIngestFreshness(snapshot, now);
    await env.GALLERY_ANALYTICS_CACHE.put(PACKAGE_REACH_KEY, JSON.stringify(snapshot));
    return jsonResponse(request, env, {
      stored: true,
      generatedAt: snapshot.generatedAt
    }, 200, "no-store");
  } catch {
    return jsonResponse(request, env, { error: "Package reach snapshot is invalid" }, 400, "no-store");
  }
}

export async function handleRequest(request, env, now = new Date()) {
  const url = new URL(request.url);

  if (request.method === "OPTIONS") {
    const origin = request.headers.get("Origin");
    if (!origin || !allowedOrigins(env).has(origin)) {
      return jsonResponse(request, env, { error: "Origin not allowed" }, 403, "no-store");
    }
    return new Response(null, { status: 204, headers: responseHeaders(request, env, "no-store") });
  }

  const knownPath = url.pathname === "/v1/summary"
    || url.pathname === "/v1/research-summary"
    || url.pathname === "/v1/package-reach";
  if (!knownPath) {
    return jsonResponse(request, env, { error: "Not found" }, 404, "no-store");
  }
  if (url.pathname === "/v1/package-reach" && request.method === "PUT") {
    return ingestPackageReach(request, env, now);
  }
  if (request.method !== "GET") {
    return jsonResponse(request, env, { error: "Method not allowed" }, 405, "no-store");
  }

  try {
    if (url.pathname === "/v1/package-reach") {
      const packageReach = await loadPackageReach(env);
      if (!packageReach) {
        return jsonResponse(request, env, { error: "Package reach summary is not available yet" }, 503, "no-store");
      }
      return jsonResponse(request, env, publicPackageReach(packageReach, env, now));
    }
    if (url.pathname === "/v1/research-summary") {
      const researchSnapshot = await loadResearchSnapshot(env);
      if (!researchSnapshot) {
        return jsonResponse(request, env, { error: "Research usage summary is not available yet" }, 503, "no-store");
      }
      return jsonResponse(request, env, publicSnapshot(researchSnapshot, env, now));
    }
    const snapshot = await loadSnapshot(env);
    if (!snapshot) {
      return jsonResponse(request, env, { error: "Usage summary is not available yet" }, 503, "no-store");
    }
    return jsonResponse(request, env, publicSnapshot(snapshot, env, now));
  } catch {
    return jsonResponse(request, env, { error: "Usage summary is temporarily unavailable" }, 503, "no-store");
  }
}

export default {
  fetch(request, env) {
    return handleRequest(request, env);
  },
  async scheduled(_controller, env) {
    const results = await Promise.allSettled([
      refreshSnapshot(env),
      refreshResearchSnapshot(env)
    ]);
    const labels = ["Gallery", "Research"];
    let failed = false;
    results.forEach((result, index) => {
      if (result.status === "rejected") {
        failed = true;
        const error = result.reason;
        console.error(`${labels[index]} analytics refresh failed`,
          error instanceof Error ? error.message : "unknown error");
      }
    });
    if (failed) {
      throw new Error("One or more analytics refreshes failed");
    }
  }
};
