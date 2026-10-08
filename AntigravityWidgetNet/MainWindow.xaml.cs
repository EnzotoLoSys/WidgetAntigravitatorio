using System;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Media;
using System.Windows.Threading;
using AntigravityWidget.Native;
using AntigravityWidget.Services;

namespace AntigravityWidget
{
    public partial class MainWindow : Window
    {
        public WidgetConfig Config { get; private set; }
        private readonly DispatcherTimer _timer;
        private SettingsWindow? _settingsWindow;
        private bool _isUpdatingData = false;

        public MainWindow()
        {
            InitializeComponent();
            Config = ConfigService.Load();

            // Setup events
            Loaded += MainWindow_Loaded;
            MainBorder.MouseLeftButtonDown += MainBorder_MouseLeftButtonDown;
            MainBorder.MouseDown += MainBorder_MouseDown;

            // Timer for refreshing metrics every 3 seconds
            _timer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(3)
            };
            _timer.Tick += (s, e) => RefreshDataAsync();
        }

        private void MainWindow_Loaded(object sender, RoutedEventArgs e)
        {
            ApplyPosition();
            ApplyConfig();
            RefreshDataAsync();
            _timer.Start();
        }

        private void ApplyPosition()
        {
            if (Config.Left.HasValue && Config.Top.HasValue)
            {
                double vLeft = SystemParameters.VirtualScreenLeft;
                double vTop = SystemParameters.VirtualScreenTop;
                double vWidth = SystemParameters.VirtualScreenWidth;
                double vHeight = SystemParameters.VirtualScreenHeight;

                if (Config.Left.Value >= vLeft - 100 && Config.Left.Value < (vLeft + vWidth - 40) &&
                    Config.Top.Value >= vTop - 20 && Config.Top.Value < (vTop + vHeight - 40))
                {
                    this.WindowStartupLocation = WindowStartupLocation.Manual;
                    this.Left = Config.Left.Value;
                    this.Top = Config.Top.Value;
                    return;
                }
            }

            CenterOnScreen();
        }

        public void CenterOnScreen()
        {
            double screenW = SystemParameters.PrimaryScreenWidth;
            double screenH = SystemParameters.PrimaryScreenHeight;
            this.Left = (screenW - 200) / 2;
            this.Top = (screenH - 120) / 2;
            Config.Left = this.Left;
            Config.Top = this.Top;
            ConfigService.Save(Config);
        }

        public void ApplyConfig()
        {
            // 1. Topmost & Pinned
            this.Topmost = Config.Pinned;

            // 2. Scale
            UiScale.ScaleX = Config.Scale;
            UiScale.ScaleY = Config.Scale;

            // 3. Opacity (Fondo, Bordes, Gráficos, Textos)
            BgBrush.Opacity = Config.OpacityBg;
            BorderGrad.Opacity = Config.OpacityBorder;

            double gOp = Config.OpacityGraphics;
            Prog5h.Opacity = gOp;
            ProgWeekly.Opacity = gOp;
            ProgContext.Opacity = gOp;
            Prog5hBg.Opacity = gOp;
            ProgWeeklyBg.Opacity = gOp;
            ProgContextBg.Opacity = gOp;
            Gauge5hRing.Opacity = gOp;
            GaugeWeeklyRing.Opacity = gOp;
            GaugeContextRing.Opacity = gOp;
            Gauge5hBgRing.Opacity = gOp;
            GaugeWeeklyBgRing.Opacity = gOp;
            GaugeContextBgRing.Opacity = gOp;
            ChipItem5h.Opacity = gOp;
            ChipItemWeekly.Opacity = gOp;
            ChipItemContext.Opacity = gOp;

            double tOp = Config.OpacityText;
            Lbl5h.Opacity = tOp;
            Txt5hPct.Opacity = tOp;
            Txt5hReset.Opacity = tOp;
            LblWeekly.Opacity = tOp;
            TxtWeeklyPct.Opacity = tOp;
            TxtWeeklyDetails.Opacity = tOp;
            LblContext.Opacity = tOp;
            TxtContextTokens.Opacity = tOp;
            TxtGauge5hVal.Opacity = tOp;
            LblGauge5h.Opacity = tOp;
            TxtGaugeWeeklyVal.Opacity = tOp;
            LblGaugeWeekly.Opacity = tOp;
            TxtGaugeContextVal.Opacity = tOp;
            LblGaugeContext.Opacity = tOp;
            LblChip5h.Opacity = tOp;
            TxtChip5h.Opacity = tOp;
            LblChipWeekly.Opacity = tOp;
            TxtChipWeekly.Opacity = tOp;
            LblChipContext.Opacity = tOp;
            TxtChipContext.Opacity = tOp;

            // 4. Mode Selection
            ViewBars.Visibility = Config.Mode == "Bars" ? Visibility.Visible : Visibility.Collapsed;
            ViewGauges.Visibility = Config.Mode == "Gauges" ? Visibility.Visible : Visibility.Collapsed;
            ViewChips.Visibility = Config.Mode == "Chips" ? Visibility.Visible : Visibility.Collapsed;

            // 5. Orientation (Horizontal vs Vertical)
            bool isHoriz = Config.Orientation == "Horizontal";

            if (isHoriz)
            {
                ViewBars.Orientation = Orientation.Horizontal;
                ViewBars.Width = double.NaN;
                Row5h.Width = 110; Row5h.Margin = new Thickness(0, 0, 8, 0);
                RowWeekly.Width = 110; RowWeekly.Margin = new Thickness(0, 0, 8, 0);
                RowContext.Width = 110; RowContext.Margin = new Thickness(0, 0, 0, 0);

                ViewGauges.Orientation = Orientation.Horizontal;
                GaugeItem5h.Margin = new Thickness(2, 0, 2, 0);
                GaugeItemWeekly.Margin = new Thickness(2, 0, 2, 0);
                GaugeItemContext.Margin = new Thickness(2, 0, 2, 0);

                ViewChips.Orientation = Orientation.Horizontal;
                ChipItem5h.Margin = new Thickness(2, 0, 2, 0);
                ChipItemWeekly.Margin = new Thickness(2, 0, 2, 0);
                ChipItemContext.Margin = new Thickness(2, 0, 2, 0);
            }
            else
            {
                ViewBars.Orientation = Orientation.Vertical;
                ViewBars.Width = 175;
                Row5h.Width = double.NaN; Row5h.Margin = new Thickness(0, 0, 0, 3.5);
                RowWeekly.Width = double.NaN; RowWeekly.Margin = new Thickness(0, 0, 0, 3.5);
                RowContext.Width = double.NaN; RowContext.Margin = new Thickness(0, 0, 0, 0);

                ViewGauges.Orientation = Orientation.Vertical;
                GaugeItem5h.Margin = new Thickness(0, 2, 0, 2);
                GaugeItemWeekly.Margin = new Thickness(0, 2, 0, 2);
                GaugeItemContext.Margin = new Thickness(0, 2, 0, 2);

                ViewChips.Orientation = Orientation.Vertical;
                ChipItem5h.Margin = new Thickness(0, 2, 0, 2);
                ChipItemWeekly.Margin = new Thickness(0, 2, 0, 2);
                ChipItemContext.Margin = new Thickness(0, 2, 0, 2);
            }

            // 6. Section Visibility Toggles
            Row5h.Visibility = Config.Show5h ? Visibility.Visible : Visibility.Collapsed;
            GaugeItem5h.Visibility = Config.Show5h ? Visibility.Visible : Visibility.Collapsed;
            ChipItem5h.Visibility = Config.Show5h ? Visibility.Visible : Visibility.Collapsed;

            RowWeekly.Visibility = Config.ShowWeekly ? Visibility.Visible : Visibility.Collapsed;
            GaugeItemWeekly.Visibility = Config.ShowWeekly ? Visibility.Visible : Visibility.Collapsed;
            ChipItemWeekly.Visibility = Config.ShowWeekly ? Visibility.Visible : Visibility.Collapsed;

            RowContext.Visibility = Config.ShowContext ? Visibility.Visible : Visibility.Collapsed;
            GaugeItemContext.Visibility = Config.ShowContext ? Visibility.Visible : Visibility.Collapsed;
            ChipItemContext.Visibility = Config.ShowContext ? Visibility.Visible : Visibility.Collapsed;

            Txt5hReset.Visibility = Config.ShowSubtitles ? Visibility.Visible : Visibility.Collapsed;
            TxtWeeklyDetails.Visibility = Config.ShowSubtitles ? Visibility.Visible : Visibility.Collapsed;

            // 7. Theme
            ApplyTheme(Config.Theme);

            // 8. Click-Through
            var helper = new WindowInteropHelper(this);
            if (helper.Handle != IntPtr.Zero)
            {
                Win32.SetClickThrough(helper.Handle, Config.ClickThrough);
            }

            // 9. Context Menu Checkmarks
            CtxAutoStart.IsChecked = ConfigService.IsAutoStartEnabled();
            CtxPin.IsChecked = Config.Pinned;
            CtxClickThrough.IsChecked = Config.ClickThrough;
        }

        private void ApplyTheme(string theme)
        {
            BorderGrad.GradientStops.Clear();
            if (theme == "Purple")
            {
                BorderGrad.GradientStops.Add(new GradientStop((Color)ColorConverter.ConvertFromString("#C084FC"), 0.0));
                BorderGrad.GradientStops.Add(new GradientStop((Color)ColorConverter.ConvertFromString("#1E293B"), 0.5));
                BorderGrad.GradientStops.Add(new GradientStop((Color)ColorConverter.ConvertFromString("#EC4899"), 1.0));
            }
            else if (theme == "Green")
            {
                BorderGrad.GradientStops.Add(new GradientStop((Color)ColorConverter.ConvertFromString("#34D399"), 0.0));
                BorderGrad.GradientStops.Add(new GradientStop((Color)ColorConverter.ConvertFromString("#064E3B"), 0.5));
                BorderGrad.GradientStops.Add(new GradientStop((Color)ColorConverter.ConvertFromString("#10B981"), 1.0));
            }
            else
            {
                // Default Cyan
                BorderGrad.GradientStops.Add(new GradientStop((Color)ColorConverter.ConvertFromString("#60A5FA"), 0.0));
                BorderGrad.GradientStops.Add(new GradientStop((Color)ColorConverter.ConvertFromString("#1E293B"), 0.5));
                BorderGrad.GradientStops.Add(new GradientStop((Color)ColorConverter.ConvertFromString("#00F2FE"), 1.0));
            }
        }

        public async void RefreshDataAsync()
        {
            if (_isUpdatingData) return;
            _isUpdatingData = true;

            try
            {
                QuotaData data = await QuotaService.CalculateAsync();
                UpdateUiWithData(data);

                // Backoff interval: 3s if live language server connected, 10s if offline/estimate
                var targetInterval = data.IsLiveApi ? TimeSpan.FromSeconds(3) : TimeSpan.FromSeconds(10);
                if (_timer.Interval != targetInterval)
                {
                    _timer.Interval = targetInterval;
                }
            }
            catch { }
            finally
            {
                _isUpdatingData = false;
            }
        }

        private void UpdateUiWithData(QuotaData data)
        {
            // Update 5-hour
            Txt5hPct.Text = $"{data.Remain5hPct}%";
            Prog5h.Value = data.Remain5hPct;
            Txt5hReset.Text = data.Reset5hText;

            // Update Weekly
            TxtWeeklyPct.Text = $"{data.RemainWeeklyPct}%";
            ProgWeekly.Value = data.RemainWeeklyPct;
            TxtWeeklyDetails.Text = data.WeeklyDetailsText;

            // Update Context
            TxtContextTokens.Text = data.ContextTokensText;
            ProgContext.Value = data.ContextPct;

            // Update Gauges (Dash math: stroke perimeter = 33 dash units)
            TxtGauge5hVal.Text = $"{data.Remain5hPct}%";
            double dash5h = (data.Remain5hPct / 100.0) * 33.0;
            Gauge5hRing.StrokeDashArray = new DoubleCollection { Math.Max(0.1, dash5h), 50.0 };

            TxtGaugeWeeklyVal.Text = $"{data.RemainWeeklyPct}%";
            double dashWeekly = (data.RemainWeeklyPct / 100.0) * 33.0;
            GaugeWeeklyRing.StrokeDashArray = new DoubleCollection { Math.Max(0.1, dashWeekly), 50.0 };

            TxtGaugeContextVal.Text = $"{(int)Math.Round(data.ContextPct)}%";
            double dashCtx = (data.ContextPct / 100.0) * 33.0;
            GaugeContextRing.StrokeDashArray = new DoubleCollection { Math.Max(0.1, dashCtx), 50.0 };

            // Update Chips
            TxtChip5h.Text = $"{data.Remain5hPct}%";
            TxtChipWeekly.Text = $"{data.RemainWeeklyPct}%";
            TxtChipContext.Text = $"{(int)Math.Round(data.ContextPct)}%";

            // Dynamic color alerts for low remaining quota (<20% red, <50% yellow)
            string color5h = data.Remain5hPct < 20 ? "#EF4444" : (data.Remain5hPct < 50 ? "#F59E0B" : "#4ADE80");
            var brush5h = new SolidColorBrush((Color)ColorConverter.ConvertFromString(color5h));
            Txt5hPct.Foreground = brush5h;
            TxtGauge5hVal.Foreground = brush5h;
            TxtChip5h.Foreground = brush5h;
            Gauge5hRing.Stroke = brush5h;
        }

        private void MainBorder_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ClickCount == 2)
            {
                OpenSettings();
                return;
            }

            if (e.LeftButton == MouseButtonState.Pressed)
            {
                DragMove();
                Config.Left = this.Left;
                Config.Top = this.Top;
                ConfigService.Save(Config);
            }
        }

        private void MainBorder_MouseDown(object sender, MouseButtonEventArgs e)
        {
            // Middle-click toggles Orientation instantly!
            if (e.ChangedButton == MouseButton.Middle)
            {
                Config.Orientation = Config.Orientation == "Horizontal" ? "Vertical" : "Horizontal";
                ApplyConfig();
                ConfigService.Save(Config);
            }
        }

        public void OpenSettings()
        {
            if (_settingsWindow == null || !_settingsWindow.IsLoaded)
            {
                _settingsWindow = new SettingsWindow(this);
                _settingsWindow.Closed += (s, e) => _settingsWindow = null;
                _settingsWindow.Show();
            }
            else
            {
                _settingsWindow.Activate();
            }
        }

        // Context Menu Handlers
        private void OnModeBarsClick(object sender, RoutedEventArgs e)
        {
            Config.Mode = "Bars";
            ApplyConfig();
            ConfigService.Save(Config);
        }

        private void OnModeGaugesClick(object sender, RoutedEventArgs e)
        {
            Config.Mode = "Gauges";
            ApplyConfig();
            ConfigService.Save(Config);
        }

        private void OnModeChipsClick(object sender, RoutedEventArgs e)
        {
            Config.Mode = "Chips";
            ApplyConfig();
            ConfigService.Save(Config);
        }

        private void OnOrientHClick(object sender, RoutedEventArgs e)
        {
            Config.Orientation = "Horizontal";
            ApplyConfig();
            ConfigService.Save(Config);
        }

        private void OnOrientVClick(object sender, RoutedEventArgs e)
        {
            Config.Orientation = "Vertical";
            ApplyConfig();
            ConfigService.Save(Config);
        }

        private void OnResetPosClick(object sender, RoutedEventArgs e)
        {
            CenterOnScreen();
        }

        private void OnAutoStartClick(object sender, RoutedEventArgs e)
        {
            bool enable = !ConfigService.IsAutoStartEnabled();
            ConfigService.SetAutoStart(enable);
            CtxAutoStart.IsChecked = enable;
        }

        private void OnPinClick(object sender, RoutedEventArgs e)
        {
            Config.Pinned = !Config.Pinned;
            ApplyConfig();
            ConfigService.Save(Config);
        }

        private void OnClickThroughClick(object sender, RoutedEventArgs e)
        {
            Config.ClickThrough = !Config.ClickThrough;
            ApplyConfig();
            ConfigService.Save(Config);
        }

        private void OnSettingsClick(object sender, RoutedEventArgs e)
        {
            OpenSettings();
        }

        private void OnRefreshClick(object sender, RoutedEventArgs e)
        {
            RefreshDataAsync();
        }

        private void OnCloseClick(object sender, RoutedEventArgs e)
        {
            Application.Current.Shutdown();
        }
    }
}
