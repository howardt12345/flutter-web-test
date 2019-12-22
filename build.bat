SET PATH=C:\Shared\Projects\flutter\beta\bin;%PATH%
flutter build web
xcopy %CD%\build\web %CD%\docs /h/i/c/k/e/r/y
pause