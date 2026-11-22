Add-Type -AssemblyName System.Drawing
$root=[IO.Path]::GetFullPath("$PSScriptRoot/..")
$selection=Get-Content "$root/media-selection.json" -Raw | ConvertFrom-Json
$encoder=[Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
for($offset=0;$offset -lt $selection.Count;$offset+=12){
 $canvas=[Drawing.Bitmap]::new(1440,1600);$g=[Drawing.Graphics]::FromImage($canvas);$g.Clear([Drawing.Color]::FromArgb(8,30,41));$font=[Drawing.Font]::new('Arial',13)
 for($i=0;$i -lt 12 -and ($offset+$i) -lt $selection.Count;$i++){
  $p=$selection[$offset+$i];$im=[Drawing.Image]::FromFile("$root/assets/photos/$($p.id)-960.jpg")
  $x=($i%3)*480;$y=[Math]::Floor($i/3)*400;$ratio=[Math]::Min(460.0/$im.Width,345.0/$im.Height)
  $g.DrawImage($im,($x+(480-$im.Width*$ratio)/2),$y,[int]($im.Width*$ratio),[int]($im.Height*$ratio));$im.Dispose()
  $g.DrawString("$($p.id) $($p.caption)",$font,[Drawing.Brushes]::White,[Drawing.RectangleF]::new($x+10,$y+348,460,52))
 }
 $g.Dispose();$font.Dispose();$num=1+$offset/12;$canvas.Save("$root/.review/selected/selection-$num.jpg",$encoder,$null);$canvas.Dispose()
}
