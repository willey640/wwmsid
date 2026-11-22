$ErrorActionPreference='Stop'
$root=[IO.Path]::GetFullPath("$PSScriptRoot/..")
$rows=Get-Content "$root/.review/inventory.json" -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force "$root/assets/videos" | Out-Null
foreach($id in @('m1267','m1264','m1266')){
 $r=$rows | Where-Object id -eq $id
 & ffmpeg -hide_banner -loglevel error -i $r.path -map 0:v:0 -map '0:a?' -vf 'scale=1280:-2' -c:v libx264 -preset medium -crf 29 -maxrate 1000k -bufsize 2000k -threads 2 -c:a aac -b:a 64k -map_metadata -1 -movflags +faststart -y "$root/assets/videos/$id.mp4"
 if($LASTEXITCODE -ne 0){throw "Video conversion failed: $id"}
 & ffmpeg -hide_banner -loglevel error -ss 2 -i $r.path -frames:v 1 -vf 'scale=960:-2' -y "$root/assets/videos/$id.jpg"
}
Get-ChildItem "$root/assets/videos" | Select-Object Name,Length | Format-Table
