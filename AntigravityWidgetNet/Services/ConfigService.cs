using System;
using System.IO;
using System.Text.Json;

namespace AntigravityWidget.Services
{
    public class WidgetConfig
    {
        public double OpacityBg { get; set; } = 0.90;
        public double OpacityBorder { get; set; } = 1.00;
        public double OpacityGraphics { get; set; } = 1.00;
        public double OpacityText { get; set; } = 1.00;
        public double Scale { get; set; } = 1.0;
        public string Mode { get; set; } = "Bars";
        public string Orientation { get; set; } = "Horizontal";
        public double? Left { get; set; }
        public double? Top { get; set; }
        public bool Pinned { get; set; } = true;
        public bool ShowGemini { get; set; } = true;
        public bool ShowGpt { get; set; } = true;
        public bool Show5h { get; set; } = true;
        public bool ShowWeekly { get; set; } = true;
        public bool ShowContext { get; set; } = true;
        public bool ShowSubtitles { get; set; } = true;
        public bool ClickThrough { get; set; } = false;
        public bool LockToTaskbar { get; set; } = false;
        public string Theme { get; set; } = "Cyan";
    }

    public static class ConfigService
    {
        private static readonly string ConfigDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "AntigravityWidget");
        private static readonly string ConfigPath = Path.Combine(ConfigDir, "widget_config.json");
        private static readonly string LegacyConfigPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "widget_config.json");
        private static readonly string StartupFolder = Environment.GetFolderPath(Environment.SpecialFolder.Startup);
        private static readonly string ShortcutPath = Path.Combine(StartupFolder, "AntigravityWidget.lnk");

        public static WidgetConfig Load()
        {
            try
            {
                // One-time migration of a config that used to live next to the exe.
                if (!File.Exists(ConfigPath) && File.Exists(LegacyConfigPath))
                {
                    Directory.CreateDirectory(ConfigDir);
                    File.Copy(LegacyConfigPath, ConfigPath);
                }

                if (File.Exists(ConfigPath))
                {
                    string json = File.ReadAllText(ConfigPath);
                    var cfg = JsonSerializer.Deserialize<WidgetConfig>(json);
                    if (cfg != null) return cfg;
                }
            }
            catch { }
            return new WidgetConfig();
        }

        public static void Save(WidgetConfig config)
        {
            try
            {
                Directory.CreateDirectory(ConfigDir);
                var options = new JsonSerializerOptions { WriteIndented = true };
                string json = JsonSerializer.Serialize(config, options);
                File.WriteAllText(ConfigPath, json);
            }
            catch { }
        }

        public static bool IsAutoStartEnabled()
        {
            return File.Exists(ShortcutPath);
        }

        public static void SetAutoStart(bool enable)
        {
            try
            {
                if (enable)
                {
                    string exePath = Environment.ProcessPath ?? Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "AntigravityWidget.exe");
                    CreateShortcut(ShortcutPath, exePath, AppDomain.CurrentDomain.BaseDirectory);
                }
                else
                {
                    if (File.Exists(ShortcutPath))
                    {
                        File.Delete(ShortcutPath);
                    }
                }
            }
            catch { }
        }

        private static void CreateShortcut(string shortcutPath, string targetPath, string workingDir)
        {
            Type? shellType = Type.GetTypeFromProgID("WScript.Shell");
            if (shellType == null) return;
            dynamic shell = Activator.CreateInstance(shellType)!;
            dynamic shortcut = shell.CreateShortcut(shortcutPath);
            shortcut.TargetPath = targetPath;
            shortcut.WorkingDirectory = workingDir;
            shortcut.Description = "Antigravity Desktop Widget";
            shortcut.Save();
        }
    }
}
