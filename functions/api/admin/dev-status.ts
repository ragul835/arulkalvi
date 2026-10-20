import {json} from '../../_lib/http'; import type {Ctx} from '../../_lib/types';
export const onRequestGet=({env}:Ctx)=>json({enabled:env.APP_ENV==='development'&&env.DEV_AUTH_BYPASS==='true'});
