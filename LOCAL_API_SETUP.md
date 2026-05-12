# Local API URL

The Flutter app reads the backend URL from `API_BASE_URL`.

By default, it uses the Android Emulator host address:

```text
http://10.0.2.2:5000/api
```

So if you run the backend and the Android Emulator on the same machine, you can usually run:

```powershell
flutter run
```

If you need a different URL, run the app with your own machine IP:

```powershell
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:5000/api
```

Example:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.8:5000/api
```

Each developer can use their own IP in the run command without changing Dart files or committing local IP changes to Git.
