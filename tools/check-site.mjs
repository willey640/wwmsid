import fs from 'node:fs';
import path from 'node:path';
const root = process.cwd();
const pages = fs.readdirSync(root).filter(f => f.endsWith('.html'));
const failures = [];
const external = new Set();
function exactFile(relative) {
  let dir = root;
  for (const part of relative.split('/').filter(Boolean)) {
    if (!fs.existsSync(dir) || !fs.readdirSync(dir).includes(part)) return false;
    dir = path.join(dir, part);
  }
  return fs.existsSync(dir);
}
for (const page of pages) {
  const html = fs.readFileSync(page, 'utf8');
  const ids=[...html.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]);
  for(const id of new Set(ids))if(ids.filter(other=>other===id).length>1)failures.push(`${page}: duplicate id: ${id}`);
  if((html.match(/<h1\b/g)||[]).length!==1)failures.push(`${page}: expected one primary heading`);
  if(html.includes('yourdomain.com') || /src="[^"]*VIDEO_ID_/.test(html))failures.push(`${page}: active placeholder URL`);
  for(const set of html.matchAll(/srcset="([^"]+)"/g))for(const src of set[1].split(',')){
    const file=src.trim().split(/\s+/)[0];if(!exactFile(file))failures.push(`${page}: missing responsive image: ${file}`);
  }
  for (const match of html.matchAll(/(?:href|src|poster)="([^"]+)"/g)) {
    const url = match[1];
    if (/^https?:/.test(url)) { external.add(url); continue; }
    if (/^(data:|mailto:|tel:)/.test(url)) continue;
    const [file, fragment] = decodeURIComponent(url).split('#');
    const target = file || page;
    if (!exactFile(target)) failures.push(`${page}: missing or wrong case: ${url}`);
    else if (fragment && target.endsWith('.html') && !fs.readFileSync(target,'utf8').includes(`id="${fragment}"`)) failures.push(`${page}: missing anchor: ${url}`);
  }
}
for (const match of fs.readFileSync('styles.css','utf8').matchAll(/url\(["']?([^"')]+)["']?\)/g)) {
  if (!exactFile(match[1])) failures.push(`styles.css: missing asset: ${match[1]}`);
}
if (process.argv.includes('--external')) {
  const rows = await Promise.all([...external].map(async url => {
    try { const r = await fetch(url,{signal:AbortSignal.timeout(15000),redirect:'follow'}); await r.body?.cancel(); return {url,status:r.status,final:r.url}; }
    catch(e) { return {url,status:'unverified',error:e.message}; }
  }));
  fs.mkdirSync('.review',{recursive:true}); fs.writeFileSync('.review/external-links.json',JSON.stringify(rows,null,2));
  console.log(`Recorded ${rows.length} external checks (HTTP success does not verify product availability or form delivery).`);
}
console.log(`${pages.length} pages checked; ${failures.length} internal reference problems.`);
for (const failure of failures) console.log(failure);
process.exitCode = failures.length ? 1 : 0;
