Add-Type -AssemblyName System.Drawing
$root=[IO.Path]::GetFullPath("$PSScriptRoot/..")
$rows=Get-Content "$root/.review/inventory.json" -Raw | ConvertFrom-Json | Where-Object type -eq video
for($offset=0;$offset -lt $rows.Count;$offset+=7){
 $canvas=[Drawing.Bitmap]::new(1280,1540);$g=[Drawing.Graphics]::FromImage($canvas);$g.Clear([Drawing.Color]::FromArgb(8,30,41));$font=[Drawing.Font]::new('Arial',13)
 for($i=0;$i -lt 7 -and ($offset+$i) -lt $rows.Count;$i++){
  $r=$rows[$offset+$i];$y=$i*220
  for($j=0;$j -lt 4;$j++){
   $file="$root/.review/video-frames/$($r.id)-$j.jpg"
   if(Test-Path $file){$im=[Drawing.Image]::FromFile($file);$ratio=[Math]::Min(310.0/$im.Width,185.0/$im.Height);$g.DrawImage($im,$j*320,$y,[int]($im.Width*$ratio),[int]($im.Height*$ratio));$im.Dispose()}
  }
  $g.DrawString("$($r.id) $($r.filename) · $($r.width)x$($r.height) · $($r.duration_seconds)s",$font,[Drawing.Brushes]::White,5,$y+190)
 }
 $g.Dispose();$font.Dispose();$num=1+$offset/7;$canvas.Save("$root/.review/video-frames/video-sheet-$num.jpg");$canvas.Dispose()
}
