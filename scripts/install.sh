#!/bin/bash

release=$(curl -s "https://api.github.com/repos/UnchartedBull/OctoDash/releases/latest" | grep "browser_download_url.*armv7l.deb" | cut -d '"' -f 4)
dependencies="libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libuuid1 libappindicator3-1 libsecret-1-0 gir1.2-gnomekeyring-1.0"

if [ -d "/home/pi/OctoPrint/venv" ]; then
    DIRECTORY="/home/pi/OctoPrint/venv"
elif [ -d "/home/pi/oprint" ]; then
    DIRECTORY="/home/pi/oprint"
else
    echo "Neither /home/pi/OctoPrint/venv nor /home/pi/oprint can be found. Please specify OctoPrints full virtualenv path manually (no trailing slash):"
    read -r DIRECTORY
fi;

"$DIRECTORY"/bin/pip install -q --disable-pip-version-check "https://github.com/OllisGit/OctoPrint-DisplayLayerProgress/releases/latest/download/master.zip"
"$DIRECTORY"/bin/pip install -q --disable-pip-version-check "https://github.com/vitormhenrique/OctoPrint-Enclosure/archive/master.zip"
"$DIRECTORY"/bin/pip install -q --disable-pip-version-check "https://github.com/marian42/octoprint-preheat/archive/master.zip"
if [[ $* == *--ptg* ]]; then
    "$DIRECTORY"/bin/pip install -q --disable-pip-version-check "https://github.com/eyal0/OctoPrint-PrintTimeGenius/archive/master.zip"
fi

echo "Installing Dependencies"
sudo apt -qq update
sudo apt -qq install $dependencies -y

echo "Installing OctoDash"
cd ~
wget -O octodash.deb $release -q --show-progress

sudo dpkg -i octodash.deb

rm octodash.deb

echo "Setting up Autostart"
cat <<EOF > ~/.xinitrc
#!/bin/sh

xset s off
xset s noblank
xset -dpms

ratpoison&
octodash
EOF

cat <<EOF >> ~/.bashrc
if [ -z "\$SSH_CLIENT" ] || [ -z "\$SSH_TTY" ]; then
    xinit -- -nocursor
fi
EOF

echo "Setting Permission"
sudo chmod +x ~/.xinitrc
sudo chmod ug+s /usr/lib/xorg/Xorg

echo "Done. OctoDash will start automatically on next reboot. Please ensure that auto-login is enabled."
