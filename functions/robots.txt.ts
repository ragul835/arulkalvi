export const onRequestGet=({env}:any)=>new Response(`User-agent: *\nAllow: /\nSitemap: ${(env.SITE_URL||'https://example.com')}/sitemap.xml`,{headers:{'content-type':'text/plain'}});
