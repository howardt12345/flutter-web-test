SET PATH=C:\Shared\Projects\flutter\master\bin;%PATH%
flutter build web
robocopy "%CD%"\build\web "%CD%"\docs
pause