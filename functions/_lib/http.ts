export const json=(data:unknown,status=200,headers:Record<string,string>={})=>new Response(JSON.stringify(data),{status,headers:{'content-type':'application/json; charset=utf-8','cache-control':'no-store',...headers}});
export const fail=(code:string,message:string,status=400)=>json({error:{code,message}},status);
export const cors=(r:Response)=>r;
