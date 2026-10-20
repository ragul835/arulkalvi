import type {Env} from './types';
export const maxSize=(env:Env)=>Number(env.MAX_FILE_SIZE||20*1024*1024);
export async function readPdf(file:File,limit:number){if(file.size<=0||file.size>limit) throw new Error('PDF must be non-empty and no larger than 20 MB'); const buf=await file.arrayBuffer(); const bytes=new Uint8Array(buf); const sig=new TextDecoder().decode(bytes.slice(0,5)); if(sig!=='%PDF-') throw new Error('File signature is not a PDF'); const text=new TextDecoder('latin1').decode(bytes.slice(Math.max(0,bytes.length-2048))); if(!text.includes('%%EOF')) throw new Error('Invalid PDF structure'); return buf;}
export const keyFor=(slug:string)=>`pdfs/${crypto.randomUUID()}-${slug}.pdf`;
