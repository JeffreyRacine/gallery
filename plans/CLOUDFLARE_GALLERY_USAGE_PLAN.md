# Cloudflare Gallery Usage Extension Plan

## Purpose

Add a small public usage summary under the Gallery's **Support** section. The
page will report privacy-preserving aggregate traffic information and refresh
without rerendering or redeploying the Quarto site.

This document is an implementation plan only. It does not authorize a live
Cloudflare deployment or a Gallery push.

## Success criteria

The implementation is complete when:

1. Cloudflare Web Analytics records Gallery page views through a site-specific
   browser beacon.
2. A Cloudflare Worker retrieves only the required aggregates through the
   Cloudflare GraphQL Analytics API.
3. The Worker refreshes and caches a validated summary every six hours.
4. A new Gallery Support page fetches that public summary when opened, so data
   changes do not require a Quarto render.
5. No Cloudflare API credential, raw IP address, query string, or individual
   visit record is present in the repository, rendered site, browser response,
   or public page.
6. Failure of the analytics service cannot impair navigation, examples, search,
   or any other Gallery content.

## Current Gallery state

- The site is a pre-rendered Quarto website published from `docs/` on GitHub
  Pages.
- `_quarto.yml` defines a **Support** section but has no analytics beacon or
  dynamic usage page.
- `.github/workflows/render-check.yml` verifies the committed Pages artifacts;
  it does not currently build or test a service component.
- The Gallery can therefore remain static while a browser-side component reads
  aggregate JSON from a separately deployed Worker.

## Architecture

```text
Gallery visitor
    |
    | page-load beacon
    v
Cloudflare Web Analytics
    |
    | authenticated aggregate query every six hours
    v
Cloudflare Worker ----> Workers KV (last known good snapshot)
    |
    | public, sanitized JSON
    v
Gallery Usage page on GitHub Pages
```

The Worker runs in Jeffrey's Cloudflare account under a stable `workers.dev`
address. Its source is version-controlled with the Gallery, but its API token is
stored only as an encrypted Cloudflare Worker secret.

## Public data contract

The Worker will expose one read-only route, `GET /v1/summary`, with a fixed
versioned response:

```json
{
  "schemaVersion": 1,
  "generatedAt": "2026-11-21T18:00:00Z",
  "status": "current",
  "totals": {
    "last7Days": { "visits": 0, "pageViews": 0 },
    "last30Days": { "visits": 0, "pageViews": 0 }
  },
  "topPages": [{ "path": "/gallery/quickstarts.html", "pageViews": 0 }],
  "topCountries": [{ "country": "Canada", "visits": 0 }],
  "topReferrers": [{ "host": "cran.r-project.org", "visits": 0 }],
  "sampling": { "applied": false, "sampleInterval": 1 }
}
```

The final field names will be frozen only after querying Cloudflare's live
GraphQL schema for the Web Analytics site. The public page will use Cloudflare's
term **visits** and will not relabel it as **unique visitors**.

## Privacy and security rules

1. Query only the Gallery hostname and the `/gallery/` path prefix.
2. Exclude recognized bots where the Web Analytics dataset permits it.
3. Publish only the ten leading pages, countries, and referring domains.
4. Suppress country and referrer rows with fewer than five visits; combine
   suppressed observations into `Other` only when that cannot reveal a small
   cell.
5. Publish referring hosts, never full referring paths or query strings.
6. Never collect, store, return, log, or display raw IP addresses.
7. Store the GraphQL token as `CF_ANALYTICS_API_TOKEN` using `wrangler secret`.
   Grant only `Account Analytics: Read` for the required account.
8. Keep the GraphQL query fixed in Worker code. The public endpoint must not
   accept arbitrary dates, filters, queries, account identifiers, or site tags.
9. Permit browser CORS for the production Gallery origin and explicit local
   preview origins. CORS is not treated as authentication because the returned
   summary is intentionally public.
10. Return security headers and cache headers with every response. Do not emit
    internal Cloudflare errors or identifiers to the browser.

## Exact repository changes

### Gallery sources

- Add `gallery_usage.qmd` containing the public explanation, metric placeholders,
  accessible tables, methodology note, last-refresh time, and unavailable/stale
  states.
- Add `gallery_usage.qmd` to the **Support** section of `_quarto.yml`, labelled
  `Gallery Usage`.
- Add `includes/cloudflare-web-analytics.html` containing only Cloudflare's
  public site beacon. Include it globally through the HTML format configuration
  in `_quarto.yml`.
- Add `www/js/gallery-usage.js` to fetch, validate, and render `/v1/summary`.
  The script will use DOM text nodes rather than injected HTML.
- Extend `styles.css` with narrowly scoped `.gallery-usage-*` rules for the
  summary cards, tables, loading state, stale notice, and small screens.
- Extend `gallery_hygiene_lint.sh` with checks that the rendered usage page and
  client script exist and that no API-token assignment appears in tracked or
  rendered files.
- Extend `.gitignore` for Worker-local `.dev.vars`, `.wrangler/`, `node_modules/`,
  coverage output, and other local credential/build products.

### Worker sources

Add an isolated project under `cloudflare/gallery-analytics-worker/`:

- `package.json` and `pnpm-lock.yaml`: pinned deployment tooling; tests use
  Node's built-in test runner.
- `wrangler.jsonc`: Worker name, compatibility date, KV binding, and six-hour
  Cron Trigger. It must contain no secret values.
- `src/index.js`: `fetch()` and `scheduled()` handlers, GraphQL request,
  validation, suppression, snapshot storage, response headers, and stale-data
  fallback.
- `src/schema.js`: internal and public response runtime validation.
- `test/worker.test.js`: mocked GraphQL and KV tests for the public contract.
- `README.md`: setup, secret creation, local testing, deployment, refresh,
  monitoring, and rollback commands.

### Continuous checks

- Extend `.github/workflows/render-check.yml` with a secret-free Worker test job
  that runs against mocked responses.
- Do not deploy the Worker from GitHub Actions in the first implementation.
  Deployment will be an explicit local operation so no Cloudflare deployment
  credential needs to be added to GitHub.

## Cloudflare resources

Create these resources in Jeffrey's Cloudflare account:

1. A Web Analytics site for `jeffreyracine.github.io`, with the beacon installed
   only in the Gallery build.
2. A narrowly scoped GraphQL Analytics API token with read-only account
   analytics permission.
3. A Worker named `gallery-analytics` with a stable `workers.dev` endpoint.
4. A KV namespace bound as `GALLERY_ANALYTICS_CACHE` containing only the current
   validated snapshot and refresh metadata.
5. A Cron Trigger such as `17 */6 * * *`, avoiding a top-of-hour burst.

The account tag and Web Analytics site tag may be Worker configuration values.
The GraphQL API token is the only required secret. The site beacon token is
necessarily public in the rendered HTML and must not be confused with the API
token.

### Free-tier guardrail

- Keep the project on Workers Free and do not activate a paid usage model.
- Six-hour refreshes require four KV writes per day, versus the current free
  allowance of 1,000.
- Each public summary request requires one Worker request and one KV read,
  versus the current free allowance of 100,000 per day for each.
- Treat a free-tier exhaustion as a temporary unavailable summary, never as a
  reason to enable billing automatically.
- Recheck Cloudflare's published limits before any material increase in refresh
  frequency, storage, or public traffic.

## Implementation sequence

### 1. Establish the live API contract

- Create or select the Web Analytics site and obtain its public beacon snippet.
- Create the read-only API token through the Cloudflare dashboard.
- Inspect the live GraphQL schema and run bounded queries against
  `rumPageloadEventsAdaptiveGroups` for visits, page views, paths, countries,
  referrers, bot exclusion, and `sampleInterval`.
- Record the exact query and a redacted response fixture for tests.
- Stop if the live schema cannot provide any required aggregate without broader
  permissions or disallowed individual-level data.

### 2. Implement and test the Worker locally

- Implement the fixed GraphQL queries and strict response validation.
- Normalize Gallery paths and reject rows outside `/gallery/`.
- Apply top-ten limits and low-count suppression before writing the snapshot.
- Write a new KV snapshot only after the complete response validates.
- If a refresh fails, preserve the previous snapshot and mark it stale; do not
  replace it with a partial or zero-filled result.
- Test normal, empty, sampled, malformed, unauthorized, timeout, suppression,
  stale, CORS, and unsupported-method cases with mocked dependencies.

### 3. Deploy and qualify the Worker

- Create the KV namespace and bind it to the Worker.
- Install the API token with `wrangler secret put`; never place it in a shell
  history command, source file, `.dev.vars`, or transcript committed to Git.
- Deploy the Worker, invoke one controlled refresh, and inspect the stored
  snapshot.
- Verify that the public endpoint returns only the documented schema and that
  repository/browser searches cannot recover the API token.
- Confirm scheduled refresh history and last-known-good behavior before linking
  the Gallery to the endpoint.

### 4. Implement the Gallery page

- Add the beacon, Support navigation entry, page, browser script, and styling.
- Present 7- and 30-day totals, followed by compact top-page, country, and
  referrer tables.
- Explain that counts are approximate, may be sampled, begin only after the
  beacon is installed, and can omit visitors who block JavaScript or analytics.
- Display an unobtrusive unavailable message when the Worker cannot be reached;
  the rest of the page and site must remain fully usable.

### 5. Render and verify locally

- Run `quarto render`.
- Run `./gallery_hygiene_lint.sh` and `git diff --check`.
- Run the Worker unit tests and a local Worker/Gallery integration test.
- Verify desktop and mobile layouts, keyboard navigation, screen-reader labels,
  loading behavior, stale behavior, and failed-request behavior.
- Confirm source/rendered resource parity and verify that `docs/search.json` and
  `docs/sitemap.xml` include the new Support page.

### 6. Publish deliberately

- Review the rendered page and its exact public metrics with Jeffrey.
- Commit the Worker and Gallery changes together only after all local gates pass.
- Push only after explicit authorization.
- Verify the production beacon request, Worker response, page rendering, and
  first scheduled refresh. Analytics collected before beacon installation will
  not be recoverable.

## Validation gates

### Hard gates

- No secret or credential in Git history, tracked files, rendered files,
  browser source, responses, logs, or test fixtures.
- No raw IP, city, full referrer path, query string, or individual event in the
  public response.
- All low-count suppression and path-scope tests pass.
- The Worker never writes a partial or invalid snapshot.
- The Gallery remains fully functional with JavaScript disabled and with the
  Worker unavailable.
- A complete Quarto render, Gallery hygiene check, Worker test suite, and diff
  check pass before commit.

### Live acceptance checks

- Cloudflare records Gallery page views after the beacon is published.
- `/v1/summary` returns valid current or explicitly stale JSON.
- The Support page updates after a Worker refresh without a Quarto render,
  Gallery commit, or GitHub Pages deployment.
- The displayed totals and top rows reconcile with the Cloudflare dashboard for
  the same period, allowing for documented sampling and refresh delay.

## Failure handling and rollback

- **Worker/API failure:** serve the last valid snapshot with a stale timestamp;
  otherwise show the Gallery's unavailable state.
- **Schema change:** stop snapshot replacement, retain the last valid snapshot,
  and repair the Worker independently of Quarto.
- **Public-page problem:** remove the Support navigation entry and browser
  component while leaving the rest of the Gallery unchanged.
- **Collection rollback:** remove the global beacon include and render once.
- **Immediate security rollback:** disable the Worker and revoke the API token in
  Cloudflare; this does not require a Gallery render.

## Required authorization checkpoint

Local source implementation can proceed autonomously once requested. Completing
the live setup requires Jeffrey to authenticate to his Cloudflare account. Codex
can guide or operate the visible setup after that authentication, but Jeffrey's
password, recovery code, and API token must not be pasted into chat or committed
to the repository.

## Deferred enhancements

The first release will not create a permanent longitudinal database, track
custom events, expose download-level behavior, or publish device/browser
details. If the basic summary proves useful, a later isolated tranche may store
daily aggregates in D1 for trends beyond Cloudflare Web Analytics' reporting
window. That extension should follow, not complicate, the initial privacy-safe
deployment.

## Primary references

- [Cloudflare Web Analytics](https://developers.cloudflare.com/web-analytics/about/)
- [Web Analytics dimensions](https://developers.cloudflare.com/web-analytics/data-metrics/dimensions/)
- [Web Analytics data retention and sampling](https://developers.cloudflare.com/web-analytics/faq/)
- [GraphQL Analytics API token setup](https://developers.cloudflare.com/analytics/graphql-api/getting-started/authentication/api-token-auth/)
- [Cloudflare Workers Cron Triggers](https://developers.cloudflare.com/workers/configuration/cron-triggers/)
