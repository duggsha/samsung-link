import os
import socket
import ssl
import sys
import threading

HOST = "shaurya1234s-macbook-pro.tailc80c27.ts.net"

if os.name == "nt":
    import msvcrt
    msvcrt.setmode(sys.stdin.fileno(), os.O_BINARY)
    msvcrt.setmode(sys.stdout.fileno(), os.O_BINARY)


def copy_in(ss):
    try:
        while True:
            data = os.read(sys.stdin.fileno(), 8192)
            if not data:
                break
            ss.sendall(data)
    except Exception:
        pass
    try:
        ss.shutdown(socket.SHUT_WR)
    except Exception:
        pass


def main():
    raw = socket.create_connection((HOST, 443), 15)
    ctx = ssl.create_default_context()
    ss = ctx.wrap_socket(raw, server_hostname=HOST)
    threading.Thread(target=copy_in, args=(ss,), daemon=True).start()
    try:
        while True:
            data = ss.recv(8192)
            if not data:
                break
            os.write(sys.stdout.fileno(), data)
    except Exception:
        pass


if __name__ == "__main__":
    main()
