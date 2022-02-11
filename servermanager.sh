#!/bin/bash

# SteamCMD APPID for the-forest-dedicated-server

# Include defaults and common functions
. /defaults

function isServerRunning() {
    if ps axg | grep -F "TheForestDedicatedServer.exe" | grep -v -F 'grep' > /dev/null; then
        true
    else
        false
    fi
}

function isVirtualScreenRunning() {
    if ps axg | grep -F "Xvfb :1 -screen 0 1024x768x24" | grep -v -F 'grep' > /dev/null; then
        true
    else
        false
    fi
}

function setupWineInBashRc() {
    echo "Setting up Wine in bashrc"
    mkdir -p /winedata/WINE64
    if [ ! -d /winedata/WINE64/drive_c/windows ]; then
      cd /winedata
      echo "Setting up WineConfig and waiting 15 seconds"
      winecfg > /dev/null 2>&1
      sleep 15
    fi
    cat >> /etc/bash.bashrc <<EOF
export WINEPREFIX=/winedata/WINE64
export WINEARCH=win64
export DISPLAY=:1.0
EOF
}

function isWineinBashRcExistent() {
    grep "wine" /etc/bash.bashrc > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Checking if Wine is set in bashrc"
        setupWineInBashRc
    fi
}

function startVirtualScreenAndRebootWine() {
    # Start X Window Virtual Framebuffer
    export WINEPREFIX=/winedata/WINE64
    export WINEARCH=win64
    export DISPLAY=:1.0
    Xvfb :1 -screen 0 1024x768x24 &
    wineboot -r
}

function installServer() {
    # force a fresh install of all
    mkdir -p /config/gamefiles /config/saves
    bash /home/steam/steamcmd/steamcmd.sh +runscript /steamcmdinstall.txt
}

function config() {
    isWineinBashRcExistent
    cp /server.cfg.example /config/config.cfg
    sed -i -e "s/##SERVERIP##/$SERVERIP/g" /config/config.cfg
    sed -i -e "s/##SERVERSTEAMPORT##/$SERVERSTEAMPORT/g" /config/config.cfg
    sed -i -e "s/##SERVERGAMEPORT##/$SERVERGAMEPORT/g" /config/config.cfg
    sed -i -e "s/##SERVERQUERYPORT##/$SERVERQUERYPORT/g" /config/config.cfg
    sed -i -e "s/##SERVERNAME##/$SERVERNAME/g" /config/config.cfg
    sed -i -e "s/##SERVERPLAYERS##/$SERVERPLAYERS/g" /config/config.cfg
    sed -i -e "s/##ENABLEVAC##/$ENABLEVAC/g" /config/config.cfg
    sed -i -e "s/##SERVERPASSWORD##/$SERVERPASSWORD/g" /config/config.cfg
    sed -i -e "s/##SERVERPASSWORDADMIN##/$SERVERPASSWORDADMIN/g" /config/config.cfg
    sed -i -e "s/##SERVERSTEAMACCOUNT##/$SERVERSTEAMACCOUNT/g" /config/config.cfg
    sed -i -e "s/##SERVERAUTOSAVEINTERVAL##/$SERVERAUTOSAVEINTERVAL/g" /config/config.cfg
    sed -i -e "s/##DIFFICULTY##/$DIFFICULTY/g" /config/config.cfg
    sed -i -e "s/##INITTYPE##/$INITTYPE/g" /config/config.cfg
    sed -i -e "s/##SLOT##/$SLOT/g" /config/config.cfg
    sed -i -e "s/##SHOWLOGS##/$SHOWLOGS/g" /config/config.cfg
    sed -i -e "s/##SERVERCONTACT##/$SERVERCONTACT/g" /config/config.cfg
    sed -i -e "s/##VEGANMODE##/$VEGANMODE/g" /config/config.cfg
    sed -i -e "s/##VEGETARIANMODE##/$VEGETARIANMODE/g" /config/config.cfg
    sed -i -e "s/##RESETHOLESMODE##/$RESETHOLESMODE/g" /config/config.cfg
    sed -i -e "s/##TREEREGROWMODE##/$TREEREGROWMODE/g" /config/config.cfg
    sed -i -e "s/##ALLOWBUILDINGDESTRUCTION##/$ALLOWBUILDINGDESTRUCTION/g" /config/config.cfg
    sed -i -e "s/##ALLOWENEMIESCREATIVEMODE##/$ALLOWENEMIESCREATIVEMODE/g" /config/config.cfg
    sed -i -e "s/##ALLOWCHEATS##/$ALLOWCHEATS/g" /config/config.cfg
    sed -i -e "s/##REALISTICPLAYERDAMAGE##/$REALISTICPLAYERDAMAGE/g" /config/config.cfg
}

function startServer() {
    if ! isVirtualScreenRunning; then
        startVirtualScreenAndRebootWine
    fi
    rm /tmp/.X1-lock 2> /dev/null
    cd /config/gamefiles
    wine64 /config/gamefiles/TheForestDedicatedServer.exe -batchmode -dedicated -savefolderpath /config/saves/ -configfilepath /config/config.cfg
}

function startMain() {
    # Check if server is installed, if not try again
    if [ ! -f "/config/gamefiles/TheForestDedicatedServer.exe" ]; then
        installServer
    fi
    config
    startServer
}

startMain