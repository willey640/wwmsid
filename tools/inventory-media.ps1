param([string]$OutputDirectory = "$PSScriptRoot/../.review")
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$output = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force "$output/thumbs", "$output/sheets" | Out-Null
$pictures = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'OneDrive/Pictures'
$roots = @(
  (Join-Path $pictures 'done to be id'),
  (Join-Path $pictures 'Garbage dive against debris'),
  (Join-Path $pictures 'Scuba'),
  "$PSScriptRoot/../Photos/Gallery"
)
$files = @($roots | ForEach-Object { Get-ChildItem -LiteralPath $_ -Recurse -File } | Sort-Object FullName)
$tasks = for ($i = 0; $i -lt $files.Count; $i++) { @{ Index = $i + 1; Path = $files[$i].FullName } }
$ffprobe = (Get-Command ffprobe).Source
$rows = $tasks | ForEach-Object -ThrottleLimit 6 -Parallel {
  Add-Type -AssemblyName System.Drawing
  $task = $_; $file = Get-Item -LiteralPath $task.Path
  $id = 'm{0:d4}' -f $task.Index
  $row = [ordered]@{ id=$id; path=$file.FullName; filename=$file.Name; folder=$file.Directory.Name; bytes=$file.Length; created_utc=$file.CreationTimeUtc.ToString('o'); modified_utc=$file.LastWriteTimeUtc.ToString('o'); original_attributes=[string]$file.Attributes; type='image'; width=$null; height=$null; captured_exif=$null; camera=$null; duration_seconds=$null; sha256=$null; dhash=$null; edge_score=$null; quality_flag=$null; status='unopened'; error=$null; visual_review='not reviewed'; category='Unclassified'; category_basis='none' }
  try {
    if ($file.Extension.ToLowerInvariant() -in @('.mov','.mp4','.avi','.m4v')) {
      $row.type='video'
      $probe = & $using:ffprobe -v fatal -show_format -show_streams -of json $file.FullName 2> "$using:output/thumbs/$id-probe.log"
      if ($LASTEXITCODE -ne 0) { throw ($probe -join ' ') }
      $meta = ($probe -join '') | ConvertFrom-Json
      $stream = $meta.streams | Where-Object codec_type -eq 'video' | Select-Object -First 1
      $row.width=$stream.width; $row.height=$stream.height; $row.duration_seconds=$meta.format.duration
      $row.captured_exif=$meta.format.tags.creation_time
      $row.sha256=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
      $row.status='metadata read; video not visually reviewed'
    } else {
      $im=[Drawing.Image]::FromFile($file.FullName)
      try {
        $row.width=$im.Width; $row.height=$im.Height
        foreach ($prop in $im.PropertyItems) {
          if ($prop.Id -eq 36867) { $row.captured_exif=[Text.Encoding]::ASCII.GetString($prop.Value).Trim([char]0) }
          if ($prop.Id -eq 272) { $row.camera=[Text.Encoding]::ASCII.GetString($prop.Value).Trim([char]0) }
        }
        $orientation = $im.PropertyItems | Where-Object Id -eq 274 | Select-Object -First 1
        if ($orientation) {
          $rotations=@{2=4;3=2;4=6;5=5;6=1;7=7;8=3}
          $orient=[BitConverter]::ToUInt16($orientation.Value,0)
          if ($rotations.ContainsKey([int]$orient)) { $im.RotateFlip([Drawing.RotateFlipType]$rotations[[int]$orient]) }
        }
        $ratio=[Math]::Min(220.0/$im.Width,155.0/$im.Height)
        $thumb=New-Object Drawing.Bitmap ([int]($im.Width*$ratio)),([int]($im.Height*$ratio))
        $g=[Drawing.Graphics]::FromImage($thumb); $g.InterpolationMode='HighQualityBicubic'; $g.DrawImage($im,0,0,$thumb.Width,$thumb.Height); $g.Dispose()
        $thumb.Save("$using:output/thumbs/$id.jpg",[Drawing.Imaging.ImageFormat]::Jpeg); $thumb.Dispose()
        $small=New-Object Drawing.Bitmap 9,8; $g=[Drawing.Graphics]::FromImage($small); $g.DrawImage($im,0,0,9,8); $g.Dispose()
        $bits=''; $edge=0
        for($y=0;$y -lt 8;$y++){ for($x=0;$x -lt 8;$x++) { $a=$small.GetPixel($x,$y);$b=$small.GetPixel($x+1,$y);$av=($a.R+$a.G+$a.B)/3;$bv=($b.R+$b.G+$b.B)/3;$bits += [int]($av -gt $bv);$edge += [Math]::Abs($av-$bv) } }
        $small.Dispose(); $row.dhash=$bits; $row.edge_score=[Math]::Round($edge/64,2)
        if ([Math]::Max($im.Width,$im.Height) -lt 1000) { $row.quality_flag='small source; thumbnail or small display only' }
        elseif ($row.edge_score -lt 5) { $row.quality_flag='low edge detail; visual blur review required' }
      } finally { $im.Dispose() }
      $row.sha256=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
      $row.status='decoded; contact sheet generated'
    }
  } catch { $row.status='failed'; $row.error=$_.Exception.Message }
  [pscustomobject]$row | ConvertTo-Json -Compress | Set-Content -LiteralPath "$using:output/thumbs/$id.json" -Encoding utf8
  [pscustomobject]$row
}
$rows=@($rows | Sort-Object id)
$rows | ConvertTo-Json -Depth 8 | Set-Content "$output/inventory.json" -Encoding utf8
$rows | Export-Csv "$output/inventory.csv" -NoTypeInformation -Encoding utf8
$duplicates=@($rows | Where-Object sha256 | Group-Object sha256 | Where-Object Count -gt 1 | ForEach-Object { [pscustomobject]@{hash=$_.Name;ids=($_.Group.id -join ', ');count=$_.Count} })
$duplicates | Export-Csv "$output/exact-duplicates.csv" -NoTypeInformation
$images=@($rows | Where-Object { Test-Path "$output/thumbs/$($_.id).jpg" })
for($offset=0;$offset -lt $images.Count;$offset+=60) {
  $canvas=New-Object Drawing.Bitmap 1200,1860; $g=[Drawing.Graphics]::FromImage($canvas); $g.Clear([Drawing.Color]::FromArgb(12,25,32)); $font=New-Object Drawing.Font 'Arial',11
  for($slot=0;$slot -lt 60 -and ($offset+$slot) -lt $images.Count;$slot++) {
    $row=$images[$offset+$slot]; $x=($slot%5)*240; $y=[Math]::Floor($slot/5)*155
    $im=[Drawing.Image]::FromFile("$output/thumbs/$($row.id).jpg"); $g.DrawImage($im,($x+(240-$im.Width)/2),$y,$im.Width,$im.Height); $im.Dispose()
    $g.FillRectangle([Drawing.Brushes]::Black,$x,($y+130),240,25); $label="$($row.id) $($row.filename)"; if($label.Length -gt 31){$label=$label.Substring(0,31)}
    $g.DrawString($label,$font,[Drawing.Brushes]::White,$x+3,$y+132)
  }
  $g.Dispose();$font.Dispose();$sheet='sheet-{0:d2}.jpg' -f (1+$offset/60); $canvas.Save("$output/sheets/$sheet",[Drawing.Imaging.ImageFormat]::Jpeg);$canvas.Dispose()
}
Write-Output "Inventoried $($rows.Count) files; decoded $($images.Count) images; exact duplicate groups: $($duplicates.Count); failed: $(@($rows | Where-Object status -eq failed).Count)"
