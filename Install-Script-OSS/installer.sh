#!/bin/bash
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Color_Off='\033[0m'

cat <<\EOF
  _    _ _           __  __  ____     _____                                      _ _           _______          _     
 | |  | (_)         |  \/  |/ __ \   / ____|                                    (_) |         |__   __|        | |    
 | |__| |___   _____| \  / | |  | | | |     ___  _ __ ___  _ __ ___  _   _ _ __  _| |_ _   _     | | ___   ___ | |___ 
 |  __  | \ \ / / _ \ |\/| | |  | | | |    / _ \| '_ ` _ \| '_ ` _ \| | | | '_ \| | __| | | |    | |/ _ \ / _ \| / __|
 | |  | | |\ V /  __/ |  | | |__| | | |___| (_) | | | | | | | | | | | |_| | | | | | |_| |_| |    | | (_) | (_) | \__ \
 |_|  |_|_| \_/ \___|_|  |_|\___\_\  \_____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|_|\__|\__, |    |_|\___/ \___/|_|___/
                                                                                        __/ |                         
                                                                                       |___/                          
EOF

echo -e "${Yellow}Welcome to the community installer for HiveMQ OSS ${Color_Off}"
echo ""

# Installation Menu
echo "Which version do you want to install :"
echo "1. HiveMQ Community Edition"
echo "2. HiveMQ Edge Edition"
read choice
case $choice in
    1) 
        echo "Installing Community Edition."
        echo "Getting available versions"
        versions=$(curl --silent "https://api.github.com/repos/hivemq/hivemq-community-edition/releases" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        # Check if curl command was successful
        if [ $? -ne 0 ]; then
        echo -e "${Red} Failed to fetch data from $URL ${Color_Off}"
        exit 1
        fi
        ;;
    2) 
        echo "Installing Edge Edition." 
        echo "Getting latest version"
        versions=$(curl --silent "https://api.github.com/repos/hivemq/hivemq-edge/releases" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

        echo "Select an Edge version:"
        select version in $versions; do
        selectedVersion=$(echo "$version")
        echo "You selected: $selectedVersion"
        break
        done

        filename="hivemq-edge-full-${selectedVersion}"
        downloadLink="https://releases.hivemq.com/edge/${filename}.zip"
        finalDirectory="hivemq-edge-${selectedVersion}"

        echo "Downloading : ${filename}"
        curl -O ${downloadLink}
        echo -e "${Green} Success ${Color_Off}"

        echo "Unzipping ..."
        mv ${filename}.zip /opt
        cd /opt
        unzip ${filename}.zip
        echo -e "${Green} Success ${Color_Off}"

        echo "Creating seemlink"
        ln -s /opt/hivemq-edge-${selectedVersion} /opt/hivemq
        echo -e "${Green} Success ${Color_Off}"

        echo "Creating hivemq user"
        useradd -d /opt/hivemq hivemq
        echo -e "${Green} Success ${Color_Off}"

        echo "Updating files ownership"
        chown -R hivemq:hivemq /opt/hivemq-edge-${selectedVersion}
        chown -R hivemq:hivemq /opt/hivemq
        echo -e "${Green} Success ${Color_Off}"

        echo "Adding execution permission on startup script"
        cd /opt/hivemq
        chmod +x ./bin/run.sh
        echo -e "${Green} Success ${Color_Off}"

        echo "Installing HiveMQ Service"
        cp /opt/hivemq/bin/init-script/hivemq.service /etc/systemd/system/hivemq.service
        systemctl enable hivemq

        echo "Starting service"
        systemctl start hivemq
        echo -e "${Green} Success ${Color_Off}"

        echo -e "${Green}Installation done ${Color_Off}"
        ;;
    
    *) echo "Invalid choice." ;;
esac