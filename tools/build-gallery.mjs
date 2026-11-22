import fs from 'node:fs';
const selection=JSON.parse(fs.readFileSync('media-selection.json','utf8'));
const rows=JSON.parse(fs.readFileSync('.review/inventory.json','utf8').replace(/^\uFEFF/,''));
const assets=JSON.parse(fs.readFileSync('.review/asset-sizes.json','utf8').replace(/^\uFEFF/,''));
const escape=s=>String(s).replaceAll('&','&amp;').replaceAll('"','&quot;').replaceAll('<','&lt;').replaceAll('>','&gt;');
function card(photo){
 const sizes=assets.filter(a=>a.id===photo.id);const large=sizes.find(a=>a.size===1600),small=sizes.find(a=>a.size===640);
 const srcset=[...new Map(sizes.map(a=>[a.width,`${a.url} ${a.width}w`])).values()].join(', ');
 const context=(photo.credit?`Photograph: ${photo.credit}. `:'')+'Names, location and date are unconfirmed.';
 return `<figure class="photo-card" data-category="${escape(photo.category)}"><a class="gallery-item" href="${large.url}" data-lightbox data-caption="${escape(photo.caption)}" data-context="${escape(context)}" aria-label="View photograph: ${escape(photo.caption)}"><img src="${small.url}" srcset="${srcset}" sizes="(max-width: 380px) 90vw, (max-width: 768px) 45vw, 31vw" width="${small.width}" height="${small.height}" alt="${escape(photo.caption)}" loading="lazy" decoding="async"></a><figcaption><span class="photo-category">${escape(photo.category)}</span><strong>${escape(photo.caption)}</strong>${photo.credit?`<span class="photo-credit">Photograph: ${escape(photo.credit)}</span>`:''}</figcaption></figure>`;
}
let gallery=fs.readFileSync('gallery.html','utf8');
gallery=gallery.replace(/<div class="gallery-grid" data-curated-gallery[^>]*>[\s\S]*?<\/div>/,`<div class="gallery-grid" data-curated-gallery data-lightbox-group="collection">${selection.map(card).join('\n')}</div>`);
let home=fs.readFileSync('index.html','utf8');
home=home.replace(/<div class="gallery-grid" data-curated-home[^>]*>[\s\S]*?<\/div>/,`<div class="gallery-grid" data-curated-home data-lightbox-group="featured">${selection.slice(0,6).map(card).join('\n')}</div>`);
// Existing image assets stay on disk; legacy gallery references use the optimized copies.
for(const file of ['gallery.html','index.html']){
 let html=file==='gallery.html'?gallery:home;
 for(const row of rows.filter(r=>r.folder==='Gallery')){
   const source=`Photos/Gallery/${row.filename}`;
   html=html.replaceAll(`href="${source}"`,`href="assets/photos/${row.id}-1600.jpg" data-lightbox data-caption="Original archive: ${escape(row.filename)}"`).replaceAll(`src="${source}"`,`src="assets/photos/${row.id}-640.jpg"`);
 }
 fs.writeFileSync(file,html);
}
// A review page includes all pre-existing gallery photographs, including files previously unlinked.
const archive=rows.filter(r=>r.folder==='Gallery').map(r=>({id:r.id,category:'Original website collection',caption:`Original archive · ${r.filename}`}));
gallery=fs.readFileSync('gallery.html','utf8');
const fullArchive=`<section class="content-section"><div class="section-inner legacy-gallery"><details id="original-collection"><summary>Browse every photograph from the original website collection</summary><p>Original filenames are retained here for reference. Names, locations and dates are unconfirmed.</p><div class="gallery-grid" data-lightbox-group="original">${archive.map(card).join('\n')}</div></details></div></section>`;
if(!gallery.includes('id="original-collection"'))gallery=gallery.replace('</main>',`${fullArchive}</main>`);
fs.writeFileSync('gallery.html',gallery);
fs.mkdirSync('docs',{recursive:true});
fs.writeFileSync('docs/photo-selection.csv','id,source_filename,category,caption,reason\n'+selection.map(p=>[p.id,rows.find(r=>r.id===p.id).filename,p.category,p.caption,p.reason].map(v=>'"'+v.replaceAll('"','""')+'"').join(',')).join('\n')+'\n');
console.log(`Rendered ${selection.length} selected photographs; preserved ${archive.length} original gallery photographs.`);
