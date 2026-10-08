using System;
using System.Runtime.InteropServices;

namespace AntigravityWidget.Native
{
    public static class Win32
    {
        public const int GWL_EXSTYLE = -20;
        public const int WS_EX_TRANSPARENT = 0x00000020;

        [DllImport("user32.dll", SetLastError = true)]
        public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

        public static void SetClickThrough(IntPtr hWnd, bool enable)
        {
            if (hWnd == IntPtr.Zero) return;
            int exStyle = GetWindowLong(hWnd, GWL_EXSTYLE);
            if (enable)
            {
                SetWindowLong(hWnd, GWL_EXSTYLE, exStyle | WS_EX_TRANSPARENT);
            }
            else
            {
                SetWindowLong(hWnd, GWL_EXSTYLE, exStyle & ~WS_EX_TRANSPARENT);
            }
        }
    }
}
