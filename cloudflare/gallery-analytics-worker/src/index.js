import { buildSummary, validateSummary } from "./schema.js";

const GRAPHQL_ENDPOINT = "https://api.cloudflare.com/client/v4/graphql";
const SNAPSHOT_KEY = "gallery-analytics:summary:v1";
const REQUEST_TIMEOUT_MS = 15000;

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

function publicSnapshot(snapshot, env, now) {
  const checked = validateSummary(snapshot);
  const age = now.getTime() - Date.parse(checked.generatedAt);
  return validateSummary({
    ...checked,
    status: age > staleAfterMilliseconds(env) ? "stale" : "current"
  });
}

export async function queryCloudflare(env, now = new Date(), fetchImplementation = fetch) {
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
        query: GALLERY_ANALYTICS_QUERY,
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

export async function handleRequest(request, env, now = new Date()) {
  const url = new URL(request.url);

  if (request.method === "OPTIONS") {
    const origin = request.headers.get("Origin");
    if (!origin || !allowedOrigins(env).has(origin)) {
      return jsonResponse(request, env, { error: "Origin not allowed" }, 403, "no-store");
    }
    return new Response(null, { status: 204, headers: responseHeaders(request, env, "no-store") });
  }

  if (url.pathname !== "/v1/summary") {
    return jsonResponse(request, env, { error: "Not found" }, 404, "no-store");
  }
  if (request.method !== "GET") {
    return jsonResponse(request, env, { error: "Method not allowed" }, 405, "no-store");
  }

  try {
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
    try {
      await refreshSnapshot(env);
    } catch (error) {
      console.error("Gallery analytics refresh failed", error instanceof Error ? error.message : "unknown error");
      throw error;
    }
  }
};
