#!/usr/bin/env bash
# =========================================================================
#             🏔️ MOUNTAIN-OS: KILIMANJARO LAYOUT SETUP ENGINE 🏔️
# =========================================================================
set -xeuo pipefail

echo "Configuring Mountain-OS Panel and Window Layouts..."

# 1. Create the system-wide directory for default user layouts
TARGET_DIR="/usr/share/org.mountainos/layouts"
mkdir -p "${TARGET_DIR}"

# 2. Write the default Mac-like Plasma panel configuration template
cat << 'EOF' > "${TARGET_DIR}/mac-layout.js"
var allPanels = panels();
for (var i in allPanels) {
    allPanels[i].remove();
}

// Top Status Menu Bar (Global Menu, Clock, System Tray)
var topPanel = new Panel();
topPanel.location = "top";
topPanel.height = 28;
topPanel.addWidget("org.kde.plasma.appmenu");       
topPanel.addWidget("org.kde.plasma.panelspacer");   
topPanel.addWidget("org.kde.plasma.digitalclock");  
topPanel.addWidget("org.kde.plasma.panelspacer");   
topPanel.addWidget("org.kde.plasma.systemtray");    

// Bottom Center Application Dock
var bottomDock = new Panel();
bottomDock.location = "bottom";
bottomDock.height = 56;
bottomDock.alignment = "center";
bottomDock.lengthMode = "fit";                      
bottomDock.addWidget("org.kde.plasma.icontasks");   
EOF

# 3. Write the Windows layout alternate template 
cat << 'EOF' > "${TARGET_DIR}/windows-layout.js"
var allPanels = panels();
for (var i in allPanels) {
    allPanels[i].remove();
}

// Classic Bottom Taskbar Layout
var mainBar = new Panel();
mainBar.location = "bottom";
mainBar.height = 40;
mainBar.addWidget("org.kde.plasma.kickoff");        
mainBar.addWidget("org.kde.plasma.icontasks");      
mainBar.addWidget("org.kde.plasma.panelspacer");   
mainBar.addWidget("org.kde.plasma.systemtray");    
mainBar.addWidget("org.kde.plasma.digitalclock");
EOF

# 4. Modify Fedora default settings: Move Window buttons to the top-left corner
# We drop this into /etc/skel so every new user account automatically gets this layout
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
