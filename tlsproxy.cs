using System;
using System.IO;
using System.Net.Security;
using System.Net.Sockets;
using System.Security.Authentication;
using System.Threading;

class TlsProxy {
    static int Main() {
        string host = "shaurya1234s-macbook-pro.tailc80c27.ts.net";
        var tcp = new TcpClient(host, 443);
        var ssl = new SslStream(tcp.GetStream(), false);
        ssl.AuthenticateAsClient(host, null, SslProtocols.Tls12, false);
        var stdin = Console.OpenStandardInput();
        var stdout = Console.OpenStandardOutput();
        var t = new Thread(() => Copy(stdin, ssl));
        t.IsBackground = true;
        t.Start();
        Copy(ssl, stdout);
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
        } catch {
        }
        try { to.Close(); } catch { }
    }
}
