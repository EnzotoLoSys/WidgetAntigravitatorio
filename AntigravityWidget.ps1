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

# ================= MAIN WIDGET XAML (PURE COMPACT GADGET) =================
$widgetXaml = @'
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
                    <MenuItem Name="CtxResetPos" Header="Restablecer Posicion (Centrar)"/>
                    <Separator Background="#334155"/>
                    <MenuItem Name="CtxAutoStart" Header="Iniciar con Windows" IsCheckable="True"/>
                    <MenuItem Name="CtxPin" Header="Siempre arriba" IsCheckable="True"/>
                    <MenuItem Name="CtxClickThrough" Header="Modo Fantasma (Click-Through)" IsCheckable="True"/>
                    <MenuItem Name="CtxSettings" Header="Preferencias..."/>
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
            </StackPanel>
        </Border>
    </Grid>
</Window>
'@

# ================= STANDALONE SETTINGS WINDOW XAML =================
$settingsXaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Preferencias - Antigravity Widget"
        Width="320"
        SizeToContent="Height"
        ResizeMode="NoResize"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        WindowStartupLocation="CenterScreen">
    
    <Window.Resources>
        <Style TargetType="TextBlock">
            <Setter Property="FontFamily" Value="Segoe UI, Segoe UI Variable, Arial"/>
            <Setter Property="Foreground" Value="#E2E8F0"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="FontFamily" Value="Segoe UI"/>
            <Setter Property="Foreground" Value="#CBD5E1"/>
            <Setter Property="FontSize" Value="10.5"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Margin" Value="0,2.5,0,2.5"/>
        </Style>
    </Window.Resources>

    <Border Margin="6" Background="#0F172A" BorderBrush="#334155" BorderThickness="1.2" CornerRadius="12">
        <Border.Effect>
            <DropShadowEffect BlurRadius="16" ShadowDepth="4" Direction="270" Color="#000000" Opacity="0.9"/>
        </Border.Effect>
        <StackPanel Margin="14,12,14,14">
            
            <!-- Header with Title and Close 'X' -->
            <Grid Margin="0,0,0,10">
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <Ellipse Width="7" Height="7" Fill="#38BDF8" Margin="0,0,6,0"/>
                    <TextBlock Text="Preferencias del Widget" FontSize="12.5" FontWeight="Bold" Foreground="#F8FAFC"/>
                </StackPanel>
                <Button Name="DlgBtnCloseX" Content="X" Width="22" Height="22" HorizontalAlignment="Right"
                        Background="#1E293B" Foreground="#94A3B8" BorderThickness="0" FontWeight="Bold" FontSize="10" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="11"/></Style></Button.Resources>
                </Button>
            </Grid>

            <!-- Section 1: Modo Visual -->
            <TextBlock Text="MODO VISUAL" FontSize="8.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,2,0,4"/>
            <Grid Margin="0,0,0,6">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Button Name="DlgBtnBars" Grid.Column="0" Content="Barras" Height="22" Margin="0,0,2,0"
                        Background="#2563EB" Foreground="#FFFFFF" BorderThickness="0" FontSize="9.5" FontWeight="SemiBold" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
                </Button>
                <Button Name="DlgBtnGauges" Grid.Column="1" Content="Tacometros" Height="22" Margin="1,0,1,0"
                        Background="#1E293B" Foreground="#94A3B8" BorderThickness="0" FontSize="9.5" FontWeight="SemiBold" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
                </Button>
                <Button Name="DlgBtnChips" Grid.Column="2" Content="Porcentajes" Height="22" Margin="2,0,0,0"
                        Background="#1E293B" Foreground="#94A3B8" BorderThickness="0" FontSize="9.5" FontWeight="SemiBold" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
                </Button>
            </Grid>

            <!-- Section 2: Orientacion -->
            <TextBlock Text="ORIENTACION" FontSize="8.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,4,0,4"/>
            <Grid Margin="0,0,0,8">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Button Name="DlgBtnOrientH" Grid.Column="0" Content="Horizontal (Fila)" Height="22" Margin="0,0,2,0"
                        Background="#2563EB" Foreground="#FFFFFF" BorderThickness="0" FontSize="9.5" FontWeight="SemiBold" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
                </Button>
                <Button Name="DlgBtnOrientV" Grid.Column="1" Content="Vertical (Columna)" Height="22" Margin="2,0,0,0"
                        Background="#1E293B" Foreground="#94A3B8" BorderThickness="0" FontSize="9.5" FontWeight="SemiBold" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="4"/></Style></Button.Resources>
                </Button>
            </Grid>

            <!-- Section 3: Opciones / Toggles -->
            <TextBlock Text="OPCIONES GENERALES" FontSize="8.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,2,0,3"/>
            <CheckBox Name="DlgChkAutoStart" Content="Iniciar automaticamente con Windows"/>
            <CheckBox Name="DlgChkPin" Content="Siempre arriba (Topmost)" IsChecked="True"/>
            <CheckBox Name="DlgChkClickThrough" Content="Modo Fantasma (Click-Through)"/>
            <CheckBox Name="DlgChkShow5h" Content="Mostrar Limite 5 Horas" IsChecked="True"/>
            <CheckBox Name="DlgChkShowWeekly" Content="Mostrar Limite Semanal" IsChecked="True"/>
            <CheckBox Name="DlgChkShowContext" Content="Mostrar Tokens de Contexto" IsChecked="True"/>
            <CheckBox Name="DlgChkShowSubtitles" Content="Mostrar Subtitulos y Detalles" IsChecked="True"/>

            <!-- Section 4: Sliders -->
            <Grid Margin="0,6,0,2">
                <TextBlock Text="Opacidad del Widget (Todo)" FontSize="9.5" Foreground="#94A3B8"/>
                <TextBlock Name="DlgTxtOpacityVal" Text="90%" HorizontalAlignment="Right" FontSize="9.5" FontWeight="Bold" Foreground="#38BDF8"/>
            </Grid>
            <Slider Name="DlgSliderOpacity" Minimum="0.15" Maximum="1.00" Value="0.90" SmallChange="0.05" LargeChange="0.1" Margin="0,0,0,4"/>

            <Grid Margin="0,2,0,2">
                <TextBlock Text="Escala / Tamano" FontSize="9.5" Foreground="#94A3B8"/>
                <TextBlock Name="DlgTxtScaleVal" Text="100%" HorizontalAlignment="Right" FontSize="9.5" FontWeight="Bold" Foreground="#38BDF8"/>
            </Grid>
            <Slider Name="DlgSliderScale" Minimum="0.60" Maximum="1.40" Value="1.0" SmallChange="0.05" LargeChange="0.1" Margin="0,0,0,8"/>

            <!-- Section 5: Temas -->
            <TextBlock Text="TEMA DE COLOR" FontSize="8.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,2,0,4"/>
            <Grid Margin="0,0,0,12">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Button Name="DlgBtnThemeCyan" Grid.Column="0" Content="Cyan" Height="20" Margin="0,0,2,0" Background="#0E7490" Foreground="#FFFFFF" BorderThickness="0" FontSize="9" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></Button.Resources>
                </Button>
                <Button Name="DlgBtnThemePurple" Grid.Column="1" Content="Violet" Height="20" Margin="1,0,1,0" Background="#6B21A8" Foreground="#FFFFFF" BorderThickness="0" FontSize="9" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></Button.Resources>
                </Button>
                <Button Name="DlgBtnThemeGreen" Grid.Column="2" Content="Matrix" Height="20" Margin="2,0,0,0" Background="#065F46" Foreground="#FFFFFF" BorderThickness="0" FontSize="9" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="3"/></Style></Button.Resources>
                </Button>
            </Grid>

            <!-- Actions Footer -->
            <Grid Margin="0,2,0,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                <Button Name="DlgBtnResetPos" Grid.Column="0" Content="Centrar Pantalla" Height="26" Margin="0,0,3,0"
                        Background="#1E293B" Foreground="#E2E8F0" BorderThickness="1" BorderBrush="#334155" FontSize="9.5" FontWeight="SemiBold" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="5"/></Style></Button.Resources>
                </Button>
                <Button Name="DlgBtnSave" Grid.Column="1" Content="Guardar y Salir" Height="26" Margin="3,0,0,0"
                        Background="#10B981" Foreground="#042F2E" FontWeight="Bold" BorderThickness="0" FontSize="10" Cursor="Hand">
                    <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="5"/></Style></Button.Resources>
                </Button>
            </Grid>

        </StackPanel>
    </Border>
</Window>
'@

# Parse Windows
$readerWidget = [System.Xml.XmlReader]::Create([System.IO.StringReader]$widgetXaml)
$window = [System.Windows.Markup.XamlReader]::Load($readerWidget)

$readerSettings = [System.Xml.XmlReader]::Create([System.IO.StringReader]$settingsXaml)
$settingsWindow = [System.Windows.Markup.XamlReader]::Load($readerSettings)

# Widget UI Handles
$mainBorder = $window.FindName("MainBorder")
$rootContainer = $window.FindName("RootContainer")
$uiScale = $window.FindName("UiScale")
$viewBars = $window.FindName("ViewBars")
$viewGauges = $window.FindName("ViewGauges")
$viewChips = $window.FindName("ViewChips")

$row5h = $window.FindName("Row5h")
$rowWeekly = $window.FindName("RowWeekly")
$rowContext = $window.FindName("RowContext")

$gaugeItem5h = $window.FindName("GaugeItem5h")
$gaugeItemWeekly = $window.FindName("GaugeItemWeekly")
$gaugeItemContext = $window.FindName("GaugeItemContext")

$chipItem5h = $window.FindName("ChipItem5h")
$chipItemWeekly = $window.FindName("ChipItemWeekly")
$chipItemContext = $window.FindName("ChipItemContext")

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

# Context Menu elements
$ctxModeBars = $window.FindName("CtxModeBars")
$ctxModeGauges = $window.FindName("CtxModeGauges")
$ctxModeChips = $window.FindName("CtxModeChips")
$ctxOrientH = $window.FindName("CtxOrientH")
$ctxOrientV = $window.FindName("CtxOrientV")
$ctxResetPos = $window.FindName("CtxResetPos")
$ctxAutoStart = $window.FindName("CtxAutoStart")
$ctxPin = $window.FindName("CtxPin")
$ctxClickThrough = $window.FindName("CtxClickThrough")
$ctxSettings = $window.FindName("CtxSettings")
$ctxRefresh = $window.FindName("CtxRefresh")
$ctxClose = $window.FindName("CtxClose")

# Settings Dialog Handles
$dlgBtnCloseX = $settingsWindow.FindName("DlgBtnCloseX")
$dlgBtnBars = $settingsWindow.FindName("DlgBtnBars")
$dlgBtnGauges = $settingsWindow.FindName("DlgBtnGauges")
$dlgBtnChips = $settingsWindow.FindName("DlgBtnChips")
$dlgBtnOrientH = $settingsWindow.FindName("DlgBtnOrientH")
$dlgBtnOrientV = $settingsWindow.FindName("DlgBtnOrientV")

$dlgChkAutoStart = $settingsWindow.FindName("DlgChkAutoStart")
$dlgChkPin = $settingsWindow.FindName("DlgChkPin")
$dlgChkClickThrough = $settingsWindow.FindName("DlgChkClickThrough")
$dlgChkShow5h = $settingsWindow.FindName("DlgChkShow5h")
$dlgChkShowWeekly = $settingsWindow.FindName("DlgChkShowWeekly")
$dlgChkShowContext = $settingsWindow.FindName("DlgChkShowContext")
$dlgChkShowSubtitles = $settingsWindow.FindName("DlgChkShowSubtitles")

$dlgSliderOpacity = $settingsWindow.FindName("DlgSliderOpacity")
$dlgTxtOpacityVal = $settingsWindow.FindName("DlgTxtOpacityVal")
$dlgSliderScale = $settingsWindow.FindName("DlgSliderScale")
$dlgTxtScaleVal = $settingsWindow.FindName("DlgTxtScaleVal")

$dlgBtnThemeCyan = $settingsWindow.FindName("DlgBtnThemeCyan")
$dlgBtnThemePurple = $settingsWindow.FindName("DlgBtnThemePurple")
$dlgBtnThemeGreen = $settingsWindow.FindName("DlgBtnThemeGreen")
$dlgBtnResetPos = $settingsWindow.FindName("DlgBtnResetPos")
$dlgBtnSave = $settingsWindow.FindName("DlgBtnSave")

# Configuration and Paths
$configDir = if ($PSScriptRoot) { $PSScriptRoot } else { "$HOME\AntigravityWidget" }
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
}
$configFile = "$configDir\widget_config.json"
$startupLnk = "$([Environment]::GetFolderPath('Startup'))\AntigravityWidget.lnk"

$script:currentMode = "Bars"
$script:currentOrientation = "Horizontal"
$script:isClickThrough = $false
$script:show5h = $true
$script:showWeekly = $true
$script:showContext = $true
$script:showSubtitles = $true

# ================= AUTOSTART HELPER =================
function Get-AutostartState {
    return (Test-Path $startupLnk)
}

function Set-AutostartState ($enable) {
    try {
        if ($enable) {
            $vbsPath = "$PSScriptRoot\Lanzar-Widget.vbs"
            $wsh = New-Object -ComObject WScript.Shell
            $shortcut = $wsh.CreateShortcut($startupLnk)
            $shortcut.TargetPath = "wscript.exe"
            $shortcut.Arguments = "`"$vbsPath`""
            $shortcut.WorkingDirectory = "$PSScriptRoot"
            $shortcut.Description = "Antigravity Desktop Widget"
            $shortcut.Save()
            [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
        } else {
            if (Test-Path $startupLnk) {
                Remove-Item -Path $startupLnk -Force -ErrorAction SilentlyContinue
            }
        }
        $isAuto = Get-AutostartState
        $ctxAutoStart.IsChecked = $isAuto
        $dlgChkAutoStart.IsChecked = $isAuto
        if ($trayAutoStartItem) { $trayAutoStartItem.Checked = $isAuto }
    } catch {}
}

# ================= CLICK-THROUGH HELPER =================
function Set-ClickThroughState ($enable) {
    $script:isClickThrough = [bool]$enable
    $dlgChkClickThrough.IsChecked = $script:isClickThrough
    $ctxClickThrough.IsChecked = $script:isClickThrough
    if ($trayClickThroughItem) { $trayClickThroughItem.Checked = $script:isClickThrough }
    
    try {
        $helper = [System.Windows.Interop.WindowInteropHelper]::new($window)
        $hwnd = $helper.Handle
        if ($hwnd -ne [IntPtr]::Zero) {
            [Win32WindowTools]::SetClickThrough($hwnd, $script:isClickThrough)
        }
    } catch {}
}

# ================= RESET POSITION =================
function Reset-WidgetPosition {
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $w = if ($window.ActualWidth -gt 0) { $window.ActualWidth } else { 180 }
    $h = if ($window.ActualHeight -gt 0) { $window.ActualHeight } else { 80 }
    $window.Left = [Math]::Max(0, ($screen.Width - $w) / 2 + $screen.Left)
    $window.Top = [Math]::Max(0, ($screen.Height - $h) / 2 + $screen.Top)
    Save-WidgetConfig
}

# ================= ORIENTATION =================
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

        $dlgBtnOrientV.Background = $activeBg
        $dlgBtnOrientV.Foreground = $activeFg
        $dlgBtnOrientH.Background = $inactiveBg
        $dlgBtnOrientH.Foreground = $inactiveFg
    } else {
        $viewGauges.Orientation = [System.Windows.Controls.Orientation]::Horizontal
        $viewChips.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        $gaugeItem5h.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)
        $gaugeItemWeekly.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)
        $gaugeItemContext.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)

        $chipItem5h.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)
        $chipItemWeekly.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)
        $chipItemContext.Margin = [System.Windows.Thickness]::new(2, 0, 2, 0)

        $dlgBtnOrientH.Background = $activeBg
        $dlgBtnOrientH.Foreground = $activeFg
        $dlgBtnOrientV.Background = $inactiveBg
        $dlgBtnOrientV.Foreground = $inactiveFg
    }
}

# ================= VISUAL MODES =================
function Set-WidgetMode ($mode) {
    $script:currentMode = $mode
    
    $viewBars.Visibility = [System.Windows.Visibility]::Collapsed
    $viewGauges.Visibility = [System.Windows.Visibility]::Collapsed
    $viewChips.Visibility = [System.Windows.Visibility]::Collapsed

    $inactiveBg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
    $inactiveFg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
    $activeBg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
    $activeFg = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FFFFFF")

    $dlgBtnBars.Background = $inactiveBg
    $dlgBtnBars.Foreground = $inactiveFg
    $dlgBtnGauges.Background = $inactiveBg
    $dlgBtnGauges.Foreground = $inactiveFg
    $dlgBtnChips.Background = $inactiveBg
    $dlgBtnChips.Foreground = $inactiveFg

    switch ($mode) {
        "Gauges" {
            $viewGauges.Visibility = [System.Windows.Visibility]::Visible
            $dlgBtnGauges.Background = $activeBg
            $dlgBtnGauges.Foreground = $activeFg
        }
        "Chips" {
            $viewChips.Visibility = [System.Windows.Visibility]::Visible
            $dlgBtnChips.Background = $activeBg
            $dlgBtnChips.Foreground = $activeFg
        }
        Default {
            $script:currentMode = "Bars"
            $viewBars.Visibility = [System.Windows.Visibility]::Visible
            $dlgBtnBars.Background = $activeBg
            $dlgBtnBars.Foreground = $activeFg
        }
    }
    Set-WidgetOrientation $script:currentOrientation
    Apply-VisibilityRules
}

function Apply-VisibilityRules {
    $v5h = if ($script:show5h) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $vW = if ($script:showWeekly) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $vCtx = if ($script:showContext) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }
    $vSub = if ($script:showSubtitles) { [System.Windows.Visibility]::Visible } else { [System.Windows.Visibility]::Collapsed }

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

function Save-WidgetConfig {
    try {
        $cfgObj = [PSCustomObject]@{
            Opacity       = $dlgSliderOpacity.Value
            Scale         = $dlgSliderScale.Value
            Mode          = $script:currentMode
            Orientation   = $script:currentOrientation
            Left          = $window.Left
            Top           = $window.Top
            Pinned        = $window.Topmost
            Show5h        = $script:show5h
            ShowWeekly    = $script:showWeekly
            ShowContext   = $script:showContext
            ShowSubtitles = $script:showSubtitles
            ClickThrough  = $script:isClickThrough
        }
        $cfgObj | ConvertTo-Json | Set-Content $configFile -Force
    } catch {}
}

function Toggle-Pin {
    $window.Topmost = -not $window.Topmost
    $ctxPin.IsChecked = $window.Topmost
    $dlgChkPin.IsChecked = $window.Topmost
    if ($trayPinItem) { $trayPinItem.Checked = $window.Topmost }
    Save-WidgetConfig
}

function Show-SettingsDialog {
    $dlgChkAutoStart.IsChecked = Get-AutostartState
    $dlgChkPin.IsChecked = $window.Topmost
    $dlgChkClickThrough.IsChecked = $script:isClickThrough
    $dlgChkShow5h.IsChecked = $script:show5h
    $dlgChkShowWeekly.IsChecked = $script:showWeekly
    $dlgChkShowContext.IsChecked = $script:showContext
    $dlgChkShowSubtitles.IsChecked = $script:showSubtitles
    $dlgSliderOpacity.Value = $window.Opacity
    $dlgSliderScale.Value = $uiScale.ScaleX

    $settingsWindow.Show()
    $settingsWindow.Activate()
}

function Close-WidgetApp {
    Save-WidgetConfig
    if ($notifyIcon) {
        $notifyIcon.Visible = $false
        $notifyIcon.Dispose()
    }
    $settingsWindow.Close()
    $window.Close()
}

# ================= LOAD SAVED CONFIG =================
if (Test-Path $configFile) {
    try {
        $cfg = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($cfg.Opacity) {
            $dlgSliderOpacity.Value = [double]$cfg.Opacity
            $window.Opacity = [double]$cfg.Opacity
            $dlgTxtOpacityVal.Text = ([string][int]($cfg.Opacity * 100)) + "%"
        } else {
            $window.Opacity = 0.90
        }
        if ($cfg.Scale) {
            $dlgSliderScale.Value = $cfg.Scale
            $uiScale.ScaleX = $cfg.Scale
            $uiScale.ScaleY = $cfg.Scale
            $dlgTxtScaleVal.Text = ([string][int]($cfg.Scale * 100)) + "%"
        }
        if ($cfg.Left -ne $null -and $cfg.Top -ne $null) {
            $window.WindowStartupLocation = [System.Windows.WindowStartupLocation]::Manual
            $window.Left = [double]$cfg.Left
            $window.Top = [double]$cfg.Top
        }
        if ($cfg.Pinned -ne $null) {
            $window.Topmost = [bool]$cfg.Pinned
            $ctxPin.IsChecked = $window.Topmost
            $dlgChkPin.IsChecked = $window.Topmost
        }
        if ($cfg.Show5h -ne $null) { $script:show5h = [bool]$cfg.Show5h; $dlgChkShow5h.IsChecked = $script:show5h }
        if ($cfg.ShowWeekly -ne $null) { $script:showWeekly = [bool]$cfg.ShowWeekly; $dlgChkShowWeekly.IsChecked = $script:showWeekly }
        if ($cfg.ShowContext -ne $null) { $script:showContext = [bool]$cfg.ShowContext; $dlgChkShowContext.IsChecked = $script:showContext }
        if ($cfg.ShowSubtitles -ne $null) { $script:showSubtitles = [bool]$cfg.ShowSubtitles; $dlgChkShowSubtitles.IsChecked = $script:showSubtitles }
        if ($cfg.ClickThrough -ne $null) { $script:isClickThrough = [bool]$cfg.ClickThrough }
        if ($cfg.Orientation) { $script:currentOrientation = $cfg.Orientation }
        if ($cfg.Mode) { Set-WidgetMode $cfg.Mode } else { Set-WidgetMode "Bars" }
    } catch {
        Set-WidgetMode "Bars"
    }
} else {
    Set-WidgetMode "Bars"
}

$ctxAutoStart.IsChecked = Get-AutostartState
$dlgChkAutoStart.IsChecked = Get-AutostartState

# ================= DRAG & DROP =================
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

# Middle Click toggles Orientation
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

# Settings Dialog Dragging
$settingsBorder = $settingsWindow.Content
$settingsBorder.Add_MouseLeftButtonDown({
    $settingsWindow.DragMove()
})

# Context Menu bindings
$ctxModeBars.Add_Click({ Set-WidgetMode "Bars"; Save-WidgetConfig })
$ctxModeGauges.Add_Click({ Set-WidgetMode "Gauges"; Save-WidgetConfig })
$ctxModeChips.Add_Click({ Set-WidgetMode "Chips"; Save-WidgetConfig })
$ctxOrientH.Add_Click({ Set-WidgetOrientation "Horizontal"; Save-WidgetConfig })
$ctxOrientV.Add_Click({ Set-WidgetOrientation "Vertical"; Save-WidgetConfig })
$ctxResetPos.Add_Click({ Reset-WidgetPosition })
$ctxAutoStart.Add_Click({ Set-AutostartState (-not (Get-AutostartState)) })
$ctxPin.IsChecked = $window.Topmost
$ctxPin.Add_Click({ Toggle-Pin })
$ctxClickThrough.Add_Click({ Set-ClickThroughState (-not $script:isClickThrough); Save-WidgetConfig })
$ctxSettings.Add_Click({ Show-SettingsDialog })
$ctxRefresh.Add_Click({ Update-WidgetData })
$ctxClose.Add_Click({ Close-WidgetApp })

# ================= SETTINGS DIALOG EVENTS =================
$dlgBtnCloseX.Add_Click({ $settingsWindow.Hide() })
$dlgBtnSave.Add_Click({
    Save-WidgetConfig
    $settingsWindow.Hide()
})
$dlgBtnResetPos.Add_Click({ Reset-WidgetPosition })

$dlgBtnBars.Add_Click({ Set-WidgetMode "Bars"; Save-WidgetConfig })
$dlgBtnGauges.Add_Click({ Set-WidgetMode "Gauges"; Save-WidgetConfig })
$dlgBtnChips.Add_Click({ Set-WidgetMode "Chips"; Save-WidgetConfig })

$dlgBtnOrientH.Add_Click({ Set-WidgetOrientation "Horizontal"; Save-WidgetConfig })
$dlgBtnOrientV.Add_Click({ Set-WidgetOrientation "Vertical"; Save-WidgetConfig })

$dlgChkAutoStart.Add_Click({ Set-AutostartState $dlgChkAutoStart.IsChecked })
$dlgChkPin.Add_Click({ if ($window.Topmost -ne $dlgChkPin.IsChecked) { Toggle-Pin } })
$dlgChkClickThrough.Add_Click({ Set-ClickThroughState $dlgChkClickThrough.IsChecked; Save-WidgetConfig })

$dlgChkShow5h.Add_Click({ $script:show5h = [bool]$dlgChkShow5h.IsChecked; Apply-VisibilityRules; Save-WidgetConfig })
$dlgChkShowWeekly.Add_Click({ $script:showWeekly = [bool]$dlgChkShowWeekly.IsChecked; Apply-VisibilityRules; Save-WidgetConfig })
$dlgChkShowContext.Add_Click({ $script:showContext = [bool]$dlgChkShowContext.IsChecked; Apply-VisibilityRules; Save-WidgetConfig })
$dlgChkShowSubtitles.Add_Click({ $script:showSubtitles = [bool]$dlgChkShowSubtitles.IsChecked; Apply-VisibilityRules; Save-WidgetConfig })

$dlgSliderOpacity.Add_ValueChanged({
    $window.Opacity = $dlgSliderOpacity.Value
    $dlgTxtOpacityVal.Text = ([string][int]($dlgSliderOpacity.Value * 100)) + "%"
})

$dlgSliderScale.Add_ValueChanged({
    $uiScale.ScaleX = $dlgSliderScale.Value
    $uiScale.ScaleY = $dlgSliderScale.Value
    $dlgTxtScaleVal.Text = ([string][int]($dlgSliderScale.Value * 100)) + "%"
})

# Dialog Themes
$dlgBtnThemeCyan.Add_Click({
    $grad = [System.Windows.Media.LinearGradientBrush]::new()
    $grad.StartPoint = [System.Windows.Point]::new(0,0)
    $grad.EndPoint = [System.Windows.Point]::new(1,1)
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#60A5FA"), 0.0))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#1E293B"), 0.5))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#00F2FE"), 1.0))
    $mainBorder.BorderBrush = $grad
})

$dlgBtnThemePurple.Add_Click({
    $grad = [System.Windows.Media.LinearGradientBrush]::new()
    $grad.StartPoint = [System.Windows.Point]::new(0,0)
    $grad.EndPoint = [System.Windows.Point]::new(1,1)
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#C084FC"), 0.0))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#1E1B4B"), 0.5))
    $grad.GradientStops.Add([System.Windows.Media.GradientStop]::new([System.Windows.Media.ColorConverter]::ConvertFromString("#F43F5E"), 1.0))
    $mainBorder.BorderBrush = $grad
})

$dlgBtnThemeGreen.Add_Click({
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

# Context menu items in tray
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

$trayResetPosItem = $contextMenu.Items.Add("Restablecer Posicion (Centrar)")
$trayResetPosItem.Add_Click({ Reset-WidgetPosition })

$contextMenu.Items.Add("-") | Out-Null

$trayAutoStartItem = $contextMenu.Items.Add("Iniciar con Windows")
$trayAutoStartItem.CheckOnClick = $true
$trayAutoStartItem.Checked = Get-AutostartState
$trayAutoStartItem.Add_Click({ Set-AutostartState $trayAutoStartItem.Checked })

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

$traySettingsItem = $contextMenu.Items.Add("Preferencias...")
$traySettingsItem.Add_Click({ Show-SettingsDialog })

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
