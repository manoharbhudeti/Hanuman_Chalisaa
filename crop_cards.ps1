Add-Type -AssemblyName System.Drawing

$sourcePath = "C:\Users\mbhudeti\.gemini\antigravity-ide\brain\531a3f6a-abf9-4807-88c8-82693ea2baca\.user_uploaded\media_1791293533644.png"
$bmp = [System.Drawing.Bitmap]::FromFile($sourcePath)

$w = $bmp.Width
$h = $bmp.Height

# Check vertical pixels on x=140
$yTop = 0
for ($y = 0; $y -lt $h; $y++) {
    $c = $bmp.GetPixel(140, $y)
    if ($c.R -gt 200 -and $c.G -gt 80) {
        $yTop = $y
        break
    }
}

$yBottom = $h - 1
for ($y = $h - 1; $y -ge 0; $y--) {
    $c = $bmp.GetPixel(140, $y)
    if ($c.R -gt 200 -and $c.G -gt 80) {
        $yBottom = $y
        break
    }
}

$cardHeight = $yBottom - $yTop + 1
Write-Output "Card yTop=$yTop, yBottom=$yBottom, Height=$cardHeight"

# Define the exact bounding boxes for the 4 cards:
# Card 0 (0s: Intro & Gada Appears): x ≈ 45 to 247
# Card 1 (1s: Hanuman Leaps): x ≈ 290 to 492
# Card 2 (2s: Catches Gada): x ≈ 537 to 739
# Card 3 (3s: Final Pose): x ≈ 782 to 984

$cards = @(
    @{ Name = "frame_0_intro"; X = 43; Width = 205 },
    @{ Name = "frame_1_leap"; X = 289; Width = 205 },
    @{ Name = "frame_2_catch"; X = 535; Width = 205 },
    @{ Name = "frame_3_pranam"; X = 781; Width = 205 }
)

$targetDir = "c:\Users\mbhudeti\AntiGravity\Hanuman_Chalisaa\assets\animation"
if (!(Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

for ($i = 0; $i -lt $cards.Count; $i++) {
    $card = $cards[$i]
    $x = $card.X
    $cw = $card.Width
    $rect = New-Object System.Drawing.Rectangle($x, $yTop, $cw, $cardHeight)
    $cropped = $bmp.Clone($rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $outPath = "$targetDir\$($card.Name).png"
    $cropped.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $cropped.Dispose()
    Write-Output "Exported: $outPath ($cw x $cardHeight)"
}

$bmp.Dispose()
Write-Output "All 4 storyboard animation frames exported successfully!"
