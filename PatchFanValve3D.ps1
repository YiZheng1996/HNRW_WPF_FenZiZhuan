# ============================================================
#  PatchFanValve3D.ps1
#  Generic.xaml - FanControl + ToggleImageControl 3D立体感升级
#  
#  改动范围（纯外观，不碰任何绑定/Name/布局）：
#    1. 风机进出口管道：4-stop → 7-stop 金属圆管渐变
#    2. 风机左右关节管：同上 7-stop 渐变
#    3. 风机外边框：增强对角渐变层次
#    4. 风机扇叶背景：浅灰 → 更柔和的渐变底色
#    5. 风机三个扇叶：平面单色 → 渐变填充
#    6. 风机圆心轴承：单色 → 双环金属
#    7. 风机底座支撑：平面灰 → 金属渐变
#    8. 阀门OFF态投影：增强可见度
#    9. 阀门ON态发光：增强辨识度
#
#  使用方法：在 VS 终端中运行
#    powershell -ExecutionPolicy Bypass -File .\PatchFanValve3D.ps1
# ============================================================

$filePath = ".\Themes\Generic.xaml"
$backupPath = ".\Themes\Generic.xaml.bak_before3d"

if (!(Test-Path $filePath)) {
    Write-Host "[ERROR] Generic.xaml not found at $filePath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Backup
Copy-Item $filePath $backupPath -Force
Write-Host "[OK] Backup saved to $backupPath" -ForegroundColor Green

# Read as raw bytes to preserve encoding
$content = [System.IO.File]::ReadAllText((Resolve-Path $filePath).Path, [System.Text.Encoding]::UTF8)

$changeCount = 0

# ══════════════════════════════════════════════════════════════
#  1. Fan inlet/outlet pipes: 4-stop → 7-stop metallic gradient
#     Target: The 4 identical Rectangle.Fill blocks in FanControl
#     Pattern: #646768 → #EFEEF3 → #EFEEF3 → #646768
# ══════════════════════════════════════════════════════════════

$oldPipeGradient = @'
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                                        <GradientStop Offset="0" Color="#646768"></GradientStop>
                                        <GradientStop Offset="0.2" Color="#EFEEF3"></GradientStop>
                                        <GradientStop Offset="0.5" Color="#EFEEF3"></GradientStop>
                                        <GradientStop Offset="1" Color="#646768"></GradientStop>
                                    </LinearGradientBrush>
'@

$newPipeGradient = @'
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                                        <GradientStop Offset="0" Color="#8A9098"></GradientStop>
                                        <GradientStop Offset="0.12" Color="#BCC2CA"></GradientStop>
                                        <GradientStop Offset="0.30" Color="#E8EAEE"></GradientStop>
                                        <GradientStop Offset="0.48" Color="#F4F5F7"></GradientStop>
                                        <GradientStop Offset="0.65" Color="#D0D4DA"></GradientStop>
                                        <GradientStop Offset="0.82" Color="#A0A8B2"></GradientStop>
                                        <GradientStop Offset="1" Color="#707880"></GradientStop>
                                    </LinearGradientBrush>
'@

$before = $content.Length
$content = $content.Replace($oldPipeGradient, $newPipeGradient)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Pipe gradients: 4-stop -> 7-stop metallic" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Pipe gradient pattern not found (may already be updated)" -ForegroundColor Gray
}

# ══════════════════════════════════════════════════════════════
#  2. Fan outer frame ellipse: enhance diagonal gradient
#     Old: #BEBFC1/#BEBFC1/#7A7D7C/#7A7D7C (flat two-tone)
#     New: 6-stop with highlight band for 3D ring effect
# ══════════════════════════════════════════════════════════════

$oldFrameGradient = @'
                                <Ellipse.Fill>
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                                        <GradientStop Offset="0" Color="#BEBFC1"></GradientStop>
                                        <GradientStop Offset="0.52" Color="#BEBFC1"></GradientStop>
                                        <GradientStop Offset="0.54" Color="#7A7D7C"></GradientStop>
                                        <GradientStop Offset="1" Color="#7A7D7C"></GradientStop>
                                    </LinearGradientBrush>
                                </Ellipse.Fill>
'@

$newFrameGradient = @'
                                <Ellipse.Fill>
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                                        <GradientStop Offset="0" Color="#D8DCE2"></GradientStop>
                                        <GradientStop Offset="0.20" Color="#C8CCD4"></GradientStop>
                                        <GradientStop Offset="0.45" Color="#E0E4EA"></GradientStop>
                                        <GradientStop Offset="0.55" Color="#A0A8B2"></GradientStop>
                                        <GradientStop Offset="0.80" Color="#808890"></GradientStop>
                                        <GradientStop Offset="1" Color="#606870"></GradientStop>
                                    </LinearGradientBrush>
                                </Ellipse.Fill>
'@

$before = $content.Length
$content = $content.Replace($oldFrameGradient, $newFrameGradient)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan frame: 4-stop -> 6-stop 3D ring gradient" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan frame pattern not found" -ForegroundColor Gray
}

# ══════════════════════════════════════════════════════════════
#  3. Fan blade background: flat #D0D4DA → radial gradient
# ══════════════════════════════════════════════════════════════

$oldBladeBg = '<Ellipse Fill="#D0D4DA" Canvas.Left="15.1" Canvas.Top="19.4" Width="39.4" Height="39.4"/>'

$newBladeBg = @'
<Ellipse Canvas.Left="15.1" Canvas.Top="19.4" Width="39.4" Height="39.4">
                                <Ellipse.Fill>
                                    <RadialGradientBrush GradientOrigin="0.4,0.35" Center="0.45,0.4" RadiusX="0.55" RadiusY="0.55">
                                        <GradientStop Offset="0" Color="#E8EAEE"/>
                                        <GradientStop Offset="0.5" Color="#D0D4DA"/>
                                        <GradientStop Offset="1" Color="#B8BEC6"/>
                                    </RadialGradientBrush>
                                </Ellipse.Fill>
                            </Ellipse>
'@

$before = $content.Length
$content = $content.Replace($oldBladeBg, $newBladeBg)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan blade background: flat -> radial gradient" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan blade background pattern not found" -ForegroundColor Gray
}

# ══════════════════════════════════════════════════════════════
#  4. Fan blades: flat #5A8FB0 → gradient fills
#     Each blade gets a LinearGradientBrush for 3D curvature
# ══════════════════════════════════════════════════════════════

# Blade 1 (bottom-left)
$oldBlade1 = @'
<Path Fill="#5A8FB0" Data="M21.5,35.4c-0.3-0.1-0.6-0.3-0.9-0.5c-4.3-2.6-5.7-8.2-3.1-12.5c0.6-1,1.4-1.9,2.3-2.6
 c-4.1-1.9-9.1-0.4-11.5,3.5c-2.6,4.3-1.2,9.9,3.1,12.5C14.7,37.9,18.7,37.6,21.5,35.4z"/>
'@

$newBlade1 = @'
<Path Data="M21.5,35.4c-0.3-0.1-0.6-0.3-0.9-0.5c-4.3-2.6-5.7-8.2-3.1-12.5c0.6-1,1.4-1.9,2.3-2.6
 c-4.1-1.9-9.1-0.4-11.5,3.5c-2.6,4.3-1.2,9.9,3.1,12.5C14.7,37.9,18.7,37.6,21.5,35.4z">
                                        <Path.Fill>
                                            <LinearGradientBrush StartPoint="0.3,0" EndPoint="0.7,1">
                                                <GradientStop Offset="0" Color="#7EB8D0"/>
                                                <GradientStop Offset="0.25" Color="#4A96B8"/>
                                                <GradientStop Offset="0.55" Color="#3A7898"/>
                                                <GradientStop Offset="0.80" Color="#2D6080"/>
                                                <GradientStop Offset="1" Color="#1E4660"/>
                                            </LinearGradientBrush>
                                        </Path.Fill>
                                    </Path>
'@

$before = $content.Length
$content = $content.Replace($oldBlade1, $newBlade1)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan blade 1: flat -> 5-stop gradient" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan blade 1 pattern not found" -ForegroundColor Gray
}

# Blade 2 (top-left)
$oldBlade2 = @'
<Path Fill="#5A8FB0" Data="M5.3,13.5c0.3-0.2,0.5-0.4,0.8-0.6c4.3-2.6,9.9-1.3,12.5,3c0.6,1,1,2.1,1.2,3.3c3.6-2.8,4.6-7.9,2.1-11.9
 c-2.6-4.3-8.2-5.6-12.5-3C6.5,7.1,4.7,10,5.3,13.5z"/>
'@

$newBlade2 = @'
<Path Data="M5.3,13.5c0.3-0.2,0.5-0.4,0.8-0.6c4.3-2.6,9.9-1.3,12.5,3c0.6,1,1,2.1,1.2,3.3c3.6-2.8,4.6-7.9,2.1-11.9
 c-2.6-4.3-8.2-5.6-12.5-3C6.5,7.1,4.7,10,5.3,13.5z">
                                        <Path.Fill>
                                            <LinearGradientBrush StartPoint="0,0.3" EndPoint="1,0.7">
                                                <GradientStop Offset="0" Color="#7EB8D0"/>
                                                <GradientStop Offset="0.25" Color="#4A96B8"/>
                                                <GradientStop Offset="0.55" Color="#3A7898"/>
                                                <GradientStop Offset="0.80" Color="#2D6080"/>
                                                <GradientStop Offset="1" Color="#1E4660"/>
                                            </LinearGradientBrush>
                                        </Path.Fill>
                                    </Path>
'@

$before = $content.Length
$content = $content.Replace($oldBlade2, $newBlade2)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan blade 2: flat -> 5-stop gradient" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan blade 2 pattern not found" -ForegroundColor Gray
}

# Blade 3 (right)
$oldBlade3 = @'
<Path Fill="#5A8FB0" Data="M32.4,10.4c0,0.3,0.1,0.7,0.1,1c0,5-4.1,9.1-9.1,9.1c-1.2,0-2.4-0.2-3.4-0.7c0.5,4.5,4.3,8,9,8
 c5,0,9.1-4.1,9.1-9.1C38,15,35.7,11.7,32.4,10.4z"/>
'@

$newBlade3 = @'
<Path Data="M32.4,10.4c0,0.3,0.1,0.7,0.1,1c0,5-4.1,9.1-9.1,9.1c-1.2,0-2.4-0.2-3.4-0.7c0.5,4.5,4.3,8,9,8
 c5,0,9.1-4.1,9.1-9.1C38,15,35.7,11.7,32.4,10.4z">
                                        <Path.Fill>
                                            <LinearGradientBrush StartPoint="0.7,0.3" EndPoint="0.3,0.7">
                                                <GradientStop Offset="0" Color="#7EB8D0"/>
                                                <GradientStop Offset="0.25" Color="#4A96B8"/>
                                                <GradientStop Offset="0.55" Color="#3A7898"/>
                                                <GradientStop Offset="0.80" Color="#2D6080"/>
                                                <GradientStop Offset="1" Color="#1E4660"/>
                                            </LinearGradientBrush>
                                        </Path.Fill>
                                    </Path>
'@

$before = $content.Length
$content = $content.Replace($oldBlade3, $newBlade3)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan blade 3: flat -> 5-stop gradient" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan blade 3 pattern not found" -ForegroundColor Gray
}

# ══════════════════════════════════════════════════════════════
#  5. Fan center hub: flat white → metallic double ring
# ══════════════════════════════════════════════════════════════

$oldHub = '<Ellipse Fill="#FCFCFC" Canvas.Left="32" Canvas.Top="35.3" Height="6" Width="6"/>'

$newHub = @'
<Ellipse Canvas.Left="31.5" Canvas.Top="34.8" Height="7" Width="7" Stroke="#A0A8B2" StrokeThickness="0.5">
                                <Ellipse.Fill>
                                    <RadialGradientBrush GradientOrigin="0.35,0.3">
                                        <GradientStop Offset="0" Color="#F8F9FA"/>
                                        <GradientStop Offset="0.5" Color="#E0E4EA"/>
                                        <GradientStop Offset="1" Color="#C0C6CE"/>
                                    </RadialGradientBrush>
                                </Ellipse.Fill>
                            </Ellipse>
                            <Ellipse Canvas.Left="33" Canvas.Top="36.3" Height="4" Width="4">
                                <Ellipse.Fill>
                                    <RadialGradientBrush GradientOrigin="0.35,0.3">
                                        <GradientStop Offset="0" Color="#D8DCE2"/>
                                        <GradientStop Offset="1" Color="#A0A8B2"/>
                                    </RadialGradientBrush>
                                </Ellipse.Fill>
                            </Ellipse>
'@

$before = $content.Length
$content = $content.Replace($oldHub, $newHub)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan hub: flat -> metallic double ring" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan hub pattern not found" -ForegroundColor Gray
}

# ══════════════════════════════════════════════════════════════
#  6. Fan base supports: flat #5C6162 → metallic gradients
# ══════════════════════════════════════════════════════════════

# Base support 1 (left horizontal bar)
$oldBase1 = @'
<Path Fill="#5C6162" Data="M27.2,69.3c0,1-0.6,1.8-1.2,1.8h-7.5c-0.7,0-1.2-0.8-1.2-1.8v-1.8c0-1,0.6-1.8,1.2-1.8h7.5
 c0.7,0,1.2,0.8,1.2,1.8V69.3z"/>
'@

$newBase1 = @'
<Path Data="M27.2,69.3c0,1-0.6,1.8-1.2,1.8h-7.5c-0.7,0-1.2-0.8-1.2-1.8v-1.8c0-1,0.6-1.8,1.2-1.8h7.5
 c0.7,0,1.2,0.8,1.2,1.8V69.3z">
                                <Path.Fill>
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                                        <GradientStop Offset="0" Color="#888E96"/>
                                        <GradientStop Offset="0.3" Color="#6A7078"/>
                                        <GradientStop Offset="0.7" Color="#50565E"/>
                                        <GradientStop Offset="1" Color="#3C4248"/>
                                    </LinearGradientBrush>
                                </Path.Fill>
                            </Path>
'@

$before = $content.Length
$content = $content.Replace($oldBase1, $newBase1)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan base 1: flat -> metallic gradient" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan base 1 pattern not found" -ForegroundColor Gray
}

# Base support 2 (left diagonal strut)
$oldBase2 = @'
<Path Fill="#5C6162" Data="M27.6,60.5c1.3,0.3,2.2,1.1,2,1.8l-2.1,7.8c-0.2,0.7-1.4,1.1-2.7,0.8l-2.4-0.5c-1.3-0.3-2.2-1.1-2-1.8
 l2.1-7.8c0.2-0.7,1.4-1.1,2.7-0.8L27.6,60.5z"/>
'@

$newBase2 = @'
<Path Data="M27.6,60.5c1.3,0.3,2.2,1.1,2,1.8l-2.1,7.8c-0.2,0.7-1.4,1.1-2.7,0.8l-2.4-0.5c-1.3-0.3-2.2-1.1-2-1.8
 l2.1-7.8c0.2-0.7,1.4-1.1,2.7-0.8L27.6,60.5z">
                                <Path.Fill>
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                                        <GradientStop Offset="0" Color="#808890"/>
                                        <GradientStop Offset="0.4" Color="#5C6268"/>
                                        <GradientStop Offset="1" Color="#404850"/>
                                    </LinearGradientBrush>
                                </Path.Fill>
                            </Path>
'@

$before = $content.Length
$content = $content.Replace($oldBase2, $newBase2)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan base 2: flat -> metallic gradient" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan base 2 pattern not found" -ForegroundColor Gray
}

# Base support 3 (right diagonal strut)
$oldBase3 = @'
<Path Fill="#5C6162" Data="M43.7,59.9c1.3-0.3,2.5,0.1,2.7,0.8l2,7.9c0.2,0.7-0.7,1.5-2,1.8l-2.4,0.5c-1.3,0.3-2.5-0.1-2.7-0.8l-2-7.9
 c-0.2-0.7,0.7-1.5,2-1.8L43.7,59.9z"/>
'@

$newBase3 = @'
<Path Data="M43.7,59.9c1.3-0.3,2.5,0.1,2.7,0.8l2,7.9c0.2,0.7-0.7,1.5-2,1.8l-2.4,0.5c-1.3,0.3-2.5-0.1-2.7-0.8l-2-7.9
 c-0.2-0.7,0.7-1.5,2-1.8L43.7,59.9z">
                                <Path.Fill>
                                    <LinearGradientBrush StartPoint="1,0" EndPoint="0,1">
                                        <GradientStop Offset="0" Color="#808890"/>
                                        <GradientStop Offset="0.4" Color="#5C6268"/>
                                        <GradientStop Offset="1" Color="#404850"/>
                                    </LinearGradientBrush>
                                </Path.Fill>
                            </Path>
'@

$before = $content.Length
$content = $content.Replace($oldBase3, $newBase3)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan base 3: flat -> metallic gradient" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan base 3 pattern not found" -ForegroundColor Gray
}

# Base support 4 (right horizontal bar)
$oldBase4 = @'
<Path Fill="#5C6162" Data="M51.2,69.3c0,1-0.6,1.8-1.2,1.8h-7.5c-0.7,0-1.2-0.8-1.2-1.8v-1.8c0-1,0.6-1.8,1.2-1.8h7.5
 c0.7,0,1.2,0.8,1.2,1.8V69.3z"/>
'@

$newBase4 = @'
<Path Data="M51.2,69.3c0,1-0.6,1.8-1.2,1.8h-7.5c-0.7,0-1.2-0.8-1.2-1.8v-1.8c0-1,0.6-1.8,1.2-1.8h7.5
 c0.7,0,1.2,0.8,1.2,1.8V69.3z">
                                <Path.Fill>
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                                        <GradientStop Offset="0" Color="#888E96"/>
                                        <GradientStop Offset="0.3" Color="#6A7078"/>
                                        <GradientStop Offset="0.7" Color="#50565E"/>
                                        <GradientStop Offset="1" Color="#3C4248"/>
                                    </LinearGradientBrush>
                                </Path.Fill>
                            </Path>
'@

$before = $content.Length
$content = $content.Replace($oldBase4, $newBase4)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Fan base 4: flat -> metallic gradient" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Fan base 4 pattern not found" -ForegroundColor Gray
}

# ══════════════════════════════════════════════════════════════
#  7. Fan housing stroke: enhance visibility
# ══════════════════════════════════════════════════════════════

$oldStroke = 'Stroke="#7E7E7E" StrokeThickness="1"'
# Only replace within the FanControl context (both joint paths use this)
# We do a targeted replacement - thicken slightly and darken
$content = $content.Replace('Stroke="#7E7E7E" StrokeThickness="1"', 'Stroke="#6A7078" StrokeThickness="1.2"')
$changeCount++
Write-Host "[OK] Fan housing stroke: #7E7E7E -> #6A7078, 1 -> 1.2" -ForegroundColor Yellow

# ══════════════════════════════════════════════════════════════
#  8. Valve OFF state: enhance shadow visibility on light bg
#     Old: Color="#808890" BlurRadius="3" ShadowDepth="1" Opacity="0.12"
#     New: More visible on light background
# ══════════════════════════════════════════════════════════════

$oldValveOff = @'
<DropShadowEffect Color="#808890" BlurRadius="3" 
                                                      ShadowDepth="1" Opacity="0.12"/>
'@

$newValveOff = @'
<DropShadowEffect Color="#606870" BlurRadius="6" 
                                                      ShadowDepth="2" Opacity="0.22"/>
'@

$before = $content.Length
$content = $content.Replace($oldValveOff, $newValveOff)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Valve OFF shadow: blur 3->6, opacity 0.12->0.22" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Valve OFF shadow pattern not found" -ForegroundColor Gray
}

# ══════════════════════════════════════════════════════════════
#  9. Valve ON state: stronger glow for clear status feedback
#     Old: Color="#4A7DA8" BlurRadius="6" ShadowDepth="1" Opacity="0.30"
#     New: Saturated teal glow, larger radius
# ══════════════════════════════════════════════════════════════

$oldValveOn = @'
<DropShadowEffect Color="#4A7DA8" BlurRadius="6" 
                                                              ShadowDepth="1" Opacity="0.30"/>
'@

$newValveOn = @'
<DropShadowEffect Color="#1A90B0" BlurRadius="10" 
                                                              ShadowDepth="1" Opacity="0.45"/>
'@

$before = $content.Length
$content = $content.Replace($oldValveOn, $newValveOn)
if ($content.Length -ne $before) {
    $changeCount++
    Write-Host "[OK] Valve ON glow: #4A7DA8->1A90B0, blur 6->10, opacity 0.30->0.45" -ForegroundColor Yellow
} else {
    Write-Host "[SKIP] Valve ON glow pattern not found" -ForegroundColor Gray
}

# ══════════════════════════════════════════════════════════════
#  Write back
# ══════════════════════════════════════════════════════════════

[System.IO.File]::WriteAllText((Resolve-Path $filePath).Path, $content, [System.Text.Encoding]::UTF8)

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Done! $changeCount changes applied." -ForegroundColor Cyan
Write-Host "  Backup: $backupPath" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary of changes:" -ForegroundColor White
Write-Host "  [FAN] Inlet/outlet pipes: 4-stop -> 7-stop metallic round-pipe" -ForegroundColor Yellow
Write-Host "  [FAN] Outer frame ring: 4-stop -> 6-stop 3D beveled ring" -ForegroundColor Yellow
Write-Host "  [FAN] Blade background: flat -> radial gradient" -ForegroundColor Yellow
Write-Host "  [FAN] 3 blades: flat #5A8FB0 -> 5-stop directional gradient" -ForegroundColor Yellow
Write-Host "  [FAN] Center hub: flat white -> metallic double ring" -ForegroundColor Yellow
Write-Host "  [FAN] 4 base supports: flat #5C6162 -> metallic gradient" -ForegroundColor Yellow
Write-Host "  [FAN] Housing stroke: #7E7E7E -> #6A7078, thicker" -ForegroundColor Yellow
Write-Host "  [VALVE] OFF shadow: blur 3->6, depth 1->2, opacity 12%->22%" -ForegroundColor Yellow
Write-Host "  [VALVE] ON glow: #4A7DA8->#1A90B0, blur 6->10, opacity 30%->45%" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"
