@echo off
REM --- First build: ProServer_Admin ---
pyinstaller --onefile --noconsole --icon=icon.png --uac-admin --name ProServer_Admin ProStore.py

REM --- Second build: ProServer ---
pyinstaller --onefile --noconsole --icon=icon.png --name ProServer ProStore.py

pause