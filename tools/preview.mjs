import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
const root = process.cwd();
const types={'.html':'text/html; charset=utf-8','.css':'text/css','.js':'text/javascript','.json':'application/json','.jpg':'image/jpeg','.jpeg':'image/jpeg','.png':'image/png','.svg':'image/svg+xml','.webp':'image/webp','.ico':'image/x-icon','.mp4':'video/mp4'};
http.createServer((req,res)=>{
  const requested = decodeURIComponent(new URL(req.url,'http://localhost').pathname);
  const file = path.resolve(root,'.'+(requested==='/'?'/index.html':requested));
  if (!file.startsWith(root+path.sep) || /[\\/]\.(git|review)([\\/]|$)/.test(file)) {res.writeHead(403);return res.end();}
  fs.stat(file,(err,stat)=>{
    if(err||!stat.isFile()){res.writeHead(404);return res.end('Not found');}
    const headers={'Content-Type':types[path.extname(file).toLowerCase()]||'application/octet-stream','Cache-Control':'no-store','Accept-Ranges':'bytes'};
    const range=/^bytes=(\d+)-(\d*)$/.exec(req.headers.range||'');
    const start=range?Number(range[1]):0;
    const end=range&&range[2]?Math.min(Number(range[2]),stat.size-1):stat.size-1;
    if(start>end||start>=stat.size){res.writeHead(416,{'Content-Range':`bytes */${stat.size}`});return res.end();}
    headers['Content-Length']=end-start+1;
    if(range)headers['Content-Range']=`bytes ${start}-${end}/${stat.size}`;
    res.writeHead(range?206:200,headers);
    if(req.method==='HEAD')return res.end();
    fs.createReadStream(file,{start,end}).pipe(res);
  });
}).listen(4173,'127.0.0.1',()=>console.log('Local preview: http://127.0.0.1:4173'));
