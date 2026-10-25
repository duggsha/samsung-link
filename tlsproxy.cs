using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;

class TlsProxy {
    const int STD_INPUT_HANDLE = -10;
    const int STD_OUTPUT_HANDLE = -11;

    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetStdHandle(int handle);

    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool ReadFile(IntPtr handle, byte[] buffer, int count, out int read, IntPtr overlapped);

    [DllImport("kernel32.dll", SetLastError = true)]
    static extern bool WriteFile(IntPtr handle, byte[] buffer, int count, out int written, IntPtr overlapped);

    static int Main() {
        string root = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "dugg-link");
        string[] spec = File.ReadAllLines(Path.Combine(root, "proxy.path"));
        var psi = new ProcessStartInfo();
        psi.FileName = spec[1];
        psi.Arguments = spec.Length > 2 ? spec[2] : "";
        psi.UseShellExecute = false;
        psi.RedirectStandardInput = true;
        psi.RedirectStandardOutput = true;
        psi.RedirectStandardError = true;
        psi.CreateNoWindow = true;
        var child = Process.Start(psi);
        var err = new Thread(() => Drain(child.StandardError.BaseStream));
        err.IsBackground = true;
        err.Start();
        var incoming = new Thread(() => CopyToStream(GetStdHandle(STD_INPUT_HANDLE), child.StandardInput.BaseStream));
        incoming.IsBackground = true;
        incoming.Start();
        CopyToHandle(child.StandardOutput.BaseStream, GetStdHandle(STD_OUTPUT_HANDLE));
        return 0;
    }

    static void Drain(Stream from) {
        var buf = new byte[1024];
        try {
            while (from.Read(buf, 0, buf.Length) > 0) { }
        } catch { }
    }

    static void CopyToStream(IntPtr from, Stream to) {
        var buf = new byte[8192];
        try {
            int n;
            while (ReadFile(from, buf, buf.Length, out n, IntPtr.Zero) && n > 0) {
                to.Write(buf, 0, n);
                to.Flush();
            }
        } catch { }
        try { to.Close(); } catch { }
    }

    static void CopyToHandle(Stream from, IntPtr to) {
        var buf = new byte[8192];
        try {
            int n;
            while ((n = from.Read(buf, 0, buf.Length)) > 0) {
                int written;
                if (!WriteFile(to, buf, n, out written, IntPtr.Zero)) break;
            }
        } catch { }
    }
}
