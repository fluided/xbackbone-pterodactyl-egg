#!/bin/ash

# Function to create directories if they don't exist
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

# Create necessary directories
create_directory "/home/container/logs/"
create_directory "/home/container/tmp/"

echo "🔄 Starting PHP-FPM..."
/usr/sbin/php-fpm81 --fpm-config /home/container/php-fpm/php-fpm.conf --daemonize || true

echo "🔄 Starting Nginx..."
nohup /usr/sbin/nginx -c /home/container/nginx/nginx.conf -p /home/container/ > /dev/null 2>&1 &
echo "✅ Successfully started"

sleep 5

echo "🔍 Checking for updates..."
current_version=$(cat /home/container/webroot/composer.json | grep -o '"version": "[^"]*"' | cut -d'"' -f4)
echo "📌 Current version: $current_version"

latest_version=$(curl -s https://api.github.com/repos/sergix44/XBackBone/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)

if [ -n "$latest_version" ]; then
    if [ "$current_version" != "$latest_version" ]; then
        echo "🚀 A new version of XBackBone is available!"
        echo "📌 Current version: $current_version"
        echo "🆕 Latest version: $latest_version"
        echo "🛠 To update, go to the 'System' tab and click 'Check for Updates' and then update."
    else
        echo "🌟 Your installation is up to date. No update is needed."
    fi
else
    echo "❌ Failed to retrieve the latest version from the GitHub API." >> /home/container/logs/update_check.log 2>&1
fi

# Keep the script running
while true; do
    sleep 60
done
