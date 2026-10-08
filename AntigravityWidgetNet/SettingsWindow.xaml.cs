using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using AntigravityWidget.Services;
using Button = System.Windows.Controls.Button;

namespace AntigravityWidget
{
    public partial class SettingsWindow : Window
    {
        private readonly MainWindow _mainWindow;
        private readonly WidgetConfig _cfg;
        private bool _isInitializing = true;

        public SettingsWindow(MainWindow mainWindow)
        {
            InitializeComponent();
            _mainWindow = mainWindow;
            _cfg = mainWindow.Config;

            LoadCurrentConfig();
            _isInitializing = false;
        }

        private void LoadCurrentConfig()
        {
            UpdateModeButtons(_cfg.Mode);
            UpdateOrientButtons(_cfg.Orientation);

            DlgSliderOpacityBg.Value = _cfg.OpacityBg;
            DlgTxtOpacityBgVal.Text = $"{(int)Math.Round(_cfg.OpacityBg * 100)}%";

            DlgSliderOpacityBorder.Value = _cfg.OpacityBorder;
            DlgTxtOpacityBorderVal.Text = $"{(int)Math.Round(_cfg.OpacityBorder * 100)}%";

            DlgSliderOpacityGraphics.Value = _cfg.OpacityGraphics;
            DlgTxtOpacityGraphicsVal.Text = $"{(int)Math.Round(_cfg.OpacityGraphics * 100)}%";

            DlgSliderOpacityText.Value = _cfg.OpacityText;
            DlgTxtOpacityTextVal.Text = $"{(int)Math.Round(_cfg.OpacityText * 100)}%";

            DlgSliderScale.Value = _cfg.Scale;
            DlgTxtScaleVal.Text = $"{(int)Math.Round(_cfg.Scale * 100)}%";

            DlgChkAutoStart.IsChecked = ConfigService.IsAutoStartEnabled();
            DlgChkPin.IsChecked = _cfg.Pinned;
            DlgChkClickThrough.IsChecked = _cfg.ClickThrough;
            DlgChkTaskbarMode.IsChecked = _cfg.OpacityBg <= 0.05 && _cfg.OpacityBorder <= 0.05;
            DlgChkShow5h.IsChecked = _cfg.Show5h;
            DlgChkShowWeekly.IsChecked = _cfg.ShowWeekly;
            DlgChkShowContext.IsChecked = _cfg.ShowContext;
            DlgChkShowSubtitles.IsChecked = _cfg.ShowSubtitles;
        }

        private void OnHeaderMouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.LeftButton == MouseButtonState.Pressed)
            {
                DragMove();
            }
        }

        protected override void OnClosed(EventArgs e)
        {
            base.OnClosed(e);
            ConfigService.Save(_cfg);
        }

        private void OnCloseClick(object sender, RoutedEventArgs e)
        {
            ConfigService.Save(_cfg);
            Close();
        }

        private void UpdateModeButtons(string mode)
        {
            _cfg.Mode = mode;
            SetButtonActive(DlgBtnBars, mode == "Bars");
            SetButtonActive(DlgBtnGauges, mode == "Gauges");
            SetButtonActive(DlgBtnChips, mode == "Chips");
            _mainWindow.ApplyConfig();
        }

        private void UpdateOrientButtons(string orient)
        {
            _cfg.Orientation = orient;
            SetButtonActive(DlgBtnOrientH, orient == "Horizontal");
            SetButtonActive(DlgBtnOrientV, orient == "Vertical");
            _mainWindow.ApplyConfig();
        }

        private void SetButtonActive(Button btn, bool active)
        {
            if (active)
            {
                btn.Background = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#2563EB"));
                btn.Foreground = Brushes.White;
            }
            else
            {
                btn.Background = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#1E293B"));
                btn.Foreground = new SolidColorBrush((Color)ColorConverter.ConvertFromString("#94A3B8"));
            }
        }

        private void OnModeBarsClick(object sender, RoutedEventArgs e) => UpdateModeButtons("Bars");
        private void OnModeGaugesClick(object sender, RoutedEventArgs e) => UpdateModeButtons("Gauges");
        private void OnModeChipsClick(object sender, RoutedEventArgs e) => UpdateModeButtons("Chips");

        private void OnOrientHClick(object sender, RoutedEventArgs e) => UpdateOrientButtons("Horizontal");
        private void OnOrientVClick(object sender, RoutedEventArgs e) => UpdateOrientButtons("Vertical");

        private void OnOpacityBgChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (_isInitializing) return;
            _cfg.OpacityBg = Math.Round(e.NewValue, 2);
            DlgTxtOpacityBgVal.Text = $"{(int)Math.Round(_cfg.OpacityBg * 100)}%";
            _mainWindow.ApplyConfig();
        }

        private void OnOpacityBorderChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (_isInitializing) return;
            _cfg.OpacityBorder = Math.Round(e.NewValue, 2);
            DlgTxtOpacityBorderVal.Text = $"{(int)Math.Round(_cfg.OpacityBorder * 100)}%";
            _mainWindow.ApplyConfig();
        }

        private void OnOpacityGraphicsChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (_isInitializing) return;
            _cfg.OpacityGraphics = Math.Round(e.NewValue, 2);
            DlgTxtOpacityGraphicsVal.Text = $"{(int)Math.Round(_cfg.OpacityGraphics * 100)}%";
            _mainWindow.ApplyConfig();
        }

        private void OnOpacityTextChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (_isInitializing) return;
            _cfg.OpacityText = Math.Round(e.NewValue, 2);
            DlgTxtOpacityTextVal.Text = $"{(int)Math.Round(_cfg.OpacityText * 100)}%";
            _mainWindow.ApplyConfig();
        }

        private void OnScaleChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (_isInitializing) return;
            _cfg.Scale = Math.Round(e.NewValue, 2);
            DlgTxtScaleVal.Text = $"{(int)Math.Round(_cfg.Scale * 100)}%";
            _mainWindow.ApplyConfig();
        }

        private void OnAutoStartClick(object sender, RoutedEventArgs e)
        {
            bool enable = DlgChkAutoStart.IsChecked ?? false;
            ConfigService.SetAutoStart(enable);
        }

        private void OnPinClick(object sender, RoutedEventArgs e)
        {
            _cfg.Pinned = DlgChkPin.IsChecked ?? true;
            _mainWindow.ApplyConfig();
        }

        private void OnClickThroughClick(object sender, RoutedEventArgs e)
        {
            _cfg.ClickThrough = DlgChkClickThrough.IsChecked ?? false;
            _mainWindow.ApplyConfig();
        }

        private void OnShowVisibilityClick(object sender, RoutedEventArgs e)
        {
            _cfg.Show5h = DlgChkShow5h.IsChecked ?? true;
            _cfg.ShowWeekly = DlgChkShowWeekly.IsChecked ?? true;
            _cfg.ShowContext = DlgChkShowContext.IsChecked ?? true;
            _cfg.ShowSubtitles = DlgChkShowSubtitles.IsChecked ?? true;
            _mainWindow.ApplyConfig();
        }

        private void OnThemeCyanClick(object sender, RoutedEventArgs e)
        {
            _cfg.Theme = "Cyan";
            _mainWindow.ApplyConfig();
        }

        private void OnThemePurpleClick(object sender, RoutedEventArgs e)
        {
            _cfg.Theme = "Purple";
            _mainWindow.ApplyConfig();
        }

        private void OnThemeGreenClick(object sender, RoutedEventArgs e)
        {
            _cfg.Theme = "Green";
            _mainWindow.ApplyConfig();
        }

        private void OnResetPosClick(object sender, RoutedEventArgs e)
        {
            _mainWindow.CenterOnScreen();
        }

        private void OnCenterTaskbarClick(object sender, RoutedEventArgs e)
        {
            _mainWindow.CenterOnTaskbar();
        }

        private void OnTaskbarModeClick(object sender, RoutedEventArgs e)
        {
            bool isTaskbarMode = DlgChkTaskbarMode.IsChecked ?? false;
            if (isTaskbarMode)
            {
                _cfg.OpacityBg = 0.0;
                _cfg.OpacityBorder = 0.0;
                _cfg.Orientation = "Horizontal";
                UpdateOrientButtons("Horizontal");
                DlgSliderOpacityBg.Value = 0.0;
                DlgTxtOpacityBgVal.Text = "0%";
                DlgSliderOpacityBorder.Value = 0.0;
                DlgTxtOpacityBorderVal.Text = "0%";
                _mainWindow.ApplyConfig();
                _mainWindow.CenterOnTaskbar();
            }
            else
            {
                _cfg.OpacityBg = 0.90;
                _cfg.OpacityBorder = 1.0;
                DlgSliderOpacityBg.Value = 0.90;
                DlgTxtOpacityBgVal.Text = "90%";
                DlgSliderOpacityBorder.Value = 1.0;
                DlgTxtOpacityBorderVal.Text = "100%";
                _mainWindow.ApplyConfig();
            }
        }

        private void OnSaveClick(object sender, RoutedEventArgs e)
        {
            ConfigService.Save(_cfg);
            Close();
        }
    }
}
