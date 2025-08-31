# Capacitor Android Build (APK) – Anleitung

Diese Schritte sind bereits an das vorhandene CRA-Setup (react-scripts) angepasst. Wir verpacken den statischen Build (inkl. /public/qualitool) unverändert in eine native WebView.

## 1) Abhängigkeiten installieren

```bash
yarn add -D @capacitor/cli @capacitor/android @capacitor/core
```

Hinweis: core ist Runtime-Dependency, für CRA kann sie auch ohne -D installiert werden:
```bash
yarn add @capacitor/core
```

## 2) Capacitor initialisieren (falls noch nicht geschehen)

```bash
npx cap init Qualifizierungstool de.ams.Qualifizierungstool --web-dir=build
```

Unsere capacitor.config.ts ist bereits erstellt.

## 3) Build des Web-Assets erstellen

```bash
yarn build
```

Wichtige Hinweise:
- Das Tool liegt unter /public/qualitool/index.html und wird in den Build kopiert.
- Supabase funktioniert offline; für Login wird Netzwerk benötigt.

## 4) Android-Plattform hinzufügen

```bash
npx cap add android
```

## 5) Dateien synchronisieren

```bash
npx cap sync android
```

## 6) Android Studio öffnen und APK bauen

```bash
npx cap open android
```

In Android Studio:
- Build > Build Bundle(s) / APK(s) > Build APK(s)
- Die APK findest du anschließend im Ausgabeverzeichnis von Android Studio

## 7) Schreibrechte / Datei-Export

Unser Webtool nutzt den Browser-Download (XLSX/CSV). In der nativen WebView greifen folgende Wege:
- Moderne Android-Versionen: Verwende den systemweiten Share/Save-Dialog (bereits durch XLSX.writeFile gegeben); je nach Android-Version wird automatisch ein geeigneter Speicherort bereitgestellt (Downloads/Share-Ziel). 
- Für explizite Ablage (optional, wenn nötig): @capacitor/filesystem verwenden und eine kleine Brücke schreiben. Aktuell nicht nötig, solange Share/Save funktioniert.

### Optionales Filesystem-Beispiel (nur wenn benötigt)

```ts
import { Filesystem, Directory, Encoding } from '@capacitor/filesystem';

async function saveTextFile(name: string, content: string) {
  await Filesystem.writeFile({
    path: name,
    data: content,
    directory: Directory.Documents,
    encoding: Encoding.UTF8,
  });
}
```

Dann via window.__CapHelper.isNative() prüfen und ggf. alternative Speicherung anbieten.

## 8) Start-URL in der App

Die App lädt standardmäßig den Build-Index (React). Unser Tool liegt unter /qualitool. Stelle sicher, dass du im mobilen Menü auf das Tool gelangst (oder setze optional eine Weiterleitung auf /qualitool/index.html, wenn die App ausschließlich dieses Tool darstellen soll).

## 9) Tests auf Gerät
- Login (Supabase)
- Import Excel und Excel/CSV-Export
- WE-Korrektur erfassen, Liste prüfen
- Hintergrund-Sync (WLAN trennen/wiederherstellen)

## Troubleshooting
- Falls Downloads nicht sichtbar: Prüfe App-Berechtigungen (Storage/Downloads). Ab Android 10+ wird in der Regel der Systemdialog verwaltet – keine extra Berechtigung notwendig.
- Bei Blank Screen: npx cap sync android erneut ausführen, und Internet-Zugriff in Manifest prüfen (Standard: vorhanden).