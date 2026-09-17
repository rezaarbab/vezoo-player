# vezoo_tools/make_icons.ps1
# Generates the VOID launcher icon set for Vezoo.
#
#   powershell -ExecutionPolicy Bypass -File vezoo_tools/make_icons.ps1
#
# Output (all committed, the CI copies them into the generated android/ tree):
#   android_files/icon.png                                 1024 legacy master
#   android_files/icons/mipmap-<density>/ic_launcher.png
#   android_files/icons/mipmap-<density>/ic_launcher_round.png
#   android_files/icons/mipmap-<density>/ic_launcher_foreground.png   (adaptive)
Add-Type -AssemblyName System.Drawing

$root     = Join-Path $PSScriptRoot "..\android_files"
$iconsDir = Join-Path $root "icons"
$root     = [System.IO.Path]::GetFullPath($root)
$iconsDir = [System.IO.Path]::GetFullPath($iconsDir)

$BgTop    = [System.Drawing.Color]::FromArgb(255, 31, 31, 38)
$BgBottom = [System.Drawing.Color]::FromArgb(255, 8, 8, 11)
$AccTop   = [System.Drawing.Color]::FromArgb(255, 251, 191, 36)
$AccBottom= [System.Drawing.Color]::FromArgb(255, 217, 119, 6)
$AccEdge  = [System.Drawing.Color]::FromArgb(255, 245, 158, 11)
$Hairline = [System.Drawing.Color]::FromArgb(38, 255, 255, 255)

function New-RoundedPath([single]$x, [single]$y, [single]$w, [single]$h, [single]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

function New-TrianglePath([single]$cx, [single]$cy, [single]$size) {
  $h  = $size * 1.732 / 2.0
  $x1 = $cx - $size / 2.0
  $y1 = $cy - $h / 2.0
  $pts = [System.Drawing.PointF[]]@(
    (New-Object System.Drawing.PointF($x1, $y1)),
    (New-Object System.Drawing.PointF($x1, ($y1 + $h))),
    (New-Object System.Drawing.PointF(($x1 + $size), $cy))
  )
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p.AddPolygon($pts)
  return $p
}

function New-GlyphBrush([single]$cx, [single]$cy, [single]$size) {
  $a = New-Object System.Drawing.PointF(($cx - $size / 2.0), ($cy - $size / 2.0))
  $b = New-Object System.Drawing.PointF(($cx + $size / 2.0), ($cy + $size / 2.0))
  return New-Object System.Drawing.Drawing2D.LinearGradientBrush($a, $b, $script:AccTop, $script:AccBottom)
}

# mode: legacy (rounded square bg) | foreground (transparent bg)
function New-Icon([int]$S, [string]$out, [string]$mode) {
  $bmp = New-Object System.Drawing.Bitmap($S, $S)
  $g   = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::Transparent)

  $bgPath = $null
  if ($mode -ne 'foreground') {
    $bgPath = New-RoundedPath 0.5 0.5 ($S - 1.0) ($S - 1.0) ([single]($S * 0.225))
    $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
      (New-Object System.Drawing.PointF(0, 0)),
      (New-Object System.Drawing.PointF($S, $S)),
      $script:BgTop, $script:BgBottom)
    $g.FillPath($bgBrush, $bgPath)
    $ringW = [single]([Math]::Max(1.0, $S * 0.007))
    $ring  = New-Object System.Drawing.Pen($script:Hairline, $ringW)
    $g.DrawPath($ring, $bgPath)
    $ring.Dispose()
    $bgBrush.Dispose()
  }

  $triSize = [single]($S * ($(if ($mode -eq 'foreground') { 0.30 } else { 0.52 })))
  $cx = [single]($S * 0.52)
  $cy = [single]($S * 0.50)
  $tri = New-TrianglePath $cx $cy $triSize
  $triBrush = New-GlyphBrush $cx $cy $triSize
  $g.FillPath($triBrush, $tri)

  $joinW = [single]($S * 0.055)
  $join  = New-Object System.Drawing.Pen($script:AccEdge, $joinW)
  $join.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $g.DrawPath($join, $tri)

  $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $join.Dispose(); $triBrush.Dispose(); $tri.Dispose()
  if ($bgPath -ne $null) { $bgPath.Dispose() }
  $g.Dispose(); $bmp.Dispose()
}

function New-RoundIcon([int]$S, [string]$out) {
  $bmp = New-Object System.Drawing.Bitmap($S, $S)
  $g   = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::Transparent)
  $clip = New-Object System.Drawing.Drawing2D.GraphicsPath
  $clip.AddEllipse(0, 0, $S, $S)
  $g.SetClip($clip)

  $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.PointF(0, 0)),
    (New-Object System.Drawing.PointF($S, $S)),
    $script:BgTop, $script:BgBottom)
  $g.FillEllipse($bgBrush, 0, 0, $S, $S)

  $triSize = [single]($S * 0.46)
  $cx = [single]($S * 0.52)
  $cy = [single]($S * 0.50)
  $tri = New-TrianglePath $cx $cy $triSize
  $triBrush = New-GlyphBrush $cx $cy $triSize
  $g.FillPath($triBrush, $tri)
  $join = New-Object System.Drawing.Pen($script:AccEdge, [single]($S * 0.05))
  $join.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $g.DrawPath($join, $tri)
  $g.ResetClip()

  $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
  $join.Dispose(); $triBrush.Dispose(); $tri.Dispose(); $bgBrush.Dispose()
  $g.Dispose(); $bmp.Dispose(); $clip.Dispose()
}

New-Item -ItemType Directory -Force -Path $iconsDir | Out-Null
New-Icon 1024 (Join-Path $root "icon.png") 'legacy'

$legacy = @{ mdpi = 48; hdpi = 72; xhdpi = 96; xxhdpi = 144; xxxhdpi = 192 }
foreach ($k in $legacy.Keys) {
  $dir = Join-Path $iconsDir ("mipmap-" + $k)
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $px = [int]$legacy[$k]
  New-Icon      $px (Join-Path $dir "ic_launcher.png") 'legacy'
  New-RoundIcon $px (Join-Path $dir "ic_launcher_round.png")
}

$adaptive = @{ mdpi = 108; hdpi = 162; xhdpi = 216; xxhdpi = 324; xxxhdpi = 432 }
foreach ($k in $adaptive.Keys) {
  $dir = Join-Path $iconsDir ("mipmap-" + $k)
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  New-Icon ([int]$adaptive[$k]) (Join-Path $dir "ic_launcher_foreground.png") 'foreground'
}

Get-ChildItem -Path $iconsDir -Recurse -File |
  ForEach-Object { $_.FullName.Replace($root + "\", "") }
Write-Output ("master: " + (Join-Path $root "icon.png"))
