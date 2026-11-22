(() => {
  const menu = document.getElementById('hamburger');
  const nav = document.getElementById('nav-links');
  function closeMenu() { nav?.classList.remove('active'); menu?.setAttribute('aria-expanded','false'); }
  menu?.addEventListener('click', () => {
    const expanded = nav.classList.toggle('active');
    menu.setAttribute('aria-expanded',String(expanded));
  });
  nav?.addEventListener('click',event=>{if(event.target.closest('a'))closeMenu();});
  document.addEventListener('keydown',event=>{if(event.key==='Escape' && menu?.getAttribute('aria-expanded')==='true'){closeMenu();menu.focus();}});
  window.matchMedia('(min-width: 769px)').addEventListener('change',closeMenu);
  const grid=document.querySelector('[data-curated-gallery]');
  const bar=document.querySelector('[data-gallery-filters]');
  const summary=document.querySelector('[data-gallery-summary]');
  if(grid && bar) {
    const cards=[...grid.querySelectorAll('[data-category]')];
    const categories=['All photographs',...new Set(cards.map(card=>card.dataset.category))];
    function filter(category) {
      let count=0;
      cards.forEach(card=>{card.hidden=category!=='All photographs' && card.dataset.category!==category;if(!card.hidden)count++;});
      bar.querySelectorAll('button').forEach(button=>button.setAttribute('aria-pressed',String(button.textContent===category)));
      summary.textContent=`${count} ${count===1?'photograph':'photographs'} · ${category}`;
    }
    for(const category of categories) {
      const button=document.createElement('button');button.type='button';button.textContent=category;
      button.addEventListener('click',()=>filter(category));bar.append(button);
    }
    filter('All photographs');
  }
  const photoLinks=[...document.querySelectorAll('a[data-lightbox]')];
  if(!photoLinks.length || typeof HTMLDialogElement==='undefined')return;
  const dialog=document.createElement('dialog');dialog.className='lightbox';dialog.setAttribute('aria-label','Photograph viewer');
  dialog.innerHTML='<div class="lightbox-toolbar"><span data-photo-count></span><div class="lightbox-controls"><button type="button" data-prev aria-label="Previous photograph">Previous</button><button type="button" data-next aria-label="Next photograph">Next</button><button type="button" data-close aria-label="Close photograph viewer">Close</button></div></div><img class="lightbox-image" alt=""><p class="lightbox-caption"></p><p class="lightbox-meta"></p>';
  document.body.append(dialog);
  const image=dialog.querySelector('img');const caption=dialog.querySelector('.lightbox-caption');const meta=dialog.querySelector('.lightbox-meta');
  let active=[];let position=0;let opener;let previousOverflow='';
  function show(index) {
    position=(index+active.length)%active.length;const link=active[position];
    image.src=link.href;image.alt=link.querySelector('img')?.alt||link.dataset.caption||'Diving photograph';
    caption.textContent=link.dataset.caption||image.alt;meta.textContent=link.dataset.context||'Names, date and location are not confirmed.';
    dialog.querySelector('[data-photo-count]').textContent=`${position+1} / ${active.length}`;
  }
  for(const link of photoLinks)link.addEventListener('click',event=>{
    if(event.ctrlKey||event.metaKey||event.shiftKey||event.altKey)return;
    event.preventDefault();opener=link;
    active=photoLinks.filter(item=>!item.closest('[hidden]') && item.closest('[data-lightbox-group]')===link.closest('[data-lightbox-group]'));
    show(active.indexOf(link));previousOverflow=document.body.style.overflow;document.body.style.overflow='hidden';dialog.showModal();dialog.querySelector('[data-close]').focus();
  });
  dialog.querySelector('[data-prev]').addEventListener('click',()=>show(position-1));
  dialog.querySelector('[data-next]').addEventListener('click',()=>show(position+1));
  dialog.querySelector('[data-close]').addEventListener('click',()=>dialog.close());
  dialog.addEventListener('keydown',event=>{
    if(event.key==='ArrowLeft'){event.preventDefault();show(position-1);}
    if(event.key==='ArrowRight'){event.preventDefault();show(position+1);}
    if(event.key==='Tab'){
      const buttons=[...dialog.querySelectorAll('button')];const first=buttons[0],last=buttons[buttons.length-1];
      if(event.shiftKey&&document.activeElement===first){event.preventDefault();last.focus();}
      else if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first.focus();}
    }
  });
  dialog.addEventListener('click',event=>{if(event.target===dialog){const box=dialog.getBoundingClientRect();if(event.clientX<box.left||event.clientX>box.right||event.clientY<box.top||event.clientY>box.bottom)dialog.close();}});
  dialog.addEventListener('close',()=>{document.body.style.overflow=previousOverflow;image.removeAttribute('src');opener?.focus();});
})();
