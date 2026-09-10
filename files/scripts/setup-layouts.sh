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
# 5. Inject Custom Mountain-OS Wallpapers into the system folders
SYSTEM_WALLPAPER_DIR="/usr/share/wallpapers/MountainOS"
mkdir -p "${SYSTEM_WALLPAPER_DIR}"

# Natively download the high-definition cinematic Kilimanjaro image during the cloud build
curl -L -o "${SYSTEM_WALLPAPER_DIR}/kilimanjaro.jpg" \
  "https://vecteezy.com"

# 6. Create the Mountain-OS Graphical First-Boot Welcome Screen
AUTOSTART_DIR="/etc/skel/.config"
mkdir -p "${AUTOSTART_DIR}/autostart"


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
        --title=" Welcome to Mountain-OS" \
        --text=" **Welcome to Mountain-OS: Kilimanjaro!**\n\nThank you for installing our custom, high-performance Fedora desktop.\n\nYour environment is pre-configured with a premium Mac-inspired visual layout layout layout. To switch instantly to a traditional Windows layout scheme, locate and launch the **Layout Switcher** script from your application utilities utility dashboard.\n\nEnjoy your new workstation experience!" \
        --width=450 --height=250
    
    # Lock the flag file down so it never triggers again
    touch "$FIRSTBOOT_FLAG"
fi
EOF

chmod +x /usr/local/bin/mountain-welcome.sh
# 7. Create the Desktop Shortcut Toggle Engine for Layout Switching
DESKTOP_DIR="/etc/skel/Desktop"
mkdir -p "${DESKTOP_DIR}"

cat << 'EOF' > "${DESKTOP_DIR}/switch-layout.desktop"
[Desktop Entry]
Type=Application
Name=🔃 Switch Layout (Mac/Windows)
Comment=Open the layout selection panel to switch your desktop view instantly
Exec=bash /usr/local/bin/mountain-toggle.sh
Icon=preferences-desktop-display-change
Terminal=false
Categories=Utility;Settings;
EOF
chmod +x "${DESKTOP_DIR}/switch-layout.desktop"

mkdir -p /usr/local/bin
cat << 'EOF' > /usr/local/bin/mountain-toggle.sh
#!/usr/bin/env bash
STATE_FILE="$HOME/.config/.mountain_layout_state"
if [ ! -f "$STATE_FILE" ]; then
    echo "windows" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" = "mac" ]; then
    # Open the Interactive Engine console pre-loaded with your Windows Layout code
    qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.loadScriptInInteractiveConsole "/usr/share/org.mountainos/layouts/windows-layout.js"
    echo "windows" > "$STATE_FILE"
else
    # Open the Interactive Engine console pre-loaded with your Mac Layout code
    qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.loadScriptInInteractiveConsole "/usr/share/org.mountainos/layouts/mac-layout.js"
    echo "mac" > "$STATE_FILE"
fi
EOF
chmod +x /usr/local/bin/mountain-toggle.sh



# Write the actual engine script that swaps the configurations behind the scenes
cat << 'EOF' > /usr/local/bin/mountain-toggle.sh
#!/usr/bin/env bash
# Track the active display format layout state using a basic text flag
STATE_FILE="$HOME/.config/.mountain_layout_state"

if [ ! -f "$STATE_FILE" ]; then
    echo "mac" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" = "mac" ]; then
    # Morph to the Windows Panel Layout Scheme
    qdbus-qt6 org.kde.plasma-shell /PlasmaShell evaluateScriptFile "/usr/share/org.mountainos/layouts/windows-layout.js"
    echo "windows" > "$STATE_FILE"
    zenity --notification --text="Layout switched to Windows Classic Mode!" --window-icon="preferences-desktop-display-change"
else
    # Morph back to the default Mac Dock Style Arrangement
    qdbus-qt6 org.kde.plasma-shell /PlasmaShell evaluateScriptFile "/usr/share/org.mountainos/layouts/mac-layout.js"
    echo "mac" > "$STATE_FILE"
    zenity --notification --text="Layout switched to Premium Mac Aesthetic Mode!" --window-icon="preferences-desktop-display-change"
fi
EOF

# Secure execute permissions on the toggle engine
chmod +x /usr/local/bin/mountain-toggle.sh
# 8. Inject Custom Mountain-OS Accent Colors (Ice Blue Theme)
KDE_GLOBALS_DIR="/etc/skel/.config"
mkdir -p "${KDE_GLOBALS_DIR}"

# Write custom accent color profiles directly into the default user configuration
cat << 'EOF' >> "${KDE_GLOBALS_DIR}/kdeglobals"
[General]
accentColor=100,149,237,255

[Colors:Button]
BackgroundAlternate=220,230,242
BackgroundNormal=235,245,255
ForegroundNormal=0,0,0

[Colors:Selection]
BackgroundNormal=100,149,237
ForegroundNormal=255,255,255

[Colors:View]
BackgroundAlternate=240,245,250
BackgroundNormal=255,255,255
ForegroundNormal=0,0,0

[Colors:Window]
BackgroundNormal=245,248,252
ForegroundNormal=0,0,0
EOF

echo "Mountain-OS visual accents deployed successfully."
# 9. Grant Absolute System Permissions for Layout Scripting
KDE_SHELL_CONFIG="/etc/skel/.config/plasmashellrc"
mkdir -p "$(dirname ${KDE_SHELL_CONFIG})"

cat << 'EOF' >> "${KDE_SHELL_CONFIG}"
[Shell][Development]
EnableScripting=true
EOF

# Apply the permission live to the default active user profile block
mkdir -p /etc/skel/.config
cat << 'EOF' >> /etc/skel/.config/kwinrc
[Scripting]
EnableScripts=true
EOF
# 10. Force Custom Mountain-OS System Identity Branding
if [ -f "/tmp/files/os-release" ]; then
    cp "/tmp/files/os-release" /etc/os-release
    cp "/tmp/files/os-release" /usr/lib/os-release
fi

# Make Fastfetch run automatically every time a user opens a terminal window
echo "fastfetch" >> /etc/skel/.bashrc
