declare interface R2Object { body: ReadableStream; writeHttpMetadata(headers:Headers):void; }
declare interface R2Bucket { get(key:string):Promise<R2Object|null>; put(key:string,value:ArrayBuffer,options?:unknown):Promise<unknown>; delete(key:string):Promise<boolean>; }
