export function initPasswordToggles(){
  const eye=(off=false)=>off?'<svg class="h-5 w-5" aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 3l18 18"/><path d="M10.6 10.6a2 2 0 0 0 2.8 2.8"/><path d="M9.9 4.3A10.8 10.8 0 0 1 12 4c5.2 0 9.2 4 10 8-.3 1.4-1 2.7-2 3.9M6.2 6.2C4.4 7.5 3.2 9.3 2 12c.8 4 4.8 8 10 8 1.2 0 2.3-.2 3.3-.6"/></svg>':'<svg class="h-5 w-5" aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z"/><circle cx="12" cy="12" r="2.7"/></svg>';
  const toggle=(button:HTMLButtonElement)=>{const inputId=button.getAttribute('aria-controls');const input=inputId?document.getElementById(inputId) as HTMLInputElement|null:null;if(!input)return;const showing=input.type==='text';input.type=showing?'password':'text';button.setAttribute('aria-pressed',String(!showing));button.setAttribute('aria-label',showing?'Show password':'Hide password');button.innerHTML=eye(!showing);};
  const bind=(button:HTMLButtonElement)=>{if(button.dataset.passwordBound)return;button.dataset.passwordBound='true';button.addEventListener('click',()=>toggle(button));};
  const enhance=()=>document.querySelectorAll<HTMLInputElement>('input[type="password"]:not([data-password-enhanced])').forEach((input,index)=>{
    if(input.parentElement?.querySelector<HTMLButtonElement>('[data-password-toggle]')){const existing=input.parentElement.querySelector<HTMLButtonElement>('[data-password-toggle]')!; existing.innerHTML=eye(); existing.className='absolute right-2 top-1/2 -translate-y-1/2 rounded-lg p-2 text-slate-500 transition hover:bg-slate-100 hover:text-brand focus:outline-none focus:ring-2 focus:ring-brand/30'; bind(existing); input.dataset.passwordEnhanced='true';return;}
    input.dataset.passwordEnhanced='true';
    if(!input.id)input.id=`password-field-${index}`;
    const wrapper=document.createElement('span'); wrapper.className='relative block'; input.parentNode?.insertBefore(wrapper,input); wrapper.appendChild(input); input.classList.add('pr-12');
    const button=document.createElement('button'); button.type='button'; button.dataset.passwordToggle='true'; button.setAttribute('aria-controls',input.id); button.setAttribute('aria-label','Show password'); button.setAttribute('aria-pressed','false'); button.className='absolute right-2 top-1/2 -translate-y-1/2 rounded-lg p-2 text-slate-500 transition hover:bg-slate-100 hover:text-brand focus:outline-none focus:ring-2 focus:ring-brand/30'; button.innerHTML=eye(); wrapper.appendChild(button); bind(button);
  });
  enhance();
  setTimeout(enhance,0);
  new MutationObserver(enhance).observe(document.body,{childList:true,subtree:true});
}
