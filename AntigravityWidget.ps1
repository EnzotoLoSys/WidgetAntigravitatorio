Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

# Win32 Window Tools (Click-Through)
if (-not ([System.Management.Automation.PSTypeName]'Win32WindowTools').Type) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public class Win32WindowTools {
    public const int GWL_EXSTYLE = -20;
    public const int WS_EX_TRANSPARENT = 0x00000020;

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

    public static void SetClickThrough(IntPtr hWnd, bool enable) {
        int exStyle = GetWindowLong(hWnd, GWL_EXSTYLE);
        if (enable) {
            SetWindowLong(hWnd, GWL_EXSTYLE, exStyle | WS_EX_TRANSPARENT);
        } else {
            SetWindowLong(hWnd, GWL_EXSTYLE, exStyle & ~WS_EX_TRANSPARENT);
        }
    }
}
'@
}

$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Antigravity Widget"
        SizeToContent="WidthAndHeight"
        ResizeMode="NoResize"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        WindowStartupLocation="CenterScreen">
    
    <Window.Resources>
        <Style TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe UI, Segoe UI Variable, Arial"/>
            <Setter Property="Foreground" Value="#E2E8F0"/>
            <Setter Property="IsHitTestVisible" Value="False"/>
        </Style>
        <Style TargetType="ProgressBar">
            <Setter Property="IsHitTestVisible" Value="False"/>
        </Style>
        <Style TargetType="Ellipse">
            <Setter Property="IsHitTestVisible" Value="False"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="Foreground" Value="#CBD5E1"/>
            <Setter Property="FontSize" Value="9"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Margin" Value="0,1,0,2"/>
        </Style>
        
        <!-- Native Dark Context Menu Style -->
        <Style TargetType="ContextMenu">
            <Setter Property="Background" Value="#0F172A"/>
            <Setter Property="BorderBrush" Value="#334155"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Foreground" Value="#E2E8F0"/>
            <Setter Property="FontSize" Value="11"/>
        </Style>
        <Style TargetType="MenuItem">
            <Setter Property="Foreground" Value="#E2E8F0"/>
            <Setter Property="Background" Value="#0F172A"/>
        </Style>
    </Window.Resources>

    <Grid Name="RootContainer" Margin="4" Background="#00000000">
        <Grid.LayoutTransform>
            <ScaleTransform x:Name="UiScale" ScaleX="1.0" ScaleY="1.0"/>
        </Grid.LayoutTransform>

        <!-- Main Card Border (Snug & Ultra-Compact) -->
        <Border Name="MainBorder" CornerRadius="10" BorderThickness="1.2" Cursor="SizeAll">
            <Border.BorderBrush>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                    <GradientStop Color="#60A5FA" Offset="0.0"/>
                    <GradientStop Color="#1E293B" Offset="0.5"/>
                    <GradientStop Color="#00F2FE" Offset="1.0"/>
                </LinearGradientBrush>
            </Border.BorderBrush>
            <Border.Background>
                <SolidColorBrush Color="#0B0F19" Opacity="0.90"/>
            </Border.Background>
            <Border.Effect>
                <DropShadowEffect BlurRadius="10" ShadowDepth="2" Direction="270" Color="#000000" Opacity="0.85"/>
            </Border.Effect>

            <!-- Right-Click Menu -->
            <Border.ContextMenu>
                <ContextMenu Name="WidgetContextMenu">
                    <MenuItem Header="Cambiar Vista">
                        <MenuItem Name="CtxModeBars" Header="Barras"/>
                        <MenuItem Name="CtxModeGauges" Header="Tacometros"/>
                        <MenuItem Name="CtxModeChips" Header="Solo Porcentajes"/>
                    </MenuItem>
                    <MenuItem Header="Orientacion">
                        <MenuItem Name="CtxOrientH" Header="Horizontal (Fila)"/>
                        <MenuItem Name="CtxOrientV" Header="Vertical (Columna)"/>
                    </MenuItem>
                    <MenuItem Name="CtxSettings" Header="Opciones y Estilo"/>
                    <MenuItem Name="CtxPin" Header="Siempre arriba" IsCheckable="True"/>
                    <MenuItem Name="CtxClickThrough" Header="Modo Fantasma (Click-Through)" IsCheckable="True"/>
                    <Separator Background="#334155"/>
                    <MenuItem Name="CtxRefresh" Header="Actualizar ahora"/>
                    <Separator Background="#334155"/>
                    <MenuItem Name="CtxClose" Header="Cerrar Widget"/>
                </ContextMenu>
            </Border.ContextMenu>

            <StackPanel Margin="6,5,6,5">
                <!-- ================= VISTA 1: BARRAS COMPACTAS ================= -->
                <StackPanel Name="ViewBars" Visibility="Visible" Width="175">
                    <!-- 5-Hour Rolling Limit -->
                    <StackPanel Name="Row5h" Margin="0,0,0,3.5">
                        <Grid Margin="0,0,0,1">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Ellipse Width="4" Height="4" Fill="#06B6D4" Margin="0,0,3,0"/>
                                <TextBlock Text="5 Horas" FontSize="9.5" FontWeight="SemiBold" Foreground="#94A3B8"/>
                            </StackPanel>
                            <TextBlock Name="Txt5hPct" Text="85%" HorizontalAlignment="Right" FontSize="9.5" FontWeight="Bold" Foreground="#4ADE80"/>
                        </Grid>
                        <Grid Height="4.5">
                            <Border Background="#1E293B" CornerRadius="2.2"/>
                            <ProgressBar Name="Prog5h" Value="85" Maximum="100" Height="4.5" BorderThickness="0" Background="Transparent">
                                <ProgressBar.Foreground>
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                                        <GradientStop Color="#06B6D4" Offset="0"/>
                                        <GradientStop Color="#10B981" Offset="1"/>
                                    </LinearGradientBrush>
                                </ProgressBar.Foreground>
                            </ProgressBar>
                        </Grid>
                        <TextBlock Name="Txt5hReset" Text="~30m (0p)" FontSize="7.5" Foreground="#64748B" Margin="0,1,0,0"/>
                    </StackPanel>

                    <!-- Weekly Quota -->
                    <StackPanel Name="RowWeekly" Margin="0,0,0,3.5">
                        <Grid Margin="0,0,0,1">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Ellipse Width="4" Height="4" Fill="#3B82F6" Margin="0,0,3,0"/>
                                <TextBlock Text="Semana" FontSize="9.5" FontWeight="SemiBold" Foreground="#94A3B8"/>
                            </StackPanel>
                            <TextBlock Name="TxtWeeklyPct" Text="94%" HorizontalAlignment="Right" FontSize="9.5" FontWeight="Bold" Foreground="#38BDF8"/>
                        </Grid>
                        <Grid Height="4.5">
                            <Border Background="#1E293B" CornerRadius="2.2"/>
                            <ProgressBar Name="ProgWeekly" Value="94" Maximum="100" Height="4.5" BorderThickness="0" Background="Transparent">
                                <ProgressBar.Foreground>
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                                        <GradientStop Color="#3B82F6" Offset="0"/>
                                        <GradientStop Color="#8B5CF6" Offset="1"/>
                                    </LinearGradientBrush>
                                </ProgressBar.Foreground>
                            </ProgressBar>
                        </Grid>
                        <TextBlock Name="TxtWeeklyDetails" Text="0 prompts" FontSize="7.5" Foreground="#64748B" Margin="0,1,0,0"/>
                    </StackPanel>

                    <!-- Context Window Tokens -->
                    <StackPanel Name="RowContext" Margin="0,0,0,0">
                        <Grid Margin="0,0,0,1">
                            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                <Ellipse Width="4" Height="4" Fill="#A855F7" Margin="0,0,3,0"/>
                                <TextBlock Text="Contexto" FontSize="9.5" FontWeight="SemiBold" Foreground="#94A3B8"/>
                            </StackPanel>
                            <TextBlock Name="TxtContextTokens" Text="18k (2%)" HorizontalAlignment="Right" FontSize="9" Foreground="#C084FC"/>
                        </Grid>
                        <Grid Height="4">
                            <Border Background="#1E293B" CornerRadius="2"/>
                            <ProgressBar Name="ProgContext" Value="2" Maximum="100" Height="4" BorderThickness="0" Background="Transparent">
                                <ProgressBar.Foreground>
                                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,0">
                                        <GradientStop Color="#8B5CF6" Offset="0"/>
                                        <GradientStop Color="#EC4899" Offset="1"/>
                                    </LinearGradientBrush>
                                </ProgressBar.Foreground>
                            </ProgressBar>
                        </Grid>
                    </StackPanel>
                </StackPanel>

                <!-- ================= VISTA 2: TACOMETROS RADIALES ================= -->
                <StackPanel Name="ViewGauges" Orientation="Horizontal" Visibility="Collapsed" Margin="0">
                    <!-- Gauge 1: 5H -->
                    <StackPanel Name="GaugeItem5h" Margin="2,0,2,0" HorizontalAlignment="Center">
                        <Grid Width="46" Height="46">
                            <Ellipse Stroke="#1E293B" StrokeThickness="4"/>
                            <Ellipse Name="Gauge5hRing" Stroke="#10B981" StrokeThickness="4" StrokeDashArray="21.3 40" RenderTransformOrigin="0.5,0.5">
                                <Ellipse.RenderTransform><RotateTransform Angle="-90"/></Ellipse.RenderTransform>
                            </Ellipse>
                            <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                <TextBlock Name="TxtGauge5hVal" Text="85%" FontWeight="Bold" FontSize="10" HorizontalAlignment="Center" Foreground="#4ADE80"/>
                                <TextBlock Text="5H" FontSize="6.5" FontWeight="SemiBold" Foreground="#64748B" HorizontalAlignment="Center"/>
                            </StackPanel>
                        </Grid>
                    </StackPanel>

                    <!-- Gauge 2: Weekly -->
                    <StackPanel Name="GaugeItemWeekly" Margin="2,0,2,0" HorizontalAlignment="Center">
                        <Grid Width="46" Height="46">
                            <Ellipse Stroke="#1E293B" StrokeThickness="4"/>
                            <Ellipse Name="GaugeWeeklyRing" Stroke="#38BDF8" StrokeThickness="4" StrokeDashArray="29.5 40" RenderTransformOrigin="0.5,0.5">
                                <Ellipse.RenderTransform><RotateTransform Angle="-90"/></Ellipse.RenderTransform>
                            </Ellipse>
                            <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                <TextBlock Name="TxtGaugeWeeklyVal" Text="94%" FontWeight="Bold" FontSize="10" HorizontalAlignment="Center" Foreground="#38BDF8"/>
                                <TextBlock Text="SEM" FontSize="6.5" FontWeight="SemiBold" Foreground="#64748B" HorizontalAlignment="Center"/>
                            </StackPanel>
                        </Grid>
                    </StackPanel>

                    <!-- Gauge 3: Context -->
                    <StackPanel Name="GaugeItemContext" Margin="2,0,2,0" HorizontalAlignment="Center">
                        <Grid Width="46" Height="46">
                            <Ellipse Stroke="#1E293B" StrokeThickness="4"/>
                            <Ellipse Name="GaugeContextRing" Stroke="#A855F7" StrokeThickness="4" StrokeDashArray="2.0 40" RenderTransformOrigin="0.5,0.5">
                                <Ellipse.RenderTransform><RotateTransform Angle="-90"/></Ellipse.RenderTransform>
                            </Ellipse>
                            <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                <TextBlock Name="TxtGaugeContextVal" Text="2%" FontWeight="Bold" FontSize="10" HorizontalAlignment="Center" Foreground="#C084FC"/>
                                <TextBlock Text="CTX" FontSize="6.5" FontWeight="SemiBold" Foreground="#64748B" HorizontalAlignment="Center"/>
                            </StackPanel>
                        </Grid>
                    </StackPanel>
                </StackPanel>

                <!-- ================= VISTA 3: SOLO PORCENTAJES (CHIPS) ================= -->
                <StackPanel Name="ViewChips" Orientation="Horizontal" Visibility="Collapsed" Margin="0">
                    <!-- Chip 1: 5H -->
                    <Border Name="ChipItem5h" Background="#132338" CornerRadius="6" Padding="5,3" Margin="2,0,2,0">
                        <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                            <TextBlock Text="5 HORAS" FontSize="6.5" FontWeight="Bold" Foreground="#64748B" HorizontalAlignment="Center"/>
                            <TextBlock Name="TxtChip5h" Text="85%" FontSize="10" FontWeight="Bold" Foreground="#4ADE80" HorizontalAlignment="Center"/>
                        </StackPanel>
                    </Border>

                    <!-- Chip 2: Weekly -->
                    <Border Name="ChipItemWeekly" Background="#142442" CornerRadius="6" Padding="5,3" Margin="2,0,2,0">
                        <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                            <TextBlock Text="SEMANAL" FontSize="6.5" FontWeight="Bold" Foreground="#64748B" HorizontalAlignment="Center"/>
                            <TextBlock Name="TxtChipWeekly" Text="94%" FontSize="10" FontWeight="Bold" Foreground="#38BDF8" HorizontalAlignment="Center"/>
                        </StackPanel>
                    </Border>

                    <!-- Chip 3: Context -->
                    <Border Name="ChipItemContext" Background="#241838" CornerRadius="6" Padding="5,3" Margin="2,0,2,0">
                        <StackPanel HorizontalAlignment="Center" VerticalAlignment="Center">
                            <TextBlock Text="CONTEXT" FontSize="6.5" FontWeight="Bold" Foreground="#64748B" HorizontalAlignment="Center"/>
                            <TextBlock Name="TxtChipContext" Text="2%" FontSize="10" FontWeight="Bold" Foreground="#C084FC" HorizontalAlignment="Center"/>
                        </StackPanel>
                    </Border>
                </StackPanel>

                <!-- ================= VISTA 4: PANEL DE OPCIONES ================= -->
                <StackPanel Name="ViewSettings" Visibility="Collapsed" Width="175" Margin="0,1,0,1">
                    <TextBlock Text="MODO VISUAL" FontSize="7.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,2"/>
                    <Grid Margin="0,0,0,3">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Button Name="BtnStyleBars" Grid.Column="0" Content="Barras" Height="19" Margin="0,0,1,0"
                                Background="#2563EB" Foreground="#FFFFFF" BorderThickness="0" FontSize="8" FontWeight="SemiBold">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></Button.Resources>
                        </Button>
                        <Button Name="BtnStyleGauges" Grid.Column="1" Content="Tacometros" Height="19" Margin="1,0,1,0"
                                Background="#1E293B" Foreground="#94A3B8" BorderThickness="0" FontSize="8" FontWeight="SemiBold">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></Button.Resources>
                        </Button>
                        <Button Name="BtnStyleChips" Grid.Column="2" Content="Porcentajes" Height="19" Margin="1,0,0,0"
                                Background="#1E293B" Foreground="#94A3B8" BorderThickness="0" FontSize="8" FontWeight="SemiBold">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></Button.Resources>
                        </Button>
                    </Grid>

                    <TextBlock Text="ORIENTACION" FontSize="7.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,2,0,2"/>
                    <Grid Margin="0,0,0,4">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Button Name="BtnOrientH" Grid.Column="0" Content="Horizontal" Height="18" Margin="0,0,1,0"
                                Background="#2563EB" Foreground="#FFFFFF" BorderThickness="0" FontSize="8" FontWeight="SemiBold">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></Button.Resources>
                        </Button>
                        <Button Name="BtnOrientV" Grid.Column="1" Content="Vertical" Height="18" Margin="1,0,0,0"
                                Background="#1E293B" Foreground="#94A3B8" BorderThickness="0" FontSize="8" FontWeight="SemiBold">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></Button.Resources>
                        </Button>
                    </Grid>

                    <CheckBox Name="ChkShow5h" Content="5 Horas" IsChecked="True"/>
                    <CheckBox Name="ChkShowWeekly" Content="Semana" IsChecked="True"/>
                    <CheckBox Name="ChkShowContext" Content="Contexto" IsChecked="True"/>
                    <CheckBox Name="ChkShowSubtitles" Content="Subtitulos" IsChecked="True"/>
                    <CheckBox Name="ChkPinSettings" Content="Siempre arriba" IsChecked="True"/>
                    <CheckBox Name="ChkClickThrough" Content="Modo Fantasma (Click-Through)" IsChecked="False"/>

                    <Grid Margin="0,2,0,1">
                        <TextBlock Text="Opacidad" FontSize="8" Foreground="#94A3B8"/>
                        <TextBlock Name="TxtOpacityVal" Text="90%" HorizontalAlignment="Right" FontSize="8" Foreground="#94A3B8"/>
                    </Grid>
                    <Slider Name="SliderOpacity" Minimum="0.10" Maximum="0.95" Value="0.90" SmallChange="0.05" LargeChange="0.1" Margin="0,0,0,2"/>

                    <Grid Margin="0,1,0,1">
                        <TextBlock Text="Zoom / Escala" FontSize="8" Foreground="#94A3B8"/>
                        <TextBlock Name="TxtScaleVal" Text="100%" HorizontalAlignment="Right" FontSize="8" Foreground="#94A3B8"/>
                    </Grid>
                    <Slider Name="SliderScale" Minimum="0.60" Maximum="1.30" Value="1.0" SmallChange="0.05" LargeChange="0.1" Margin="0,0,0,3"/>

                    <!-- Themes -->
                    <Grid Margin="0,1,0,4">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Button Name="BtnThemeCyan" Grid.Column="0" Content="Cyan" Height="16" Margin="0,0,1,0" Background="#0E7490" Foreground="#FFFFFF" BorderThickness="0" FontSize="7.5">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="2"/></Style></Button.Resources>
                        </Button>
                        <Button Name="BtnThemePurple" Grid.Column="1" Content="Violet" Height="16" Margin="1,0,1,0" Background="#6B21A8" Foreground="#FFFFFF" BorderThickness="0" FontSize="7.5">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="2"/></Style></Button.Resources>
                        </Button>
                        <Button Name="BtnThemeGreen" Grid.Column="2" Content="Matrix" Height="16" Margin="1,0,0,0" Background="#065F46" Foreground="#FFFFFF" BorderThickness="0" FontSize="7.5">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="2"/></Style></Button.Resources>
                        </Button>
                    </Grid>

                    <Button Name="BtnSaveSettings" Content="Guardar" Height="18"
                            Background="#10B981" Foreground="#000000" FontWeight="Bold" BorderThickness="0" FontSize="8">
                        <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></Button.Resources>
                    </Button>
                </StackPanel>
            </StackPanel>
        </Border>
    </Grid>
</Window>
'@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Handles
$mainBorder = $window.FindName("MainBorder")
$rootContainer = $window.FindName("RootContainer")
$uiScale = $window.FindName("UiScale")
$viewBars = $window.FindName("ViewBars")
$viewGauges = $window.FindName("ViewGauges")
$viewChips = $window.FindName("ViewChips")
$viewSettings = $window.FindName("ViewSettings")

$row5h = $window.FindName("Row5h")
$rowWeekly = $window.FindName("RowWeekly")
$rowContext = $window.FindName("RowContext")

$gaugeItem5h = $window.FindName("GaugeItem5h")
$gaugeItemWeekly = $window.FindName("GaugeItemWeekly")
$gaugeItemContext = $window.FindName("GaugeItemContext")

$chipItem5h = $window.FindName("ChipItem5h")
$chipItemWeekly = $window.FindName("ChipItemWeekly")
$chipItemContext = $window.FindName("ChipItemContext")

$chkShow5h = $window.FindName("ChkShow5h")
$chkShowWeekly = $window.FindName("ChkShowWeekly")
$chkShowContext = $window.FindName("ChkShowContext")
$chkShowSubtitles = $window.FindName("ChkShowSubtitles")
$chkPinSettings = $window.FindName("ChkPinSettings")
$chkClickThrough = $window.FindName("ChkClickThrough")

$prog5h = $window.FindName("Prog5h")
$txt5hPct = $window.FindName("Txt5hPct")
$txt5hReset = $window.FindName("Txt5hReset")
$progWeekly = $window.FindName("ProgWeekly")
$txtWeeklyPct = $window.FindName("TxtWeeklyPct")
$txtWeeklyDetails = $window.FindName("TxtWeeklyDetails")
$progContext = $window.FindName("ProgContext")
$txtContextTokens = $window.FindName("TxtContextTokens")

$gauge5hRing = $window.FindName("Gauge5hRing")
$txtGauge5hVal = $window.FindName("TxtGauge5hVal")
$gaugeWeeklyRing = $window.FindName("GaugeWeeklyRing")
$txtGaugeWeeklyVal = $window.FindName("TxtGaugeWeeklyVal")
$gaugeContextRing = $window.FindName("GaugeContextRing")
$txtGaugeContextVal = $window.FindName("TxtGaugeContextVal")

$txtChip5h = $window.FindName("TxtChip5h")
$txtChipWeekly = $window.FindName("TxtChipWeekly")
$txtChipContext = $window.FindName("TxtChipContext")

$btnStyleBars = $window.FindName("BtnStyleBars")
$btnStyleGauges = $window.FindName("BtnStyleGauges")
$btnStyleChips = $window.FindName("BtnStyleChips")

$btnOrientH = $window.FindName("BtnOrientH")
$btnOrientV = $window.FindName("BtnOrientV")

$sliderOpacity = $window.FindName("SliderOpacity")
$txtOpacityVal = $window.FindName("TxtOpacityVal")
$sliderScale = $window.FindName("SliderScale")
$txtScaleVal = $window.FindName("TxtScaleVal")
$btnThemeCyan = $window.FindName("BtnThemeCyan")
$btnThemePurple = $window.FindName("BtnThemePurple")
$btnThemeGreen = $window.FindName("BtnThemeGreen")
$btnSaveSettings = $window.FindName("BtnSaveSettings")

# Context Menu elements
$ctxModeBars = $window.FindName("CtxModeBars")
$ctxModeGauges = $window.FindName("CtxModeGauges")
$ctxModeChips = $window.FindName("CtxModeChips")
$ctxOrientH = $window.FindName("CtxOrientH")
$ctxOrientV = $window.FindName("CtxOrientV")
$ctxSettings = $window.FindName("CtxSettings")
$ctxPin = $window.FindName("CtxPin")
$ctxClickThrough = $window.FindName("CtxClickThrough")
$ctxRefresh = $window.FindName("CtxRefresh")
$ctxClose = $window.FindName("CtxClose")

# Config persistence
$configDir = if ($PSScriptRoot) { $PSScriptRoot } else { "$HOME\AntigravityWidget" }
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
}
$configFile = "$configDir\widget_config.json"
$script:currentMode = "Bars"
$script:currentOrientation = "Horizontal"
$script:isClickThrough = $false

function Set-ClickThroughState ($enable) {
    $script:isClickThrough = [bool]$enable
    $chkClickThrough.IsChecked = $script:isClickThrough
    $ctxClickThrough.IsChecked = $script:isClickThrough
    if ($trayClickThroughItem) { $trayClickThroughItem.Checked = $script:isClickThrough }
    
    # Apply to Win32 handle
    try {
        $helper = [System.Windows.Interop.WindowInteropHelper]::new($window)
        $hwnd = $helper.Handle
        if ($hwnd -ne [IntPtr]::Zero) {
            [Win32WindowTools]::SetClickThrough($hwnd, $script:isClickThrough)
        }
    } catch {}
}

function Set-WidgetOrientation ($orientation) {
    $script:currentOrientation = if ($orientation -eq "Vertical") { "Vertical" } else { "Horizontal" }

    $inactiveBg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
    $inactiveFg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
    $activeBg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
    $activeFg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")

    if ($script:currentOrientation -eq "Vertical") {
        $viewGauges.Orientation = [System.Windows.Controls.Orientation]::Vertical
        $viewChips.Orientation = [System.Windows.Controls.Orientation]::Vertical

        $gaugeItem5h.Margin = [System.Windows.Thickness]::new(0, 2, 0, 2)
        $gaugeItemWeekly.Margin = [System.Windows.Thickness]::new(0, 2, 0, 2)
        $gaugeItemContext.Margin = [System.Windows.Thickness]::new(0, 2, 0, 2)

        $chipItem5h.Margin = [System.Windows.Thickness]::new(0, 2, 0, 2)
        $chipItemWeekly.Margin = [System.Windows.Thickness]::new(0, 2, 0, 2)
        $chipItemContext.Margin = [System.Windows.Thickness]::new(0, 2, 0, 2)

        $btnOrientV.Background = $activeBg
        $btnOrientV.Foreground = $activeFg
        $btnOrientH.Background = $inactiveBg
        $btnOrientH.Foreground = $inactiveFg
    } else {
        $viewGauges.Orientation = [System.Windows.Controls.Orientation]::Horizontal
        $viewChips.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        $gaugeItem5h.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)
        $gaugeItemWeekly.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)
        $gaugeItemContext.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)

        $chipItem5h.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)
        $chipItemWeekly.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)
        $chipItemContext.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)

        $btnOrientH.Background = $activeBg
        $btnOrientH.Foreground = $activeFg
        $btnOrientV.Background = $inactiveBg
        $btnOrientV.Foreground = $inactiveFg
    }
}

function Set-WidgetMode ($mode) {
    $script:currentMode = $mode
    
    $viewBars.Visibility = [System.Windows.Visibility]::Collapsed
    $viewGauges.Visibility = [System.Windows.Visibility]::Collapsed
    $viewChips.Visibility = [System.Windows.Visibility]::Collapsed
    $viewSettings.Visibility = [System.Windows.Visibility]::Collapsed

    $inactiveBg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
    $inactiveFg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
    $activeBg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
    $activeFg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")

    $btnStyleBars.Background = $inactiveBg
    $btnStyleBars.Foreground = $inactiveFg
    $btnStyleGauges.Background = $inactiveBg
    $btnStyleGauges.Foreground = $inactiveFg
    $btnStyleChips.Background = $inactiveBg
    $btnStyleChips.Foreground = $inactiveFg

    switch ($mode) {
        "Gauges" {
            $viewGauges.Visibility = [System.Windows.Visibility]::Visible
            $btnStyleGauges.Background = $activeBg
            $btnStyleGauges.Foreground = $activeFg
        }
        "Chips" {
            $viewChips.Visibility = [System.Windows.Visibility]::Visible
            $btnStyleChips.Background = $activeBg
            $btnStyleChips.Foreground = $activeFg
        }
        Default {
            $script:currentMode = "Bars"
            $viewBars.Visibility = [System.Windows.Visibility]::Visible
            $btnStyleBars.Background = $activeBg
            $btnStyleBars.Foreground = $activeFg
        }
    }
    Set-WidgetOrientation $script:currentOrientation
    Apply-VisibilityRules
}

function Apply-VisibilityRules {
    $v5h = if ($chkShow5h.IsChecked) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $vW = if ($chkShowWeekly.IsChecked) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $vCtx = if ($chkShowContext.IsChecked) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $vSub = if ($chkShowSubtitles.IsChecked) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }

    $row5h.Visibility = $v5h
    $rowWeekly.Visibility = $vW
    $rowContext.Visibility = $vCtx

    $gaugeItem5h.Visibility = $v5h
    $gaugeItemWeekly.Visibility = $vW
    $gaugeItemContext.Visibility = $vCtx

    $chipItem5h.Visibility = $v5h
    $chipItemWeekly.Visibility = $vW
    $chipItemContext.Visibility = $vCtx

    $txt5hReset.Visibility = $vSub
    $txtWeeklyDetails.Visibility = $vSub
}

$chkShow5h.Add_Checked({ Apply-VisibilityRules })
$chkShow5h.Add_Unchecked({ Apply-VisibilityRules })
$chkShowWeekly.Add_Checked({ Apply-VisibilityRules })
$chkShowWeekly.Add_Unchecked({ Apply-VisibilityRules })
$chkShowContext.Add_Checked({ Apply-VisibilityRules })
$chkShowContext.Add_Unchecked({ Apply-VisibilityRules })
$chkShowSubtitles.Add_Checked({ Apply-VisibilityRules })
$chkShowSubtitles.Add_Unchecked({ Apply-VisibilityRules })

function Save-WidgetConfig {
    try {
        $cfgObj = [PSCustomObject]@{
            Opacity       = $sliderOpacity.Value
            Scale         = $sliderScale.Value
            Mode          = $script:currentMode
            Orientation   = $script:currentOrientation
            Left          = $window.Left
            Top           = $window.Top
            Pinned        = $window.Topmost
            Show5h        = $chkShow5h.IsChecked
            ShowWeekly    = $chkShowWeekly.IsChecked
            ShowContext   = $chkShowContext.IsChecked
            ShowSubtitles = $chkShowSubtitles.IsChecked
            ClickThrough  = $script:isClickThrough
        }
        $cfgObj | ConvertTo-Json | Set-Content $configFile -Force
    } catch {}
}

# Load saved preferences
if (Test-Path $configFile) {
    try {
        $cfg = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($cfg.Opacity) {
            $sliderOpacity.Value = $cfg.Opacity
            $mainBorder.Background.Opacity = $cfg.Opacity
            $txtOpacityVal.Text = ([string][int]($cfg.Opacity * 100)) + "%"
        }
        if ($cfg.Scale) {
            $sliderScale.Value = $cfg.Scale
            $uiScale.ScaleX = $cfg.Scale
            $uiScale.ScaleY = $cfg.Scale
            $txtScaleVal.Text = ([string][int]($cfg.Scale * 100)) + "%"
        }
        if ($cfg.Left -ne $null -and $cfg.Top -ne $null) {
            $window.WindowStartupLocation = [System.Windows.WindowStartupLocation]::Manual
            $window.Left = [double]$cfg.Left
            $window.Top = [double]$cfg.Top
        }
        if ($cfg.Pinned -ne $null) {
            $window.Topmost = [bool]$cfg.Pinned
            $ctxPin.IsChecked = $window.Topmost
            $chkPinSettings.IsChecked = $window.Topmost
        }
        if ($cfg.Show5h -ne $null) { $chkShow5h.IsChecked = [bool]$cfg.Show5h }
        if ($cfg.ShowWeekly -ne $null) { $chkShowWeekly.IsChecked = [bool]$cfg.ShowWeekly }
        if ($cfg.ShowContext -ne $null) { $chkShowContext.IsChecked = [bool]$cfg.ShowContext }
        if ($cfg.ShowSubtitles -ne $null) { $chkShowSubtitles.IsChecked = [bool]$cfg.ShowSubtitles }
        if ($cfg.ClickThrough -ne $null) { $script:isClickThrough = [bool]$cfg.ClickThrough }
        if ($cfg.Orientation) { $script:currentOrientation = $cfg.Orientation }
        if ($cfg.Mode) { Set-WidgetMode $cfg.Mode } else { Set-WidgetMode "Bars" }
    } catch {
        Set-WidgetMode "Bars"
    }
} else {
    Set-WidgetMode "Bars"
}

# Smooth Delta-based Mouse Dragging (Does NOT trigger Windows 11 Snap Assist / Quarter Screen Snap!)
$script:isDragging = $false
$script:startScreenPos = [System.Drawing.Point]::new(0,0)
$script:startWindowLeft = 0
$script:startWindowTop = 0

$mainBorder.Add_MouseLeftButtonDown({
    if (-not $script:isClickThrough) {
        $script:isDragging = $true
        $script:startScreenPos = [System.Windows.Forms.Cursor]::Position
        $script:startWindowLeft = $window.Left
        $script:startWindowTop = $window.Top
        $mainBorder.CaptureMouse() | Out-Null
    }
})

$mainBorder.Add_MouseMove({
    if ($script:isDragging) {
        $cur = [System.Windows.Forms.Cursor]::Position
        $deltaX = $cur.X - $script:startScreenPos.X
        $deltaY = $cur.Y - $script:startScreenPos.Y
        $window.Left = $script:startWindowLeft + $deltaX
        $window.Top = $script:startWindowTop + $deltaY
    }
})

$mainBorder.Add_MouseLeftButtonUp({
    if ($script:isDragging) {
        $script:isDragging = $false
        $mainBorder.ReleaseMouseCapture()
        Save-WidgetConfig
    }
})

# Middle Click toggles Orientation (Horizontal <-> Vertical)
$mainBorder.Add_MouseDown({
    if ($args[0].ChangedButton -eq [System.Windows.Input.MouseButton]::Middle) {
        if ($script:currentOrientation -eq "Horizontal") {
            Set-WidgetOrientation "Vertical"
        } else {
            Set-WidgetOrientation "Horizontal"
        }
        Save-WidgetConfig
    }
})

function Toggle-Pin {
    $window.Topmost = -not $window.Topmost
    $ctxPin.IsChecked = $window.Topmost
    $chkPinSettings.IsChecked = $window.Topmost
    if ($trayPinItem) { $trayPinItem.Checked = $window.Topmost }
    Save-WidgetConfig
}

$chkPinSettings.Add_Checked({ if (-not $window.Topmost) { Toggle-Pin } })
$chkPinSettings.Add_Unchecked({ if ($window.Topmost) { Toggle-Pin } })

function Toggle-Settings {
    if ($viewSettings.Visibility -eq [System.Windows.Visibility]::Visible) {
        Set-WidgetMode $script:currentMode
    } else {
        $viewBars.Visibility = [System.Windows.Visibility]::Collapsed
        $viewGauges.Visibility = [System.Windows.Visibility]::Collapsed
        $viewChips.Visibility = [System.Windows.Visibility]::Collapsed
        $viewSettings.Visibility = [System.Windows.Visibility]::Visible
    }
}

function Close-WidgetApp {
    Save-WidgetConfig
    if ($notifyIcon) {
        $notifyIcon.Visible = $false
        $notifyIcon.Dispose()
    }
    $window.Close()
}

$btnSaveSettings.Add_Click({
    Set-WidgetMode $script:currentMode
    Save-WidgetConfig
})

# Settings Mode Buttons
$btnStyleBars.Add_Click({ Set-WidgetMode "Bars"; Save-WidgetConfig })
$btnStyleGauges.Add_Click({ Set-WidgetMode "Gauges"; Save-WidgetConfig })
$btnStyleChips.Add_Click({ Set-WidgetMode "Chips"; Save-WidgetConfig })

# Settings Orientation Buttons
$btnOrientH.Add_Click({ Set-WidgetOrientation "Horizontal"; Save-WidgetConfig })
$btnOrientV.Add_Click({ Set-WidgetOrientation "Vertical"; Save-WidgetConfig })

# Context Menu Items (Right Click on Widget)
$ctxModeBars.Add_Click({ Set-WidgetMode "Bars"; Save-WidgetConfig })
$ctxModeGauges.Add_Click({ Set-WidgetMode "Gauges"; Save-WidgetConfig })
$ctxModeChips.Add_Click({ Set-WidgetMode "Chips"; Save-WidgetConfig })

$ctxOrientH.Add_Click({ Set-WidgetOrientation "Horizontal"; Save-WidgetConfig })
$ctxOrientV.Add_Click({ Set-WidgetOrientation "Vertical"; Save-WidgetConfig })

$ctxSettings.Add_Click({ Toggle-Settings })
$ctxPin.IsChecked = $window.Topmost
$ctxPin.Add_Click({ Toggle-Pin })
$ctxClickThrough.Add_Click({ Set-ClickThroughState (-not $script:isClickThrough); Save-WidgetConfig })
$ctxRefresh.Add_Click({ Update-WidgetData })
$ctxClose.Add_Click({ Close-WidgetApp })

# Checkbox in settings for Click-Through
$chkClickThrough.Add_Checked({ Set-ClickThroughState $true })
$chkClickThrough.Add_Unchecked({ Set-ClickThroughState $false })

# Sliders
$sliderOpacity.Add_ValueChanged({
    $mainBorder.Background.Opacity = $sliderOpacity.Value
    $txtOpacityVal.Text = ([string][int]($sliderOpacity.Value * 100)) + "%"
})

$sliderScale.Add_ValueChanged({
    $uiScale.ScaleX = $sliderScale.Value
    $uiScale.ScaleY = $sliderScale.Value
    $txtScaleVal.Text = ([string][int]($sliderScale.Value * 100)) + "%"
})

# Themes
$btnThemeCyan.Add_Click({
    $grad = [System.Windows.Media.LinearGradientBrush]::new()
    $grad.StartPoint = [System.Windows.Point]::new(0,0)
    $grad.EndPoint = [System.Windows.Point]::new(1,1)
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#60A5FA"), 0.0))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#1E293B"), 0.5))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#00F2FE"), 1.0))
    $mainBorder.BorderBrush = $grad
})

$btnThemePurple.Add_Click({
    $grad = [System.Windows.Media.LinearGradientBrush]::new()
    $grad.StartPoint = [System.Windows.Point]::new(0,0)
    $grad.EndPoint = [System.Windows.Point]::new(1,1)
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#C084FC"), 0.0))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#1E1B4B"), 0.5))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#F43F5E"), 1.0))
    $mainBorder.BorderBrush = $grad
})

$btnThemeGreen.Add_Click({
    $grad = [System.Windows.Media.LinearGradientBrush]::new()
    $grad.StartPoint = [System.Windows.Point]::new(0,0)
    $grad.EndPoint = [System.Windows.Point]::new(1,1)
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#34D399"), 0.0))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#064E3B"), 0.5))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#A3E635"), 1.0))
    $mainBorder.BorderBrush = $grad
})

# ================= SYSTEM TRAY / NOTIFY ICON =================
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip

$bmp = New-Object System.Drawing.Bitmap(16, 16)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$brushBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(30, 58, 138))
$penBorder = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(56, 189, 248), 1.5)
$brushDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(34, 197, 94))
$g.FillEllipse($brushBg, 1, 1, 13, 13)
$g.DrawEllipse($penBorder, 1, 1, 13, 13)
$g.FillEllipse($brushDot, 5, 5, 5, 5)
$g.Dispose()
$hIcon = $bmp.GetHicon()
$notifyIcon.Icon = [System.Drawing.Icon]::FromHandle($hIcon)
$notifyIcon.Text = "Antigravity Widget"
$notifyIcon.Visible = $true

# Context menu items
$trayShowItem = $contextMenu.Items.Add("Mostrar / Ocultar")
$trayShowItem.Add_Click({
    if ($window.Visibility -eq [System.Windows.Visibility]::Visible) {
        $window.Visibility = [System.Windows.Visibility]::Hidden
    } else {
        $window.Visibility = [System.Windows.Visibility]::Visible
        $window.Activate()
    }
})

$trayModesMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Cambiar Vista")
$trayModeBars = $trayModesMenu.DropDownItems.Add("Barras")
$trayModeBars.Add_Click({ Set-WidgetMode "Bars"; Save-WidgetConfig })
$trayModeGauges = $trayModesMenu.DropDownItems.Add("Tacometros")
$trayModeGauges.Add_Click({ Set-WidgetMode "Gauges"; Save-WidgetConfig })
$trayModeChips = $trayModesMenu.DropDownItems.Add("Solo Porcentajes")
$trayModeChips.Add_Click({ Set-WidgetMode "Chips"; Save-WidgetConfig })
$contextMenu.Items.Add($trayModesMenu) | Out-Null

$trayOrientMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Orientacion")
$trayOrientH = $trayOrientMenu.DropDownItems.Add("Horizontal")
$trayOrientH.Add_Click({ Set-WidgetOrientation "Horizontal"; Save-WidgetConfig })
$trayOrientV = $trayOrientMenu.DropDownItems.Add("Vertical")
$trayOrientV.Add_Click({ Set-WidgetOrientation "Vertical"; Save-WidgetConfig })
$contextMenu.Items.Add($trayOrientMenu) | Out-Null

$traySettingsItem = $contextMenu.Items.Add("Opciones y Estilo")
$traySettingsItem.Add_Click({
    $window.Visibility = [System.Windows.Visibility]::Visible
    $window.Activate()
    Toggle-Settings
})

$trayPinItem = $contextMenu.Items.Add("Siempre arriba")
$trayPinItem.CheckOnClick = $true
$trayPinItem.Checked = $window.Topmost
$trayPinItem.Add_Click({ Toggle-Pin })

$trayClickThroughItem = $contextMenu.Items.Add("Modo Fantasma (Click-Through)")
$trayClickThroughItem.CheckOnClick = $true
$trayClickThroughItem.Checked = $script:isClickThrough
$trayClickThroughItem.Add_Click({
    Set-ClickThroughState $trayClickThroughItem.Checked
    Save-WidgetConfig
})

$contextMenu.Items.Add("-") | Out-Null

$trayRefreshItem = $contextMenu.Items.Add("Actualizar ahora")
$trayRefreshItem.Add_Click({ Update-WidgetData })

$contextMenu.Items.Add("-") | Out-Null

$trayCloseItem = $contextMenu.Items.Add("Cerrar")
$trayCloseItem.Add_Click({ Close-WidgetApp })

$notifyIcon.ContextMenuStrip = $contextMenu
$notifyIcon.Add_DoubleClick({
    if ($window.Visibility -eq [System.Windows.Visibility]::Visible) {
        $window.Visibility = [System.Windows.Visibility]::Hidden
    } else {
        $window.Visibility = [System.Windows.Visibility]::Visible
        $window.Activate()
    }
})

# Window Loaded & cleanup event
$window.Add_SourceInitialized({
    if ($script:isClickThrough) {
        Set-ClickThroughState $true
    }
})

$window.Add_Closed({
    if ($notifyIcon) {
        $notifyIcon.Visible = $false
        $notifyIcon.Dispose()
    }
})

# Logic for data updates
$candidateGeminiDirs = @(
    "$HOME\.gemini\antigravity-ide",
    "$HOME\.gemini\antigravity-cli",
    "$HOME\.gemini"
)

function Update-WidgetData {
    try {
        $now = [DateTime]::UtcNow
        
        # 1. Active conversation context
        $latestTranscript = $null
        foreach ($dir in $candidateGeminiDirs) {
            $brainDir = "$dir\brain"
            if (Test-Path $brainDir) {
                $found = Get-ChildItem -Path "$brainDir\*\.system_generated\logs\transcript.jsonl" -ErrorAction SilentlyContinue |
                         Sort-Object LastWriteTime -Descending | Select-Object -First 1
                if ($found -and (-not $latestTranscript -or $found.LastWriteTime -gt $latestTranscript.LastWriteTime)) {
                    $latestTranscript = $found
                }
            }
        }
        
        $contextTokens = 3000
        if ($latestTranscript) {
            $fileSize = $latestTranscript.Length
            $contextTokens = [Math]::Max(1000, [int]($fileSize / 4))
        }
        
        $maxContext = 1000000
        $contextPct = [Math]::Round(($contextTokens / $maxContext) * 100, 1)
        $progContext.Value = [Math]::Min(100, [Math]::Max(1, $contextPct))
        
        if ($contextTokens -ge 1000) {
            $tokenStr = ([string][Math]::Round($contextTokens / 1000, 1)) + "k"
        } else {
            $tokenStr = [string]$contextTokens
        }
        $txtContextTokens.Text = "$tokenStr (" + [string]$contextPct + "%)"
        $txtGaugeContextVal.Text = [string]$contextPct + "%"
        $txtChipContext.Text = [string]$contextPct + "%"
        
        # 2. Rolling 5-hour and Weekly usage
        $fiveHoursAgo = $now.AddHours(-5)
        $weeklyAgo = $now.AddDays(-7)
        
        $recentCount5h = 0
        $recentCountWeekly = 0
        
        foreach ($dir in $candidateGeminiDirs) {
            $hPath = "$dir\history.jsonl"
            if (Test-Path $hPath) {
                $lines = Get-Content $hPath -Tail 300 -ErrorAction SilentlyContinue
                foreach ($line in $lines) {
                    if ($line -match '"timestamp":(\d+)') {
                        $ts = [long]$matches[1]
                        $entryDate = [DateTimeOffset]::FromUnixTimeMilliseconds($ts).UtcDateTime
                        if ($entryDate -ge $fiveHoursAgo) {
                            $recentCount5h++
                        }
                        if ($entryDate -ge $weeklyAgo) {
                            $recentCountWeekly++
                        }
                    }
                }
            }
        }
        
        # 5-hour quota
        $max5hRequests = 50
        $used5hPct = [Math]::Min(100, ($recentCount5h / $max5hRequests) * 100)
        $remain5hPct = [Math]::Max(0, 100 - [int]$used5hPct)
        
        $prog5h.Value = $remain5hPct
        $txt5hPct.Text = [string]$remain5hPct + "%"
        $txtGauge5hVal.Text = [string]$remain5hPct + "%"
        $txtChip5h.Text = [string]$remain5hPct + "%"
        
        # Exact Radial Gauge ring calculation (Perimeter in stroke units = 31.416)
        $d5h = [Math]::Max(0.1, [Math]::Min(31.4, ($remain5hPct / 100.0) * 31.416))
        $gauge5hRing.StrokeDashArray = [System.Windows.Media.DoubleCollection]::new(@($d5h, 40))

        if ($remain5hPct -ge 50) {
            $colorHex = "#4ADE80"
        } elseif ($remain5hPct -ge 20) {
            $colorHex = "#FACC15"
        } else {
            $colorHex = "#F87171"
        }
        $brush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($colorHex)
        $txt5hPct.Foreground = $brush
        $txtGauge5hVal.Foreground = $brush
        $txtChip5h.Foreground = $brush
        $gauge5hRing.Stroke = $brush
        
        $nextResetMin = 60 - ($now.Minute % 60)
        $txt5hReset.Text = "~" + [string]$nextResetMin + "m (" + [string]$recentCount5h + " p)"
        
        # Weekly quota
        $maxWeekly = 500
        $usedWeeklyPct = [Math]::Min(100, ($recentCountWeekly / $maxWeekly) * 100)
        $remainWeeklyPct = [Math]::Max(0, 100 - [int]$usedWeeklyPct)
        
        $progWeekly.Value = $remainWeeklyPct
        $txtWeeklyPct.Text = [string]$remainWeeklyPct + "%"
        $txtGaugeWeeklyVal.Text = [string]$remainWeeklyPct + "%"
        $txtChipWeekly.Text = [string]$remainWeeklyPct + "%"
        
        $dWeekly = [Math]::Max(0.1, [Math]::Min(31.4, ($remainWeeklyPct / 100.0) * 31.416))
        $gaugeWeeklyRing.StrokeDashArray = [System.Windows.Media.DoubleCollection]::new(@($dWeekly, 40))
        $txtWeeklyDetails.Text = [string]$recentCountWeekly + " prompts"
        
        # Context Gauge ring
        $dCtx = [Math]::Max(0.1, [Math]::Min(31.4, ($contextPct / 100.0) * 31.416))
        $gaugeContextRing.StrokeDashArray = [System.Windows.Media.DoubleCollection]::new(@($dCtx, 40))
        
        $notifyIcon.Text = "Antigravity (5h: " + [string]$remain5hPct + "% | Sem: " + [string]$remainWeeklyPct + "%)"
        
    } catch { }
}

# Initial trigger
Update-WidgetData

# Real-time background dispatcher timer
$timer = [System.Windows.Threading.DispatcherTimer]::new()
$timer.Interval = [TimeSpan]::FromSeconds(4)
$timer.Add_Tick({
    Update-WidgetData
})
$timer.Start()

# Display GUI
$window.ShowDialog() | Out-Null
