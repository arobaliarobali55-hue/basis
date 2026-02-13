@echo off
echo Building Flutter web app...
flutter build web --release

echo Copying to dist folder...
xcopy /E /I /Y build\web dist

echo Committing and pushing...
git add dist
git commit -m "Deploy update: %date% %time%"
git push

echo Done! Check your Vercel dashboard for deployment status.
pause
