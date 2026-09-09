#!/usr/bin/env bash
set -xeuo pipefail

echo "Configuring Mountain-OS Panel and Window Layouts..."

TARGET_DIR="/usr/share/org.mountainos/layouts"
mkdir -p "${TARGET_DIR}"

cat << 'EOF' > "${TARGET_DIR}/mac-layout.js"
var allPanels = panels();
for (var i in allPanels) {
    allPanels[i].remove();
}
var topPanel = new Panel();
topPanel.location = "top";
topPanel.height = 28;
topPanel.addWidget("org.kde.plasma.appmenu");       
topPanel.addWidget("org.kde.plasma.panelspacer");   
topPanel.addWidget("org.kde.plasma.digitalclock");  
topPanel.addWidget("org.kde.plasma.panelspacer");   
topPanel.addWidget("org.kde.plasma.systemtray");    

var bottomDock = new Panel();
bottomDock.location = "bottom";
bottomDock.height = 56;
bottomDock.alignment = "center";
bottomDock.lengthMode = "fit";                      
bottomDock.addWidget("org.kde.plasma.icontasks");   
EOF

cat << 'EOF' > "${TARGET_DIR}/windows-layout.js"
var allPanels = panels();
for (var i in allPanels) {
    allPanels[i].remove();
}
var mainBar = new Panel();
mainBar.location = "bottom";
mainBar.height = 40;
mainBar.addWidget("org.kde.plasma.kickoff");        
mainBar.addWidget("org.kde.plasma.icontasks");      
mainBar.addWidget("org.kde.plasma.panelspacer");   
mainBar.addWidget("org.kde.plasma.systemtray");    
mainBar.addWidget("org.kde.plasma.digitalclock");
EOF

FEDORA_SKEL_DIR="/etc/skel/.config"
mkdir -p "${FEDORA_SKEL_DIR}"

cat << 'EOF' > "${FEDORA_SKEL_DIR}/kwinrc"
[org.kde.kdecoration2]
ButtonsOnLeft=XIA
ButtonsOnRight=F
CloseOnDoubleClickOnMenu=false
ThemeName=Breeze
EOF

echo "Mountain-OS visual profiles configured successfully."
