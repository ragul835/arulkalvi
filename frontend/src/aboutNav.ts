export function initAboutNav(){
  const add=()=>{const nav=document.querySelector('header nav');if(!nav||nav.querySelector('[data-about-link]'))return;const link=document.createElement('a');link.href='/about';link.dataset.aboutLink='true';link.className='rounded-lg px-3 py-2 text-sm font-semibold text-slate-600 no-underline hover:bg-slate-100 hover:text-brand';link.textContent='About';nav.insertBefore(link,nav.firstChild)};
  add();new MutationObserver(add).observe(document.body,{childList:true,subtree:true});
}
