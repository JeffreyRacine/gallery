# Gallery analytics Worker

This Worker exposes a privacy-preserving, read-only usage summary for the
Gallery of Code. Cloudflare Web Analytics remains the data source; the Worker
publishes only validated aggregates cached in Workers KV.

Public summary endpoint:

```text
https://gallery-analytics.gallery-analytics-worker.workers.dev/v1/summary
```

## Safety contract

- The public API has one route: `GET /v1/summary`.
- The GraphQL query and its 7- and 30-day windows are fixed in source.
- Paths outside `/gallery/` and country/referrer counts below five are omitted.
- The API token is a Worker secret and must never enter this repository.
- A failed refresh leaves the last valid KV snapshot unchanged.
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

7. Deploy:

   ```sh
   pnpm run deploy
   ```

The first public snapshot appears after the first successful scheduled refresh.
Cron changes can take up to 15 minutes to propagate. Do not add a public refresh
route merely to accelerate the initial snapshot.

## Verification

After the first scheduled event, check:

```sh
curl -fsS https://gallery-analytics.gallery-analytics-worker.workers.dev/v1/summary
```

The response must match schema version 1, contain no credential or account/site
identifier, and report either `current` or `stale`. Reconcile its totals with the
Cloudflare dashboard over the same period before inserting the endpoint into
`gallery_usage.qmd`.

## Rollback

Disable the Worker and revoke `CF_ANALYTICS_API_TOKEN` in Cloudflare. The
Gallery remains operational and its usage page falls back to an unavailable
message. Removing the browser beacon is a separate one-line Quarto change.
