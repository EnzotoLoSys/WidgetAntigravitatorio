using System;
using System.Collections.Generic;
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

        private const int AF_INET = 2;
        private const int TCP_TABLE_OWNER_PID_LISTENER = 3;

        [DllImport("iphlpapi.dll", SetLastError = true)]
        private static extern uint GetExtendedTcpTable(IntPtr pTcpTable, ref int pdwSize, bool bOrder, int ulAf, int tableClass, uint reserved);

        [StructLayout(LayoutKind.Sequential)]
        private struct MIB_TCPROW_OWNER_PID
        {
            public uint state;
            public uint localAddr;
            public uint localPort;
            public uint remoteAddr;
            public uint remotePort;
            public uint owningPid;
        }

        /// <summary>
        /// Returns the IPv4 TCP ports that the given process is listening on.
        /// Used so the CSRF token is only ever sent to the language server's own ports.
        /// </summary>
        public static List<int> GetListeningPortsForPid(int pid)
        {
            var result = new List<int>();
            int size = 0;
            GetExtendedTcpTable(IntPtr.Zero, ref size, true, AF_INET, TCP_TABLE_OWNER_PID_LISTENER, 0);
            if (size <= 0) return result;

            IntPtr buffer = Marshal.AllocHGlobal(size);
            try
            {
                if (GetExtendedTcpTable(buffer, ref size, true, AF_INET, TCP_TABLE_OWNER_PID_LISTENER, 0) != 0)
                {
                    return result;
                }

                int rowCount = Marshal.ReadInt32(buffer);
                IntPtr rowPtr = IntPtr.Add(buffer, 4);
                int rowSize = Marshal.SizeOf<MIB_TCPROW_OWNER_PID>();

                for (int i = 0; i < rowCount; i++)
                {
                    var row = Marshal.PtrToStructure<MIB_TCPROW_OWNER_PID>(rowPtr);
                    if (row.owningPid == (uint)pid)
                    {
                        // Port is stored in network byte order in the low 16 bits.
                        int port = (int)(((row.localPort & 0xFF) << 8) | ((row.localPort >> 8) & 0xFF));
                        result.Add(port);
                    }
                    rowPtr = IntPtr.Add(rowPtr, rowSize);
                }
            }
            finally
            {
                Marshal.FreeHGlobal(buffer);
            }

            return result;
        }
    }
}
