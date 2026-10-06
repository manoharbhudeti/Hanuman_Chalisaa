Add-Type -AssemblyName System.Drawing

$sourcePath = "C:\Users\mbhudeti\.gemini\antigravity-ide\brain\531a3f6a-abf9-4807-88c8-82693ea2baca\.user_uploaded\media_1791286771397.jpg"
$baseDir = "c:\Users\mbhudeti\AntiGravity\Hanuman_Chalisaa"

Write-Output "Loading source image from $sourcePath"
$sourceImg = [System.Drawing.Image]::FromFile($sourcePath)

function Resize-And-Save($targetPath, $width, $height) {
    $targetDir = Split-Path $targetPath -Parent
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    
    $destBitmap = New-Object System.Drawing.Bitmap($width, $height)
    $destGraphics = [System.Drawing.Graphics]::FromImage($destBitmap)
    $destGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $destGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $destGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $destGraphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    
    $destGraphics.DrawImage($sourceImg, 0, 0, $width, $height)
    $destBitmap.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $destGraphics.Dispose()
    $destBitmap.Dispose()
    Write-Output "Created: $targetPath ($width x $height)"
}

# 1. Assets for app UI usage
Resize-And-Save "$baseDir\assets\images\app_logo.png" 1024 1024
Resize-And-Save "$baseDir\assets\icon\app_icon.png" 1024 1024

# 2. Web Icons
Resize-And-Save "$baseDir\web\favicon.png" 64 64
Resize-And-Save "$baseDir\web\icons\Icon-192.png" 192 192
Resize-And-Save "$baseDir\web\icons\Icon-512.png" 512 512
Resize-And-Save "$baseDir\web\icons\Icon-maskable-192.png" 192 192
Resize-And-Save "$baseDir\web\icons\Icon-maskable-512.png" 512 512

# 3. Android Mipmaps
Resize-And-Save "$baseDir\android\app\src\main\res\mipmap-mdpi\ic_launcher.png" 48 48
Resize-And-Save "$baseDir\android\app\src\main\res\mipmap-hdpi\ic_launcher.png" 72 72
Resize-And-Save "$baseDir\android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" 96 96
Resize-And-Save "$baseDir\android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" 144 144
Resize-And-Save "$baseDir\android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" 192 192

# 4. iOS Icons
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png" 1024 1024
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@1x.png" 20 20
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@2x.png" 40 40
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@3x.png" 60 60
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@1x.png" 29 29
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@2x.png" 58 58
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@3x.png" 87 87
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@1x.png" 40 40
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@2x.png" 80 80
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@3x.png" 120 120
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@2x.png" 120 120
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@3x.png" 180 180
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@1x.png" 76 76
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@2x.png" 152 152
Resize-And-Save "$baseDir\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-83.5x83.5@2x.png" 167 167

# 5. Windows Icon
$winIconPath = "$baseDir\windows\runner\resources\app_icon.ico"
if (Test-Path "$baseDir\windows\runner\resources") {
    $bmp256 = New-Object System.Drawing.Bitmap($sourceImg, 256, 256)
    $hIcon = $bmp256.GetHicon()
    $winIcon = [System.Drawing.Icon]::FromHandle($hIcon)
    $fs = New-Object System.IO.FileStream($winIconPath, [System.IO.FileMode]::Create)
    $winIcon.Save($fs)
    $fs.Close()
    $winIcon.Dispose()
    $bmp256.Dispose()
    Write-Output "Created: $winIconPath"
}

$sourceImg.Dispose()
Write-Output "All icons generated successfully!"
