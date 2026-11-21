# Gallery analytics Worker

This Worker exposes privacy-preserving Gallery traffic and package-reach
summaries. Cloudflare Web Analytics supplies the traffic data. A daily GitHub
workflow uses `packageRank`, `cranlogs`, and current CRAN metadata to publish a
separate package snapshot. Only validated aggregates are cached in Workers KV.

Public endpoints:

```text
https://gallery-analytics.gallery-analytics-worker.workers.dev/v1/summary
https://gallery-analytics.gallery-analytics-worker.workers.dev/v1/package-reach
```

## Safety contract

- The public API has two read-only routes: `GET /v1/summary` and
  `GET /v1/package-reach`.
- The GraphQL query and its 7- and 30-day windows are fixed in source.
- Paths outside `/gallery/` and country/referrer counts below five are omitted.
- Analytics and package-ingest credentials are secrets and must never enter
  this repository.
- A failed refresh leaves the last valid KV snapshot unchanged.
- Package ingestion accepts only the three tracked packages, a fresh timestamp,
  fixed rolling windows, and bounded non-negative metrics.
- The Worker is intended for the Cloudflare Workers Free plan.

## Local checks

```sh
pnpm install
pnpm run check
pnpm exec wrangler deploy --dry-run
```

The tests use mocked GraphQL and KV responses; they require no Cloudflare
credentials.

## One-time Cloudflare setup

1. Add `jeffreyracine.github.io` as a Web Analytics site and retain its public
   site tag and beacon token.
2. Create an API token with only `Account Analytics: Read` for the account.
3. Authenticate Wrangler interactively:

   ```sh
   pnpm exec wrangler login
   ```

4. Replace `CF_ACCOUNT_TAG` and `CF_SITE_TAG` in `wrangler.jsonc`.
5. Create and bind the KV namespace:

   ```sh
   pnpm exec wrangler kv namespace create gallery-analytics-cache \
     --binding GALLERY_ANALYTICS_CACHE --update-config
   ```

6. Store the API token through Wrangler's private prompt:

   ```sh
   pnpm exec wrangler secret put CF_ANALYTICS_API_TOKEN
   ```

7. Generate a separate random package-ingest token and store the same value as
   the Worker secret `PACKAGE_REACH_INGEST_TOKEN` and the GitHub Actions secret
   `PACKAGE_REACH_INGEST_TOKEN`. Do not reuse the Cloudflare API token.
8. Deploy:

   ```sh
   pnpm run deploy
   ```

The first traffic snapshot appears after the first successful scheduled Worker
refresh. Package reach is refreshed by `.github/workflows/package-reach.yml`
each day at 18:41 UTC, after the daily CRAN log is normally available, and can
also be run manually. Neither update requires a
Quarto render. Cron changes can take up to 15 minutes to propagate.

## Verification

After the first scheduled event, check:

```sh
curl -fsS https://gallery-analytics.gallery-analytics-worker.workers.dev/v1/summary
curl -fsS https://gallery-analytics.gallery-analytics-worker.workers.dev/v1/package-reach
```

Both responses must match schema version 1, contain no credential or
account/site identifier, and report either `current` or `stale`. Reconcile
traffic totals with Cloudflare and package counts with the named source windows.

## Rollback

Disable the Worker and revoke both Worker secrets. The Gallery remains
operational and its usage page falls back to unavailable messages. Removing the
browser beacon is a separate one-line Quarto change.
