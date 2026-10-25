using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;

class TlsProxy {
    [DllImport("msvcrt.dll", CallingConvention = CallingConvention.Cdecl)]
    static extern int _setmode(int fd, int mode);

    static int Main() {
        _setmode(0, 0x8000);
        _setmode(1, 0x8000);
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
        var err = new Thread(() => {
            try {
                var t = child.StandardError.ReadToEnd();
                if (!string.IsNullOrEmpty(t)) Console.Error.WriteLine(t);
            } catch { }
        });
        err.IsBackground = true;
        err.Start();
        var tIn = new Thread(() => Copy(Console.OpenStandardInput(), child.StandardInput.BaseStream));
        tIn.IsBackground = true;
        tIn.Start();
        Copy(child.StandardOutput.BaseStream, Console.OpenStandardOutput());
        return 0;
    }

    static void Copy(Stream from, Stream to) {
        var buf = new byte[8192];
        try {
            int n;
            while ((n = from.Read(buf, 0, buf.Length)) > 0) {
                to.Write(buf, 0, n);
                to.Flush();
            }
        } catch { }
        try { to.Close(); } catch { }
    }
}
