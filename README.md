# ArulKalvi educational PDF library

Production-oriented MVP using React/Vite/TypeScript, Cloudflare Pages Functions, Supabase PostgreSQL/Auth, and a private R2 bucket.

## Local setup
1. `npm install`
2. Apply `migrations/001_initial.sql` in Supabase SQL editor.
3. Apply `migrations/002_updates.sql` for news, recent updates, and exam tips.
4. Apply `migrations/003_contact_messages.sql` for private contact submissions.
5. Apply `migrations/004_contact_phone.sql` to require phone numbers on contact submissions.
6. Apply `migrations/005_view_counts.sql` to enable server-controlled PDF view counts.
7. Create the sole admin user in Supabase Auth (disable public signups) and set its UUID as `ADMIN_USER_ID`.
4. Configure `.env.example` values as Pages/Functions secrets; never expose the service-role key to the browser.
5. `npm run dev` or `npm run build`.

For an interactive project manager, run `./manage.sh`. Option `1` builds the project; option `13` performs a clean rebuild; options `2`–`5` start/stop the frontend and backend separately; options `6`–`7` control production preview; options `8`–`11` manage/check Supabase; option `12` pulls fast-forward-only Git changes; `0` exits. The database reset option requires typing `RESET DATABASE`. The frontend runs on port `5173`; Pages Functions backend runs on port `8788`.

### Local development login

For local development only, copy `.dev.vars.example` to `.dev.vars`. With `APP_ENV=development` and `DEV_AUTH_BYPASS=true`, the development login is `admin@arulkalvi.com` / `Admin@123`. This bypass is explicitly rejected unless both development flags are enabled; never set it in Cloudflare production secrets. Production must use the pre-created Supabase Auth administrator.

Admin password recovery is available at `/admin/forgot-password`. Configure production SMTP and a Supabase email template containing `{{ .Token }}` so the administrator receives a six-digit OTP.

Cloudflare Pages uses `dist` as build output and the R2 binding in `wrangler.toml`. Set secrets with `wrangler pages secret put`; do not enable the R2 public development URL or a bucket domain.

Provider references checked 2026-10-20: [Pages Functions bindings](https://developers.cloudflare.com/pages/functions/bindings/), [Pages Functions](https://developers.cloudflare.com/pages/functions/get-started/), [R2 pricing](https://developers.cloudflare.com/r2/pricing/), and [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security). Pricing, quotas, and key naming can change, so record the current dashboard values during deployment.

## Backups and recovery
Export PostgreSQL metadata nightly to encrypted object storage (30-day retention) and take an R2 object inventory plus versioned copy weekly (90-day retention). Restore SQL into staging, restore R2 keys, run a test download, then switch bindings. Backup storage/egress may incur charges. Test restore quarterly.

## Scope
`npm test` runs unit tests. Excludes visitor accounts, bulk uploads, OCR/full-text PDF content search, comments, payments, ads, and large-library migration. Verify current Cloudflare and Supabase pricing/limits at deployment.
