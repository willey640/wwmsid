param([string]$OutputDirectory="$PSScriptRoot/../.review")
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$output=[IO.Path]::GetFullPath($OutputDirectory)
$rows=Get-Content "$output/inventory.json" -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force "$output/metadata", "$output/video-frames" | Out-Null
foreach($row in $rows){
  if($row.type -eq 'image'){
    $im=[Drawing.Image]::FromFile($row.path)
    try { @($im.PropertyItems | ForEach-Object { @{tag=$_.Id;type=$_.Type;value_base64=[Convert]::ToBase64String($_.Value)} }) | ConvertTo-Json -Depth 6 | Set-Content "$output/metadata/$($row.id)-exif.json" } finally { $im.Dispose() }
  } else {
    try {
      $probe=& ffprobe -v fatal -show_format -show_streams -of json $row.path 2> "$output/metadata/$($row.id)-probe.log"
      if($LASTEXITCODE -ne 0){throw 'ffprobe failed; see probe log'}
      $raw=$probe -join "`n";$raw | Set-Content "$output/metadata/$($row.id)-video.json";$meta=$raw | ConvertFrom-Json
      $stream=$meta.streams | Where-Object codec_type -eq video | Select-Object -First 1
      $row.width=$stream.width;$row.height=$stream.height;$row.duration_seconds=$meta.format.duration;$row.captured_exif=$meta.format.tags.creation_time
      $row.sha256=(Get-FileHash -LiteralPath $row.path -Algorithm SHA256).Hash
      $row.status='metadata read; sampled frames generated';$row.error=$null
      for($i=0;$i -lt 4;$i++){
        $seconds=([double]$row.duration_seconds)*($i+.2)/4
        & ffmpeg -hide_banner -loglevel fatal -ss $seconds.ToString([Globalization.CultureInfo]::InvariantCulture) -i $row.path -frames:v 1 -vf 'scale=320:-2' -y "$output/video-frames/$($row.id)-$i.jpg" 2> "$output/metadata/$($row.id)-frames.log"
      }
    } catch {$row.status='failed';$row.error=$_.Exception.Message}
  }
}
$rows | ConvertTo-Json -Depth 8 | Set-Content "$output/inventory.json"
$rows | Export-Csv "$output/inventory.csv" -NoTypeInformation
Write-Output "Metadata enriched; $(@($rows | Where-Object status -eq failed).Count) failed. Video frames: $(@(Get-ChildItem "$output/video-frames" -Filter '*.jpg').Count)."
