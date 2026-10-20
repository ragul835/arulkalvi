# Deployment and handover checklist

1. Create a Supabase project, disable public Auth signups, create one admin user, and record its UUID.
2. Run `migrations/001_initial.sql`; verify anonymous `select/insert/update/delete` on `documents` is denied.
3. Create a private R2 bucket. Do not enable its development URL or a custom public bucket domain.
4. Create a Cloudflare Pages project connected to this repository, build command `npm run build`, output directory `dist`, and add the `R2_BUCKET` binding.
5. Add Pages secrets `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `ADMIN_USER_ID`, `SITE_URL`; set `MAX_FILE_SIZE=20971520`.
6. Attach the custom domain and HTTPS in Pages. Verify `/`, `/pdf/<published-slug>`, `/sitemap.xml`, and `/robots.txt`.
7. Run smoke tests: anonymous list/detail/download, draft isolation, wrong-admin rejection, oversized upload rejection, publish/unpublish, and delete retry path.

## Admin password recovery

Configure Supabase Auth email delivery (custom SMTP is recommended for production), ensure the email template includes the six-digit `{{ .Token }}`, and set `ADMIN_EMAIL` to the sole administrator address. The recovery page is `/admin/forgot-password`; it sends a one-time code through Supabase Auth, verifies it server-side, checks the verified user ID against `ADMIN_USER_ID`, and updates the password through the server-only service role. Supabase Auth throttling applies; add edge rate limiting or CAPTCHA if needed.

To replace the admin, create the new Auth user, update `ADMIN_USER_ID`, then disable/delete the former user. To roll back, redeploy the previous Pages deployment and restore the matching SQL/R2 backup. Inspect Pages Functions logs and Supabase Auth/database logs after each release.

There is no deployed URL in this workspace because Cloudflare and Supabase credentials, project IDs, domain, and initial PDF content were not supplied. The repository is ready for the authorized deployment step.
