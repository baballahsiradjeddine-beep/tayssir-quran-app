#!/bin/bash
set -e

echo "Building Flutter Web..."
flutter build web --release --no-tree-shake-icons

echo "Copying extra files..."
cp web/images.php build/web/
cp web/.htaccess build/web/

echo "Zipping build..."
cd build/web
zip -r ../../web_build.zip .
cd ../../

echo "Uploading to Hostinger..."
expect -c "
set timeout 600
spawn scp -P 65002 -o StrictHostKeyChecking=no web_build.zip u477314974@46.202.172.117:domains/tayssir-bac.com/public_html/
expect {
    \"password:\" { send \"Tayssir@admin01\r\"; exp_continue }
    eof
}
"

echo "Unzipping on server..."
expect -c "
set timeout 600
spawn ssh -p 65002 u477314974@46.202.172.117
expect {
    \"password:\" { send \"Tayssir@admin01\r\"; exp_continue }
    -re \"(%|#|\\$) $\" {
        send \"cd domains/tayssir-bac.com/public_html/\r\"
        expect -re \"(%|#|\\$) $\"
        send \"rm -rf app_old\r\"
        expect -re \"(%|#|\\$) $\"
        send \"mv app app_old\r\"
        expect -re \"(%|#|\\$) $\"
        send \"mkdir app\r\"
        expect -re \"(%|#|\\$) $\"
        send \"unzip -o web_build.zip -d app/\r\"
        expect -re \"(%|#|\\$) $\"
        send \"rm web_build.zip\r\"
        expect -re \"(%|#|\\$) $\"
        send \"exit\r\"
    }
}
expect eof
"

echo "Deployment complete!"
