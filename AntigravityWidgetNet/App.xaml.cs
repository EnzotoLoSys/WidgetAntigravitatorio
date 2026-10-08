using System;
using System.Drawing;
using System.Threading;
using System.Windows;
using System.Windows.Forms;
using AntigravityWidget.Services;
using Application = System.Windows.Application;
using MessageBox = System.Windows.MessageBox;

namespace AntigravityWidget
{
    public partial class App : Application
    {
        private const string MutexName = "AntigravityWidgetMutex_SingleInstance";
        private Mutex? _mutex;
        private bool _ownsMutex;
        private NotifyIcon? _notifyIcon;
        private MainWindow? _mainWindow;

        protected override void OnStartup(StartupEventArgs e)
        {
            _mutex = new Mutex(true, MutexName, out bool createdNew);
            _ownsMutex = createdNew;
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

            var ghostItem = new ToolStripMenuItem("Modo Fantasma (Click-Through)");
            ghostItem.Click += (s, e) =>
            {
                if (_mainWindow != null)
                {
                    _mainWindow.Config.ClickThrough = !_mainWindow.Config.ClickThrough;
                    _mainWindow.ApplyConfig();
                    ConfigService.Save(_mainWindow.Config);
                }
            };
            contextMenu.Items.Add(ghostItem);

            contextMenu.Items.Add("Centrar en Barra de Tareas", null, (s, e) => _mainWindow?.CenterOnTaskbar());
            contextMenu.Items.Add("Centrar en Pantalla", null, (s, e) => _mainWindow?.CenterOnScreen());
            contextMenu.Items.Add("Actualizar Métricas", null, (s, e) => _mainWindow?.RefreshDataAsync());
            contextMenu.Items.Add(new ToolStripSeparator());
            contextMenu.Items.Add("Cerrar Widget", null, (s, e) => Shutdown());

            contextMenu.Opening += (s, e) =>
            {
                ghostItem.Checked = _mainWindow?.Config.ClickThrough ?? false;
            };

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
                if (_ownsMutex)
                {
                    try { _mutex.ReleaseMutex(); } catch (ApplicationException) { }
                }
                _mutex.Dispose();
            }

            base.OnExit(e);
        }
    }
}
