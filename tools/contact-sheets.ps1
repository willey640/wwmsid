param([string]$OutputDirectory="$PSScriptRoot/../.review",[string]$SheetFolder='visual')
Add-Type -AssemblyName System.Drawing
$output=[IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force "$output/$SheetFolder" | Out-Null
$rows=@(Get-ChildItem "$output/thumbs" -Filter '*.json' | Sort-Object Name | ForEach-Object { Get-Content $_.FullName -Raw | ConvertFrom-Json } | Where-Object { Test-Path "$output/thumbs/$($_.id).jpg" })
for($offset=0;$offset -lt $rows.Count;$offset+=60){
  $canvas=[Drawing.Bitmap]::new(1200,1860);$g=[Drawing.Graphics]::FromImage($canvas);$g.Clear([Drawing.Color]::FromArgb(12,25,32));$font=[Drawing.Font]::new('Arial',11)
  for($slot=0;$slot -lt 60 -and ($offset+$slot) -lt $rows.Count;$slot++){
    $r=$rows[$offset+$slot];$x=($slot%5)*240;$y=[Math]::Floor($slot/5)*155
    $im=[Drawing.Image]::FromFile("$output/thumbs/$($r.id).jpg");$g.DrawImage($im,($x+(240-$im.Width)/2),$y,$im.Width,$im.Height);$im.Dispose()
    $g.FillRectangle([Drawing.Brushes]::Black,$x,($y+130),240,25);$g.DrawString("$($r.id) $($r.folder)",$font,[Drawing.Brushes]::White,$x+3,$y+132)
  }
  $g.Dispose();$font.Dispose();$name='sheet-{0:d2}.jpg' -f (1+$offset/60);$canvas.Save("$output/$SheetFolder/$name");$canvas.Dispose()
}
Write-Output "Generated sheets for $($rows.Count) decoded images."
