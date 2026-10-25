import socket
import ssl
import sys
import threading

HOST = "shaurya1234s-macbook-pro.tailc80c27.ts.net"


def copy(src, dst):
    try:
        while True:
            data = src.read(8192)
            if not data:
                break
            dst.write(data)
            dst.flush()
    except Exception:
        pass
    try:
        dst.close()
    except Exception:
        pass


def main():
    raw = socket.create_connection((HOST, 443), 15)
    ctx = ssl.create_default_context()
    ss = ctx.wrap_socket(raw, server_hostname=HOST)
    thread = threading.Thread(target=copy, args=(sys.stdin.buffer, ss), daemon=True)
    thread.start()
    copy(ss, sys.stdout.buffer)


if __name__ == "__main__":
    main()
