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
# 6. Create the Mountain-OS Graphical First-Boot Welcome Screen
AUTOSTART_DIR="/etc/skel/.config/autostart"
mkdir -p "${AUTOSTART_DIR}"

# Write the background starter configuration shortcut
cat << 'EOF' > "${AUTOSTART_DIR}/mountain-welcome.desktop"
[Desktop Entry]
Type=Application
Name=Mountain-OS Welcome
Exec=/usr/local/bin/mountain-welcome.sh
Icon=utilities-terminal
Terminal=false
X-KDE-AutostartScript=true
EOF

# Write the actual graphical script that triggers the welcome prompt window
mkdir -p /usr/local/bin
cat << 'EOF' > /usr/local/bin/mountain-welcome.sh
#!/usr/bin/env bash
# Only show this pop-up once so it doesn't annoy the user on every single boot
FIRSTBOOT_FLAG="$HOME/.config/.mountain_welcome_done"
if [ ! -f "$FIRSTBOOT_FLAG" ]; then
    zenity --info \
        --title="🏔️ Welcome to Mountain-OS" \
        --text="✨ **Welcome to Mountain-OS: Kilimanjaro!**\n\nThank you for installing our custom, high-performance Fedora desktop.\n\nYour environment is pre-configured with a premium Mac-inspired visual layout layout layout. To switch instantly to a traditional Windows layout scheme, locate and launch the **Layout Switcher** script from your application utilities utility dashboard.\n\nEnjoy your new workstation experience!" \
        --width=450 --height=250
    
    # Lock the flag file down so it never triggers again
    touch "$FIRSTBOOT_FLAG"
fi
EOF

chmod +x /usr/local/bin/mountain-welcome.sh
