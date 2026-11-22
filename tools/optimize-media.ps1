param([string]$Inventory="$PSScriptRoot/../.review/inventory.json")
$ErrorActionPreference='Stop';Add-Type -AssemblyName System.Drawing
$root=[IO.Path]::GetFullPath("$PSScriptRoot/..")
$rows=Get-Content $Inventory -Raw | ConvertFrom-Json
$selection=Get-Content "$root/media-selection.json" -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force "$root/assets/photos", "$root/.review/selected" | Out-Null
$encoder=[Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
$quality=[Drawing.Imaging.EncoderParameters]::new(1);$quality.Param[0]=[Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality,[long]82)
$ids=@($selection.id)+@($rows | Where-Object folder -eq Gallery | ForEach-Object id)
$assets=@()
foreach($id in ($ids | Select-Object -Unique)){
 $r=$rows | Where-Object id -eq $id
 $im=[Drawing.Image]::FromFile($r.path)
 try {
  $orientation=$im.PropertyItems | Where-Object Id -eq 274 | Select-Object -First 1
  if($orientation){$rot=@{2=4;3=2;4=6;5=5;6=1;7=7;8=3};$o=[BitConverter]::ToUInt16($orientation.Value,0);if($rot.ContainsKey([int]$o)){$im.RotateFlip([Drawing.RotateFlipType]$rot[[int]$o])}}
  foreach($size in @(640,960,1600)){
   $ratio=[Math]::Min(1.0,$size/[double]$im.Width);$w=[Math]::Max(1,[int]($im.Width*$ratio));$h=[Math]::Max(1,[int]($im.Height*$ratio))
   $bmp=[Drawing.Bitmap]::new($w,$h);$g=[Drawing.Graphics]::FromImage($bmp);$g.InterpolationMode='HighQualityBicubic';$g.DrawImage($im,0,0,$w,$h);$g.Dispose()
   $dest="$root/assets/photos/$id-$size.jpg";$bmp.Save($dest,$encoder,$quality);$bmp.Dispose()
   $assets += [pscustomobject]@{id=$id;size=$size;width=$w;height=$h;url="assets/photos/$id-$size.jpg";bytes=(Get-Item $dest).Length}
  }
 }finally{$im.Dispose()}
}
$hero=$selection | Where-Object hero | Select-Object -First 1
Copy-Item "$root/assets/photos/$($hero.id)-1600.jpg" "$root/assets/photos/hero-1600.jpg"
$assets | ConvertTo-Json | Set-Content "$root/.review/asset-sizes.json"
Write-Output "Exported $($assets.Count) JPEG derivatives; no original was changed."
