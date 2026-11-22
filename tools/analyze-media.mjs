import fs from 'node:fs';
const rows=JSON.parse(fs.readFileSync('.review/inventory.json','utf8').replace(/^\uFEFF/,''));
const selected=JSON.parse(fs.readFileSync('media-selection.json','utf8'));
const manual={m1040:'Visible motion blur; exclude from website shortlist.',m1437:'Fish is visibly motion blurred; nearby frames offer alternatives.',m1420:'Bright fish detail is clipped; use a better exposed alternative.',m1698:'Profile screenshot includes personal information; exclude from public assets.',m1687:'Card with personal details; exclude from public assets.',m1608:'Social-media screenshot; use original media instead.',m1699:'Webpage screenshot; avoid as a feature photograph.'};
for(const r of rows){
 if(r.type==='image')r.visual_review='screened on contact sheet; shortlisted exports also inspected at larger size';
 const p=selected.find(p=>p.id===r.id);
 if(p){r.category=p.category;r.category_basis='visual editorial selection; names, event and location unconfirmed';r.visual_notes=p.reason;r.selected=true;}
 else {
  r.selected=false;
  r.category=r.path.includes('Garbage dive against debris')?'Lionfish Hunting and Conservation':r.path.includes('done to be id')?'Marine Life and Underwater Photography':'My Diving Career';
  r.category_basis='provisional source-folder grouping; not a confirmed subject, location or event';
 }
 if(manual[r.id])r.visual_notes=manual[r.id];
}
const images=rows.filter(r=>r.dhash);const pairs=[];
const hashes=new Map();
for(const row of rows.filter(r=>r.sha256)){if(!hashes.has(row.sha256))hashes.set(row.sha256,[]);hashes.get(row.sha256).push(row);}
const exact=[...hashes].filter(([,group])=>group.length>1);
fs.writeFileSync('.review/exact-duplicates.csv','hash,ids,count\n'+exact.map(([hash,group])=>`"${hash}","${group.map(r=>r.id).join(', ')}",${group.length}`).join('\n')+'\n');
const split=images.map(r=>[parseInt(r.dhash.slice(0,32),2)>>>0,parseInt(r.dhash.slice(32),2)>>>0]);
function pop(v){v=v-((v>>>1)&0x55555555);v=(v&0x33333333)+((v>>>2)&0x33333333);return (((v+(v>>>4))&0x0f0f0f0f)*0x01010101)>>>24;}
for(let i=0;i<images.length;i++)for(let j=i+1;j<images.length;j++){
 if(images[i].sha256===images[j].sha256)continue;
 const distance=pop(split[i][0]^split[j][0])+pop(split[i][1]^split[j][1]);
 if(distance<=4)pairs.push({first:images[i].id,second:images[j].id,hamming_distance:distance,status:'machine candidate only; similar reef subjects can be false positives'});
}
fs.writeFileSync('.review/near-duplicates.json',JSON.stringify(pairs,null,2));
fs.writeFileSync('.review/inventory.json',JSON.stringify(rows,null,2));
const columns=[...new Set(rows.flatMap(r=>Object.keys(r)))];
fs.writeFileSync('.review/inventory.csv',columns.join(',')+'\n'+rows.map(r=>columns.map(c=>'"'+String(r[c]??'').replaceAll('"','""')+'"').join(',')).join('\n')+'\n');
const oneDrive=rows.filter(r=>r.path.includes('OneDrive'));
const summary={oneDriveFiles:oneDrive.length,oneDriveImages:oneDrive.filter(r=>r.type==='image').length,oneDriveVideos:oneDrive.filter(r=>r.type==='video').length,existingGalleryImages:rows.length-oneDrive.length,failed:rows.filter(r=>r.status==='failed').map(r=>({id:r.id,filename:r.filename,error:r.error})),selected:selected.length,exactDuplicateGroups:exact.length,lowResolutionCandidates:oneDrive.filter(r=>r.quality_flag?.startsWith('small')).length,lowEdgeDetailCandidates:oneDrive.filter(r=>r.quality_flag?.startsWith('low')).length,nearDuplicateCandidatePairs:pairs.length,oneDriveTotalBytes:oneDrive.reduce((n,r)=>n+r.bytes,0)};
fs.writeFileSync('.review/summary.json',JSON.stringify(summary,null,2));
console.log(JSON.stringify(summary,null,2));
