export type PublicDocument = { id:string; title:string; slug:string; description:string|null; class_name:string; subject:string; academic_year:string; file_size:number; download_count?:number; created_at:string; updated_at:string; };
export type AdminDocument = PublicDocument & { storage_key:string; is_published:boolean; };
export type ApiError = { error:{ code:string; message:string } };
