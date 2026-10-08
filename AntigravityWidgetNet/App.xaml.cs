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

            try
            {
                var iconUri = new Uri("pack://application:,,,/app.ico");
                var streamInfo = System.Windows.Application.GetResourceStream(iconUri);
                if (streamInfo != null)
                {
                    using (streamInfo.Stream)
                    {
                        _notifyIcon.Icon = new Icon(streamInfo.Stream);
                    }
                }
                else
                {
                    string localIco = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "app.ico");
                    if (System.IO.File.Exists(localIco))
                    {
                        _notifyIcon.Icon = new Icon(localIco);
                    }
                    else
                    {
                        _notifyIcon.Icon = SystemIcons.Application;
                    }
                }
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
