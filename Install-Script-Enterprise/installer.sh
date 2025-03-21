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

echo ""

echo -e "${Yellow}Welcome to the community installer for HiveMQ Enterprise ${Color_Off}"
echo ""

echo "Checking OS"
if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
   osType="Debian"
fi
if [ "$(grep -Ei 'fedora|redhat' /etc/*release)" ]; then
   osType="RedHat"
fi
echo "${osType} based"

echo "Checking prerequisites"
echo "Curl & Unzip"
if [ $osType == 'Debian' ]; then
    apt install curl unzip wget -y
fi
if [ $osType == 'RedHat' ]; then
    sudo dnf install curl unzip wget -y
fi

echo "Java 17"
if type -p java; then
    echo "Found java executable in PATH"
    _java=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    echo "Found java executable in JAVA_HOME"
    _java="$JAVA_HOME/bin/java"
else
    echo "No Java Found, Installing"
    if [ $osType == 'Debian' ]; 
    then
        apt update
        apt install openjdk-17-jdk -y
    elif [ $osType == 'RedHat' ]; 
    then
        sudo dnf install java-17-openjdk.x86_64 -y
    fi
fi

if [[ "$_java" ]]; then
    version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo "Version ${version}"
    if [[ "$version" > "17" ]]; then
        echo "Version is more than 17"
    else         
        echo "Version is less than 17, install at least version 17 to run HiveMQ products"
        exit 3
    fi
fi

echo "Installing latest version of Enterprise Edition." 
echo "Downloading latest version"
wget "https://www.hivemq.com/releases/hivemq-latest.zip"
echo -e "${Green} Success ${Color_Off}"

echo "Unzipping ..."
mv hivemq-latest.zip /opt
cd /opt
unzip -o hivemq-latest.zip
echo -e "${Green} Success ${Color_Off}"

# This always get the lowest version folder so needs to be fixed in future release with an endpoint that list the official versions
pattern="hivemq"
for _dir in "${pattern}"*; do
    [ -d "${_dir}" ] && dir="${_dir}" && break
done

echo "Creating seemlink"
rm /opt/hivemq
ln -s /opt/${dir} /opt/hivemq
echo -e "${Green} Success ${Color_Off}"

echo "Creating hivemq user"
useradd -d /opt/hivemq hivemq
echo -e "${Green} Success ${Color_Off}"

echo "Updating files ownership"
chown -R hivemq:hivemq /opt/${dir}
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