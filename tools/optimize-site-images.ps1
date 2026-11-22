$ErrorActionPreference='Stop';Add-Type -AssemblyName System.Drawing
$root=[IO.Path]::GetFullPath("$PSScriptRoot/..")
New-Item -ItemType Directory -Force "$root/assets/site" | Out-Null
$pages=Get-ChildItem $root -Filter '*.html'
$sources=@($pages | ForEach-Object { $h=Get-Content $_.FullName -Raw; [regex]::Matches($h,'<img[^>]+src="(Photos/[^">]+)"') | ForEach-Object { $_.Groups[1].Value } } | Sort-Object -Unique)
$encoder=[Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
$q=[Drawing.Imaging.EncoderParameters]::new(1);$q.Param[0]=[Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality,[long]82)
$mapping=@()
foreach($source in $sources){
 $im=[Drawing.Image]::FromFile("$root/$source")
 try {
  $ratio=[Math]::Min(1.0,800.0/$im.Width);$w=[Math]::Max(1,[int]($im.Width*$ratio));$h=[Math]::Max(1,[int]($im.Height*$ratio))
  $bmp=[Drawing.Bitmap]::new($w,$h);$g=[Drawing.Graphics]::FromImage($bmp);$g.Clear([Drawing.Color]::White);$g.InterpolationMode='HighQualityBicubic';$g.DrawImage($im,0,0,$w,$h);$g.Dispose()
  $name=([IO.Path]::GetFileNameWithoutExtension($source).ToLowerInvariant() -replace '[^a-z0-9]+','-')+'.jpg';$dest="assets/site/$name"
  $bmp.Save("$root/$dest",$encoder,$q);$bmp.Dispose()
  $mapping += [pscustomobject]@{source=$source;url=$dest;width=$w;height=$h;bytes=(Get-Item "$root/$dest").Length}
 }finally{$im.Dispose()}
}
foreach($page in $pages){
 $html=Get-Content $page.FullName -Raw
 foreach($m in $mapping){$html=$html.Replace("src=`"$($m.source)`"","src=`"$($m.url)`" width=`"$($m.width)`" height=`"$($m.height)`"")}
 [IO.File]::WriteAllText($page.FullName,$html)
}
$mapping | ConvertTo-Json | Set-Content "$root/.review/site-image-sizes.json"
Write-Output "Optimized $($mapping.Count) existing site images."
