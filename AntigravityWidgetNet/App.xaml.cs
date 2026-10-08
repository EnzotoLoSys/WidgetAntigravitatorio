using System;
using System.Drawing;
using System.Threading;
using System.Windows;
using System.Windows.Forms;
using Application = System.Windows.Application;
using MessageBox = System.Windows.MessageBox;

namespace AntigravityWidget
{
    public partial class App : Application
    {
        private const string MutexName = "AntigravityWidgetMutex_SingleInstance";
        private Mutex? _mutex;
        private NotifyIcon? _notifyIcon;
        private MainWindow? _mainWindow;

        protected override void OnStartup(StartupEventArgs e)
        {
            _mutex = new Mutex(true, MutexName, out bool createdNew);
            if (!createdNew)
            {
                MessageBox.Show("Antigravity Widget ya se encuentra en ejecución.", "Antigravity Widget", MessageBoxButton.OK, MessageBoxImage.Information);
                Shutdown();
                return;
            }

            base.OnStartup(e);

            _mainWindow = new MainWindow();
            _mainWindow.Show();

            SetupNotifyIcon();
        }

        private void SetupNotifyIcon()
        {
            _notifyIcon = new NotifyIcon();

            // Create a sleek icon programmatically (Cyan dot with dark background)
            try
            {
                using var bmp = new Bitmap(16, 16);
                using (var g = Graphics.FromImage(bmp))
                {
                    g.Clear(Color.Transparent);
                    using var brush = new SolidBrush(Color.FromArgb(56, 189, 248)); // #38BDF8 Sky Cyan
                    g.FillEllipse(brush, 1, 1, 14, 14);
                    using var innerBrush = new SolidBrush(Color.FromArgb(15, 23, 42)); // Slate 900
                    g.FillEllipse(innerBrush, 4, 4, 8, 8);
                }
                IntPtr hIcon = bmp.GetHicon();
                _notifyIcon.Icon = System.Drawing.Icon.FromHandle(hIcon);
            }
            catch
            {
                _notifyIcon.Icon = SystemIcons.Application;
            }

            _notifyIcon.Text = "Antigravity Desktop Widget";
            _notifyIcon.Visible = true;

            var contextMenu = new ContextMenuStrip();
            contextMenu.Items.Add("Preferencias...", null, (s, e) => _mainWindow?.OpenSettings());
            contextMenu.Items.Add("Centrar en Pantalla", null, (s, e) => _mainWindow?.CenterOnScreen());
            contextMenu.Items.Add("Actualizar Métricas", null, (s, e) => _mainWindow?.RefreshDataAsync());
            contextMenu.Items.Add(new ToolStripSeparator());
            contextMenu.Items.Add("Cerrar Widget", null, (s, e) => Shutdown());

            _notifyIcon.ContextMenuStrip = contextMenu;
            _notifyIcon.DoubleClick += (s, e) =>
            {
                if (_mainWindow != null)
                {
                    _mainWindow.WindowState = WindowState.Normal;
                    _mainWindow.Activate();
                }
            };
        }

        protected override void OnExit(ExitEventArgs e)
        {
            if (_notifyIcon != null)
            {
                _notifyIcon.Visible = false;
                _notifyIcon.Dispose();
            }

            if (_mutex != null)
            {
                _mutex.ReleaseMutex();
                _mutex.Dispose();
            }

            base.OnExit(e);
        }
    }
}
