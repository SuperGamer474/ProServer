# ProServer (for ProStore iOS)

**The backend server code for ProStore iOS.**

---

## What this repository contains

* `main.py` — the ProServer application (Flask API + tray UI).
* `build.bat` — helper script to create a bundled executable using PyInstaller.
* `icon.png` — the icon used by PyInstaller to create the executable.
* `zsign.exe` — zsign executable by zhlynn.

> The main script automatically downloads `zsign` (if missing) to the user folder and exposes an `/api` endpoint that accepts files or URLs for `.ipa`, `.p12`, and `.mobileprovision`. It can either return the signed `.ipa` file directly (`type=file`) or host the signed IPA + manifest and return an `itms-services` link for OTA install (`type=install`).

---

## Requirements

* Windows (tested on Windows 10/11 x64).
* Python 3.9+ (3.12 recommended).
* `pip` available on PATH.
* (Optional) Git (to clone repo).

Python packages (see `requirements.txt`):

```
Flask
requests
Pillow
pystray
werkzeug
```

---

## Install & run (development)

1. Clone repo and open a PowerShell / cmd prompt in the project folder.

```powershell
git clone https://github.com/SuperGamer474/ProServer.git
cd ProServer
```

2. Run the server (development):

```powershell
python main.py
```

This will start the Flask server on `0.0.0.0:8030` and show a system tray icon. The tray menu contains a short server code (your local IP with dots replaced by dashes) which can be copied to the clipboard from the menu.

---

## Build (create a single exe)

**What `build.bat` does:**

* Runs PyInstaller to bundle `main.py` into a single executable.
* Produces 2 files, ProStore.exe, and ProStore_Admin.exe, which requires administrator privileges to open.

---

## Requirements

```
Flask
requests
Pillow
pystray
werkzeug
```

---

## Usage

### 1) Sign by uploading files (return file)

```bash
curl -F "ipa=@path/to/app.ipa" -F "p12=@path/to/cert.p12" -F "mobileprovision=@path/to/profile.mobileprovision" -F "password=PASSWORD" http://<host>:8030/api
```

This will return the signed `.ipa` file as an attachment.

### 2) Sign and host for OTA install (return JSON with itms link)

```bash
curl -F "ipa=@path/to/app.ipa" -F "p12=@path/to/cert.p12" -F "mobileprovision=@path/to/profile.mobileprovision" -F "password=PASSWORD" -F "type=install" http://<host>:8030/api
```

The server will respond with JSON similar to:

```json
{
  "status": "success",
  "id": "...",
  "manifest_url": "http://<host>:8030/manifest/<id>.plist",
  "ipa_url": "http://<host>:8030/ipa/<id>.ipa",
  "itms_link": "itms-services://?action=download-manifest&url=..."
}
```

Open the `itms_link` from an iOS device (Safari) to install the app OTA.

---

## API reference

* `POST /api` — main endpoint. Accepts form fields and file uploads. Required inputs: `ipa`, `p12`, `mobileprovision`, `password` (either a form field, uploaded password file, or a `password_url`). Optional `type=file|install` (default `file`).
* `GET /ipa/<id>.ipa` — serve hosted ipa
* `GET /manifest/<id>.plist` — serve manifest

See the source `main.py` for detailed behavior and error handling.

---

## Tray behavior

* The tray shows a small icon.
* The menu shows the server code (your local IP with dots replaced by dashes). Clicking the code copies it to the clipboard. This is used by ProStore iOS app.
* The tray also displays a notification at startup (may depend on system notification backend).

---

## Security & privacy

* The server deletes uploaded `.p12`, `.mobileprovision`, and temporary files where possible. However: **treat this tool as running on a trusted local machine only**. Do not run it on a public-facing server with untrusted network access.
* Consider running behind an HTTPS reverse proxy (e.g., Caddy, nginx, or a cloud load-balancer) if you expose it remotely.

---
