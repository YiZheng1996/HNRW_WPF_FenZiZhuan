# FixElbow18L.ps1
# Fix: elbow connector between border1 (vertical) and border18 (horizontal)
# Problem: color mismatch due to small arc radius + Absolute MappingMode gradient
# Solution: replace with properly sized filled-area elbow using two concentric arcs

param(
    [string]$XamlPath = ".\MainWindow.xaml"
)

if (-not (Test-Path $XamlPath)) {
    Write-Host "[ERROR] MainWindow.xaml not found at $XamlPath" -ForegroundColor Red
    Write-Host "  Usage: .\FixElbow18L.ps1 -XamlPath 'path\to\MainWindow.xaml'"
    Read-Host "Press Enter to exit"
    exit 1
}

# Backup
$backupPath = "$XamlPath.bak_elbow18L_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $XamlPath $backupPath -Force
Write-Host "[OK] Backup saved: $backupPath" -ForegroundColor Green

# Read file
$content = [System.IO.File]::ReadAllText((Resolve-Path $XamlPath).Path, [System.Text.Encoding]::UTF8)

# ============================================================
# OLD elbow block (the entire Canvas at Left=105, Top=372)
# ============================================================
$oldElbow = @'
                <!-- ╰ 弯头：向上→向左 -->
                <Canvas Canvas.Left="105" Canvas.Top="372">
                    <!-- 管壁层：MappingMode=Absolute 让渐变不因弧形变形 -->
                    <Path StrokeThickness="10"
                        StrokeStartLineCap="Flat" StrokeEndLineCap="Flat"
                        Data="M 0,0 A 14,15 0 0 0 15,15">
                        <Path.Stroke>
                            <LinearGradientBrush MappingMode="Absolute"
                                                 StartPoint="0,0" EndPoint="0,15">
                                <GradientStop Color="#FFD0D4DA" Offset="0"/>
                                <GradientStop Color="#FFC0C6CE" Offset="0.10"/>
                                <GradientStop Color="#FFE8EAEE" Offset="0.28"/>
                                <GradientStop Color="#FFC8CED6" Offset="0.55"/>
                                <GradientStop Color="#FFA0A8B2" Offset="0.82"/>
                                <GradientStop Color="#FF909098" Offset="1"/>
                            </LinearGradientBrush>
                        </Path.Stroke>
                    </Path>

                    <!-- 流体层：颜色=#00EEFF, Opacity=1.0 和 liquidline18 完全一致 -->
                    <Path x:Name="elbowFluid18L"
                        Stroke="#6B8DA8" StrokeThickness="6" Opacity="1.0"
                        StrokeDashArray="2,3" StrokeDashCap="Round"
                        StrokeStartLineCap="Round" StrokeEndLineCap="Round"
                        Data="M 0,0 A 15,15 0 0 0 15,15"/>
                </Canvas>
'@

# ============================================================
# NEW elbow block
# Strategy:
#   - Use a filled closed Path (two concentric arcs) instead of thick stroke
#   - This gives the gradient a proper rectangular bounding box to map onto
#   - Outer arc radius = 16, inner arc radius = 8 => pipe wall thickness = 8
#   - The fill gradient maps top-to-bottom across the bounding box,
#     producing the same metallic band as the straight pipes
#   - Fluid dash layer uses stroke on the mid-radius arc (r=12)
#   - Position adjusted so the elbow seamlessly meets both pipes
# ============================================================
$newElbow = @'
                <!-- ╰ 弯头：border1(垂直)→border18(水平) 填充式弯头 -->
                <Canvas Canvas.Left="97" Canvas.Top="374">
                    <!-- 管壁层：用两条同心弧围成的闭合区域 + Fill渐变 -->
                    <Path StrokeThickness="0">
                        <Path.Data>
                            <PathGeometry>
                                <PathFigure StartPoint="0,0" IsClosed="True">
                                    <!-- 外弧：从上端到右端，半径=18 -->
                                    <ArcSegment Point="18,18" Size="18,18" SweepDirection="Clockwise" IsLargeArc="False"/>
                                    <!-- 直线到内弧右端 -->
                                    <LineSegment Point="10,18"/>
                                    <!-- 内弧：从右端回到上端，半径=10 -->
                                    <ArcSegment Point="0,8" Size="10,10" SweepDirection="Counterclockwise" IsLargeArc="False"/>
                                    <!-- 自动闭合回 StartPoint -->
                                </PathFigure>
                            </PathGeometry>
                        </Path.Data>
                        <Path.Fill>
                            <LinearGradientBrush StartPoint="0,0" EndPoint="0,1">
                                <GradientStop Color="#FFD0D4DA" Offset="0"/>
                                <GradientStop Color="#FFC0C6CE" Offset="0.10"/>
                                <GradientStop Color="#FFE8EAEE" Offset="0.28"/>
                                <GradientStop Color="#FFC8CED6" Offset="0.55"/>
                                <GradientStop Color="#FFA0A8B2" Offset="0.82"/>
                                <GradientStop Color="#FF909098" Offset="1"/>
                            </LinearGradientBrush>
                        </Path.Fill>
                    </Path>

                    <!-- 流体层：沿中心弧线绘制虚线，半径=14 -->
                    <Path x:Name="elbowFluid18L"
                        Stroke="#6B8DA8" StrokeThickness="5" Opacity="1.0"
                        StrokeDashArray="2,3" StrokeDashCap="Round"
                        StrokeStartLineCap="Round" StrokeEndLineCap="Round"
                        Data="M 0,4 A 14,14 0 0 1 14,18"/>
                </Canvas>
'@

$before = $content.Length
$content = $content.Replace($oldElbow, $newElbow)

if ($content.Length -ne $before) {
    Write-Host "[OK] Elbow 18L replaced: filled-area elbow with matching gradient" -ForegroundColor Yellow
} else {
    Write-Host "[WARN] Old elbow pattern not found - may need manual replacement" -ForegroundColor Red
    Write-Host "  Try opening MainWindow.xaml and searching for 'Canvas.Left=""105"" Canvas.Top=""372""'" -ForegroundColor Gray
    Read-Host "Press Enter to exit"
    exit 1
}

# Save
[System.IO.File]::WriteAllText((Resolve-Path $XamlPath).Path, $content, [System.Text.Encoding]::UTF8)

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Elbow 18L fix applied successfully!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Changes:" -ForegroundColor White
Write-Host "  [FIX] Stroke-based elbow -> filled dual-arc elbow" -ForegroundColor Yellow
Write-Host "  [FIX] Gradient now maps across full bounding box (no Absolute mode)" -ForegroundColor Yellow
Write-Host "  [FIX] Position adjusted (105,372) -> (97,374) for seamless join" -ForegroundColor Yellow
Write-Host "  [FIX] Pipe wall: outer R=18, inner R=10, thickness=8 (matches Border height)" -ForegroundColor Yellow
Write-Host "  [FIX] Fluid dash layer on mid-arc R=14" -ForegroundColor Yellow
Write-Host ""
Write-Host "Please rebuild and check the junction visually." -ForegroundColor White
Write-Host "If position needs fine-tuning, adjust Canvas.Left/Top on the elbow Canvas." -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
