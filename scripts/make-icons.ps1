$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$build = Join-Path $root 'build'
$iconset = Join-Path $build 'icon.iconset'
New-Item -ItemType Directory -Force -Path $build, $iconset | Out-Null

function New-RoundedPath {
    param(
        [float]$X,
        [float]$Y,
        [float]$W,
        [float]$H,
        [float]$R
    )
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $R * 2
    $path.AddArc($X, $Y, $d, $d, 180, 90)
    $path.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
    $path.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
    $path.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-IconBitmap {
    param([int]$Size)

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    $margin = [float]($Size * 0.075)
    $x = $margin
    $y = $margin
    $w = [float]($Size - 2 * $margin)
    $h = $w
    $r = [float]($Size * 0.215)

    $path = New-RoundedPath -X $x -Y $y -W $w -H $h -R $r

    # Soft drop shadow: a few offset copies with low alpha.
    for ($i = 7; $i -ge 1; $i--) {
        $alpha = [int](5 + (8 - $i) * 2)
        $shadowPath = New-RoundedPath -X ($x + $i * 0.7) -Y ($y + $i * 1.3) -W $w -H $h -R $r
        $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($alpha, 0, 0, 0))
        $g.FillPath($shadowBrush, $shadowPath)
        $shadowBrush.Dispose()
        $shadowPath.Dispose()
    }

    $c1 = [System.Drawing.ColorTranslator]::FromHtml('#109184')
    $c2 = [System.Drawing.ColorTranslator]::FromHtml('#0B5F59')
    $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.PointF($x, $y)),
        (New-Object System.Drawing.PointF(($x + $w), ($y + $h))),
        $c1,
        $c2
    )
    $g.FillPath($gradient, $path)
    $gradient.Dispose()

    # Subtle top highlight.
    $g.SetClip($path)
    $highlight = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.PointF($x, $y)),
        (New-Object System.Drawing.PointF($x, ($y + $h * 0.62))),
        [System.Drawing.Color]::FromArgb(55, 255, 255, 255),
        [System.Drawing.Color]::FromArgb(0, 255, 255, 255)
    )
    $g.FillRectangle($highlight, $x, $y, $w, $h)
    $highlight.Dispose()
    $g.ResetClip()

    # Thin inner border.
    $border = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(42, 255, 255, 255), [float]([Math]::Max(1, $Size * 0.008)))
    $g.DrawPath($border, $path)
    $border.Dispose()

    # White photo frame, sun and mountains. This scales much better than a
    # large CJK glyph at 16-32 px.
    $frameX = [float]($Size * 0.205)
    $frameY = [float]($Size * 0.235)
    $frameW = [float]($Size * 0.590)
    $frameH = [float]($Size * 0.530)
    $frameR = [float]($Size * 0.060)
    $framePath = New-RoundedPath -X $frameX -Y $frameY -W $frameW -H $frameH -R $frameR

    $frameFill = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(24, 255, 255, 255))
    $g.FillPath($frameFill, $framePath)
    $frameFill.Dispose()

    $framePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(244, 255, 255, 255), [float]($Size * 0.042))
    $framePen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $framePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $framePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawPath($framePen, $framePath)
    $framePen.Dispose()

    # Sun.
    $sunBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(248, 255, 255, 255))
    $sunSize = [float]($Size * 0.105)
    $sunX = [float]($Size * 0.585)
    $sunY = [float]($Size * 0.335)
    $g.FillEllipse($sunBrush, $sunX, $sunY, $sunSize, $sunSize)

    # Mountains.
    $mountains = New-Object System.Drawing.Drawing2D.GraphicsPath
    $points = @(
        (New-Object System.Drawing.PointF([float]($Size * 0.270), [float]($Size * 0.690))),
        (New-Object System.Drawing.PointF([float]($Size * 0.415), [float]($Size * 0.455))),
        (New-Object System.Drawing.PointF([float]($Size * 0.525), [float]($Size * 0.605))),
        (New-Object System.Drawing.PointF([float]($Size * 0.600), [float]($Size * 0.515))),
        (New-Object System.Drawing.PointF([float]($Size * 0.730), [float]($Size * 0.690)))
    )
    $mountains.AddPolygon($points)
    $g.FillPath($sunBrush, $mountains)

    $mountains.Dispose()
    $sunBrush.Dispose()
    $framePath.Dispose()
    $path.Dispose()
    $g.Dispose()
    return $bmp
}

function Resize-Bitmap {
    param(
        [System.Drawing.Bitmap]$Source,
        [int]$Size
    )
    $dest = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($Source, 0, 0, $Size, $Size)
    $g.Dispose()
    return $dest
}

$base = New-IconBitmap -Size 1024
$sizes = @(16, 32, 48, 64, 128, 256, 512, 1024)
$pngs = @{}

foreach ($size in $sizes) {
    if ($size -eq 1024) {
        $bmp = $base
    } else {
        $bmp = Resize-Bitmap -Source $base -Size $size
    }
    $out = Join-Path $build ("icon-{0}.png" -f $size)
    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    $pngs[$size] = [System.IO.File]::ReadAllBytes($out)
    if ($size -ne 1024) { $bmp.Dispose() }
}

$base.Save((Join-Path $build 'icon.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$base.Dispose()

# Apple iconset naming (for optional `iconutil` regeneration on macOS).
$iconsetMap = @{
    'icon_16x16.png'     = 16
    'icon_16x16@2x.png'  = 32
    'icon_32x32.png'     = 32
    'icon_32x32@2x.png'  = 64
    'icon_128x128.png'   = 128
    'icon_128x128@2x.png'= 256
    'icon_256x256.png'   = 256
    'icon_256x256@2x.png'= 512
    'icon_512x512.png'   = 512
    'icon_512x512@2x.png'= 1024
}
foreach ($name in $iconsetMap.Keys) {
    [System.IO.File]::WriteAllBytes((Join-Path $iconset $name), $pngs[$iconsetMap[$name]])
}

function Write-BigEndian32 {
    param([System.IO.BinaryWriter]$Writer, [UInt32]$Value)
    $Writer.Write([byte](($Value -shr 24) -band 0xFF))
    $Writer.Write([byte](($Value -shr 16) -band 0xFF))
    $Writer.Write([byte](($Value -shr 8) -band 0xFF))
    $Writer.Write([byte]($Value -band 0xFF))
}

# ICNS (PNG-compressed chunks).
$icnsChunks = @(
    @{ Type = 'icp4'; Size = 16 },
    @{ Type = 'icp5'; Size = 32 },
    @{ Type = 'icp6'; Size = 64 },
    @{ Type = 'ic07'; Size = 128 },
    @{ Type = 'ic08'; Size = 256 },
    @{ Type = 'ic09'; Size = 512 },
    @{ Type = 'ic10'; Size = 1024 }
)

$total = 8
foreach ($chunk in $icnsChunks) { $total += 8 + $pngs[$chunk.Size].Length }
$icnsPath = Join-Path $build 'icon.icns'
$fs = [System.IO.File]::Open($icnsPath, [System.IO.FileMode]::Create)
$bw = New-Object System.IO.BinaryWriter($fs)
$bw.Write([System.Text.Encoding]::ASCII.GetBytes('icns'))
Write-BigEndian32 -Writer $bw -Value ([UInt32]$total)
foreach ($chunk in $icnsChunks) {
    $bw.Write([System.Text.Encoding]::ASCII.GetBytes($chunk.Type))
    $data = $pngs[$chunk.Size]
    Write-BigEndian32 -Writer $bw -Value ([UInt32](8 + $data.Length))
    $bw.Write($data)
}
$bw.Dispose()
$fs.Dispose()

# Windows ICO (PNG-compressed entries), useful for local testing.
$icoSizes = @(16, 32, 48, 64, 128, 256)
$icoHeaderSize = 6 + 16 * $icoSizes.Count
$icoOffset = $icoHeaderSize
$icoTotal = $icoHeaderSize
foreach ($size in $icoSizes) { $icoTotal += $pngs[$size].Length }
$icoPath = Join-Path $build 'icon.ico'
$fs = [System.IO.File]::Open($icoPath, [System.IO.FileMode]::Create)
$bw = New-Object System.IO.BinaryWriter($fs)
$bw.Write([UInt16]0)
$bw.Write([UInt16]1)
$bw.Write([UInt16]$icoSizes.Count)
foreach ($size in $icoSizes) {
    $data = $pngs[$size]
    $dim = if ($size -ge 256) { 0 } else { $size }
    $bw.Write([byte]$dim)
    $bw.Write([byte]$dim)
    $bw.Write([byte]0)
    $bw.Write([byte]0)
    $bw.Write([UInt16]1)
    $bw.Write([UInt16]32)
    $bw.Write([UInt32]$data.Length)
    $bw.Write([UInt32]$icoOffset)
    $icoOffset += $data.Length
}
foreach ($size in $icoSizes) {
    $bw.Write($pngs[$size])
}
$bw.Dispose()
$fs.Dispose()

Write-Host "Generated:"
Get-ChildItem $build -File | Select-Object Name, Length | Format-Table -AutoSize
