# samsung-link

Visible link from Shaurya's Samsung laptop to his Mac.

The laptop opens an outbound SSH connection to the Mac. The Mac can then SSH back through that connection to the laptop's existing OpenSSH server. The window stays on screen. Closing it stops the link.

No private key is in this repo. `install.ps1` creates one on the laptop and prints the public key.

## Install

In PowerShell:

```powershell
git clone https://github.com/duggsha/samsung-link.git $env:USERPROFILE\dugg-link\samsung-link
powershell -NoProfile -ExecutionPolicy Bypass -File $env:USERPROFILE\dugg-link\samsung-link\install.ps1
```

Paste the printed public key into the Mac's allowed keys. The window retries until that key is accepted.
