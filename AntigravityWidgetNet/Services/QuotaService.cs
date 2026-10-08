using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management;
using System.Net.Http;
using System.Net.NetworkInformation;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace AntigravityWidget.Services
{
    public class QuotaData
    {
        public bool IsLiveApi { get; set; } = false;
        public int Count5h { get; set; }
        public int CountWeekly { get; set; }

        // Gemini Metrics
        public int Remain5hPct { get; set; } = 100;
        public int RemainWeeklyPct { get; set; } = 100;
        public string Reset5hText { get; set; } = "~1h 12m";
        public string WeeklyDetailsText { get; set; } = "186 prompts";

        // ChatGPT / Claude (GPT-OSS / 3P) Metrics
        public int GptRemain5hPct { get; set; } = 100;
        public int GptRemainWeeklyPct { get; set; } = 100;
        public string GptReset5hText { get; set; } = "100%";
        public string GptWeeklyDetailsText { get; set; } = "100%";

        // Context Tokens
        public string ContextTokensText { get; set; } = "1k (~0.1%)";
        public double ContextPct { get; set; } = 0.1;
        public string ModelGroupName { get; set; } = "Gemini + ChatGPT";
    }

    public static class QuotaService
    {
        private static readonly Regex CreatedAtRegex = new Regex("\"created_at\":\"([^\"]+)\"", RegexOptions.Compiled);
        private static readonly Regex CsrfRegex = new Regex(@"--csrf_token\s+([a-zA-Z0-9\-]+)", RegexOptions.Compiled);
        private static readonly HttpClient HttpClient = new HttpClient { Timeout = TimeSpan.FromSeconds(1.5) };

        private static int? _cachedPort = null;
        private static string? _cachedCsrf = null;

        public static async Task<QuotaData> CalculateAsync()
        {
            var data = new QuotaData();

            // 1. First, calculate Context Tokens & prompt counts from local transcript logs
            CalculateLocalMetrics(data);

            // 2. Query official Antigravity IDE Language Server API for 100% exact live quota
            bool apiSuccess = await TryFetchFromLanguageServerAsync(data);

            // 3. If API is not available (e.g. IDE closed), fallback to estimate from transcript logs
            if (!apiSuccess)
            {
                CalculateFallbackQuota(data);
            }

            return data;
        }

        private static async Task<bool> TryFetchFromLanguageServerAsync(QuotaData data)
        {
            try
            {
                // Try cached endpoint first
                if (_cachedPort.HasValue && !string.IsNullOrEmpty(_cachedCsrf))
                {
                    if (await FetchQuotaJsonAsync(_cachedPort.Value, _cachedCsrf, data))
                    {
                        return true;
                    }
                    _cachedPort = null;
                    _cachedCsrf = null;
                }

                // Auto-discover Language Server PID & CSRF Token via WMI
                var processes = new List<(int Pid, string Csrf)>();
                try
                {
                    using var searcher = new ManagementObjectSearcher("SELECT ProcessId, CommandLine FROM Win32_Process WHERE Name LIKE 'language_server%'");
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        string cmd = obj["CommandLine"]?.ToString() ?? "";
                        int pid = Convert.ToInt32(obj["ProcessId"]);
                        var match = CsrfRegex.Match(cmd);
                        if (match.Success)
                        {
                            processes.Add((pid, match.Groups[1].Value));
                        }
                    }
                }
                catch { }

                if (processes.Count == 0) return false;

                // Each token is only ever tried against the ports owned by the
                // language server process that actually holds it.
                foreach (var proc in processes)
                {
                    foreach (var port in Native.Win32.GetListeningPortsForPid(proc.Pid))
                    {
                        if (await FetchQuotaJsonAsync(port, proc.Csrf, data))
                        {
                            _cachedPort = port;
                            _cachedCsrf = proc.Csrf;
                            return true;
                        }
                    }
                }
            }
            catch { }

            return false;
        }

        private static async Task<bool> FetchQuotaJsonAsync(int port, string csrf, QuotaData data)
        {
            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Post, $"http://127.0.0.1:{port}/exa.language_server_pb.LanguageServerService/RetrieveUserQuotaSummary");
                request.Headers.Add("Connect-Protocol-Version", "1");
                request.Headers.Add("x-codeium-csrf-token", csrf);
                request.Content = new StringContent("{}", Encoding.UTF8, "application/json");

                using var response = await HttpClient.SendAsync(request);
                if (!response.IsSuccessStatusCode) return false;

                string json = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(json);

                if (!doc.RootElement.TryGetProperty("response", out var respEl)) return false;
                if (!respEl.TryGetProperty("groups", out var groupsEl)) return false;

                bool foundAny = false;
                foreach (var g in groupsEl.EnumerateArray())
                {
                    string name = g.GetProperty("displayName").GetString() ?? "";
                    bool isGemini = name.Contains("Gemini", StringComparison.OrdinalIgnoreCase);
                    bool isGpt = name.Contains("GPT", StringComparison.OrdinalIgnoreCase) ||
                                 name.Contains("Claude", StringComparison.OrdinalIgnoreCase) ||
                                 name.Contains("3p", StringComparison.OrdinalIgnoreCase) ||
                                 name.Contains("OpenAI", StringComparison.OrdinalIgnoreCase);

                    if (g.TryGetProperty("buckets", out var bucketsEl))
                    {
                        foreach (var b in bucketsEl.EnumerateArray())
                        {
                            string window = b.TryGetProperty("window", out var wEl) ? (wEl.GetString() ?? "") : "";
                            string bucketId = b.TryGetProperty("bucketId", out var idEl) ? (idEl.GetString() ?? "") : "";
                            double frac = b.TryGetProperty("remainingFraction", out var fracEl) ? fracEl.GetDouble() : 1.0;
                            string desc = b.TryGetProperty("description", out var dEl) ? (dEl.GetString() ?? "") : "";
                            string resetTimeStr = b.TryGetProperty("resetTime", out var rEl) ? (rEl.GetString() ?? "") : "";

                            int pct = Math.Clamp((int)Math.Round(frac * 100), 0, 100);
                            string resetText = FormatResetTime(resetTimeStr, desc, window == "5h" ? data.Count5h : data.CountWeekly);

                            if (isGemini)
                            {
                                if (window == "5h" || bucketId.Contains("5h"))
                                {
                                    data.Remain5hPct = pct;
                                    data.Reset5hText = resetText;
                                    foundAny = true;
                                }
                                else if (window == "weekly" || bucketId.Contains("weekly"))
                                {
                                    data.RemainWeeklyPct = pct;
                                    data.WeeklyDetailsText = resetText;
                                    foundAny = true;
                                }
                            }
                            else if (isGpt || !isGemini)
                            {
                                if (window == "5h" || bucketId.Contains("5h"))
                                {
                                    data.GptRemain5hPct = pct;
                                    data.GptReset5hText = resetText;
                                    foundAny = true;
                                }
                                else if (window == "weekly" || bucketId.Contains("weekly"))
                                {
                                    data.GptRemainWeeklyPct = pct;
                                    data.GptWeeklyDetailsText = resetText;
                                    foundAny = true;
                                }
                            }
                        }
                    }
                }

                if (foundAny)
                {
                    data.IsLiveApi = true;
                    return true;
                }
            }
            catch { }

            return false;
        }

        private static string FormatResetTime(string resetTimeStr, string desc, int promptCount)
        {
            if (!string.IsNullOrEmpty(resetTimeStr) && DateTime.TryParse(resetTimeStr, out DateTime resetUtc))
            {
                TimeSpan diff = resetUtc.ToUniversalTime() - DateTime.UtcNow;
                if (diff.TotalDays >= 1)
                {
                    int d = (int)diff.TotalDays;
                    int h = diff.Hours;
                    return $"~{d}d {h}h";
                }
                if (diff.TotalMinutes > 0)
                {
                    int h = diff.Hours;
                    int m = diff.Minutes;
                    string timeStr = h > 0 ? $"{h}h {m}m" : $"{m}m";
                    return $"~{timeStr}";
                }
                return "100%";
            }
            if (!string.IsNullOrEmpty(desc))
            {
                return desc;
            }
            return $"{promptCount} prompts";
        }

        private static void CalculateLocalMetrics(QuotaData data)
        {
            try
            {
                DateTime now = DateTime.UtcNow;
                DateTime fiveHoursAgo = now.AddHours(-5);
                DateTime weeklyAgo = now.AddDays(-7);

                string userHome = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                string brainRoot = Path.Combine(userHome, ".gemini", "antigravity-ide", "brain");

                var candidateFiles = new List<FileInfo>();
                FileInfo? latestTranscript = null;

                if (Directory.Exists(brainRoot))
                {
                    var brainDirs = Directory.GetDirectories(brainRoot);
                    foreach (var convDir in brainDirs)
                    {
                        string logFile = Path.Combine(convDir, ".system_generated", "logs", "transcript.jsonl");
                        if (File.Exists(logFile))
                        {
                            var fi = new FileInfo(logFile);
                            if (fi.LastWriteTimeUtc >= weeklyAgo)
                            {
                                candidateFiles.Add(fi);
                            }
                            if (latestTranscript == null || fi.LastWriteTimeUtc > latestTranscript.LastWriteTimeUtc)
                            {
                                latestTranscript = fi;
                            }
                        }
                    }
                }

                // Context Tokens
                long contextTokens = 3000;
                if (latestTranscript != null && latestTranscript.Exists)
                {
                    contextTokens = Math.Max(1000, latestTranscript.Length / 4);
                }
                const long maxContext = 1000000;
                double ctxPct = Math.Round(((double)contextTokens / maxContext) * 100.0, 1);
                data.ContextPct = Math.Clamp(ctxPct, 0.1, 100.0);
                string tokenStr = contextTokens >= 1000 ? $"{(contextTokens / 1000.0):0.#}k" : contextTokens.ToString();
                data.ContextTokensText = $"{tokenStr} (~{ctxPct}%)";

                // Count prompts
                int count5h = 0;
                int countWeekly = 0;

                foreach (var fi in candidateFiles)
                {
                    try
                    {
                        using var fs = new FileStream(fi.FullName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
                        using var reader = new StreamReader(fs);
                        string? line;
                        while ((line = reader.ReadLine()) != null)
                        {
                            if (line.Contains("\"type\":\"USER_INPUT\""))
                            {
                                var m = CreatedAtRegex.Match(line);
                                if (m.Success && DateTime.TryParse(m.Groups[1].Value, out DateTime dt))
                                {
                                    dt = dt.ToUniversalTime();
                                    if (dt >= weeklyAgo) countWeekly++;
                                    if (dt >= fiveHoursAgo) count5h++;
                                }
                            }
                        }
                    }
                    catch { }
                }

                data.Count5h = count5h;
                data.CountWeekly = countWeekly;
                data.WeeklyDetailsText = $"{countWeekly} prompts";
            }
            catch { }
        }

        private static void CalculateFallbackQuota(QuotaData data)
        {
            data.IsLiveApi = false;
            const double max5hRequests = 90.0;
            double used5hPct = Math.Min(100.0, (data.Count5h / max5hRequests) * 100.0);
            data.Remain5hPct = Math.Clamp((int)Math.Round(100.0 - used5hPct), 0, 100);

            const double maxWeekly = 500.0;
            double usedWeeklyPct = Math.Min(100.0, (data.CountWeekly / maxWeekly) * 100.0);
            data.RemainWeeklyPct = Math.Clamp((int)Math.Round(100.0 - usedWeeklyPct), 0, 100);
            data.Reset5hText = $"~Est. ({data.Count5h} p)";
            data.WeeklyDetailsText = $"~Est. ({data.CountWeekly} p)";
            data.ModelGroupName = "IDE desconectado";
        }
    }
}
