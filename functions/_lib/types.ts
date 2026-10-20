export type Env = { SUPABASE_URL:string; SUPABASE_SERVICE_ROLE_KEY:string; SUPABASE_ANON_KEY:string; ADMIN_USER_ID:string; ADMIN_EMAIL?:string; R2_BUCKET:R2Bucket; MAX_FILE_SIZE?:string; SITE_URL?:string; APP_ENV?:string; DEV_AUTH_BYPASS?:string };
export type Ctx = { request:Request; env:Env; params:Record<string,string|undefined> };
