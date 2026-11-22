// Creates a reviewable, static GitHub Pages artifact. Does not deploy or push.
import fs from 'node:fs';
import path from 'node:path';
const output=path.resolve('.review/pages');
fs.mkdirSync(output,{recursive:true});
for(const file of fs.readdirSync('.').filter(file=>/\.(html|css|js|ico)$/.test(file)||['CNAME','robots.txt','sitemap.xml'].includes(file)))fs.copyFileSync(file,path.join(output,file));
fs.cpSync('assets',path.join(output,'assets'),{recursive:true});
// Every original asset is preserved for any historic direct URL.
fs.cpSync('Photos',path.join(output,'Photos'),{recursive:true});
fs.copyFileSync('circle_logo.png',path.join(output,'circle_logo.png'));
fs.writeFileSync(path.join(output,'.nojekyll'),'');
console.log(`GitHub Pages review artifact: ${output}. No publication performed.`);
