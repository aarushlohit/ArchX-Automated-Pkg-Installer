#!/bin/bash

# ==============================
# ⚡ Arch Linux Package Installer ⚡
#        Script by aarushLohit
# ==============================

set -e

update_system() {
    echo "🔄 Updating system..."
    sudo pacman -Syu base base-devel --noconfirm
    rm -rf ~/.cache/vulkan
}

is_installed() {
    pacman -Qq "$1" &>/dev/null
}

ask_reinstall() {
    local package=$1
    if is_installed "$package"; then
        read -p "⚠️ $package is already installed. Do you want to reinstall? (y/N): " choice
        [[ "$choice" =~ ^[Yy]$ ]] || return 1
    fi
    return 0
}

choose_aur_helper() {
    read -p "❓ Which AUR helper do you want to use (yay/paru)? " aur_helper
    if [[ "$aur_helper" != "yay" && "$aur_helper" != "paru" ]]; then
        echo "⚠️ Invalid choice. Defaulting to yay."
        aur_helper="yay"
    fi
}

install_paru() {
    update_system
    ask_reinstall "paru" || return
    echo "🔧 Installing Paru..."
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru/
}

install_yay() {
    update_system
    ask_reinstall "yay" || return
    echo "🔧 Installing Yay..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay/
}

install_blackarch_repo() {
    echo "🔧 Installing BlackArch Repository..."
    curl -O https://blackarch.org/strap.sh
    echo "🔐 Please manually verify the script signature before proceeding!"
    chmod +x strap.sh
    sudo ./strap.sh
    rm -f strap.sh
    sudo pacman -Syu
}

install_chaotic_aur() {
    update_system
    echo "🔧 Installing Chaotic AUR..."
    git clone https://github.com/SharafatKarim/chaotic-AUR-installer.git
    cd chaotic-AUR-installer
    chmod +x install.bash
    sudo ./install.bash
    cd ..
    rm -rf chaotic-AUR-installer/
}

install_hyprland() {
    update_system
    choose_aur_helper

    read -p "⚠️ Do you want to install Chaotic AUR for smoother Hyprland installation? (y/N): " choice
    [[ "$choice" =~ ^[Yy]$ ]] && install_chaotic_aur

    if is_installed "hyprland"; then
        read -p "⚠️ Hyprland is already installed. Do you want to reinstall? (y/N): " reinstall_choice
        [[ ! "$reinstall_choice" =~ ^[Yy]$ ]] && return
    fi

    echo "🔧 Installing Hyprland and dependencies..."
    $aur_helper -Rns rofi-lbonn-wayland-git 2>/dev/null || true
    $aur_helper -S hyprland waybar dunst alacritty thunar polkit-gnome nwg-look grimblast-git

    echo "🔧 Installing additional Hyprland packages..."
    $aur_helper -S wallust-git rofi-lbonn-wayland rofi-lbonn-wayland-git \
                pokemon-colorscripts-git wlogout zsh-theme-powerlevel10k-git \
                python-pyamdgpuinfo oh-my-zsh-git hyde-cli-git swaylock-effects-git

    echo "🎨 Select Hyprland dotfiles:"
    echo "1) Jakoolit"
    echo "2) Prasanth Rangan"
    read -p "Enter choice (1 or 2): " hypr_choice

    case "$hypr_choice" in
        1)
            read -p "Enter your username: " user
            git clone https://github.com/Jakoolit/Arch-Hyprland.git
            cd Arch-Hyprland
            mkdir -p install-scripts/Install-Logs
            sudo chmod -R 777 install-scripts/Install-Logs
            sudo chown -R "${user}:${user}" install-scripts/Install-Logs
            chmod -R u+w install-scripts/Install-Logs
            ./install.sh
            cd ..
            rm -rf Arch-Hyprland/
            ;;
        2)
            git clone https://github.com/prasanthrangan/hyprdots.git
            cd hyprdots/Scripts
            sudo ./install.sh
            cd ../..
            ;;
        *)
            echo "❌ Invalid choice. Skipping Hyprland dotfiles."
            ;;
    esac
}

install_gnome() {
    update_system
    ask_reinstall "gnome" || return
    sudo pacman -S gnome gnome-extra --noconfirm
}

install_cinnamon() {
    update_system
    ask_reinstall "cinnamon" || return
    sudo pacman -S cinnamon --noconfirm
}

install_general_software() {
    update_system
    choose_aur_helper

    read -p "❓ Do you want to install Hyprland packages too? (y/N): " install_hypr_pkgs

    echo "🔧 Installing general software..."
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-add --if-not-exists --subset=verified flathub-verified https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-add --if-not-exists --subset=verified_floss flathub-verified_floss https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
    sudo flatpak remote-add --if-not-exists eclipse-nightly https://download.eclipse.org/linuxtools/flatpak-I-builds/eclipse.flatpakrepo

    sudo flatpak install -y flathub com.gigitux.youp

    $aur_helper -S android-studio visual-studio-code-bin google-chrome \
         android-sdk-platform-tools android-sdk-build-tools \
        firefox vlc gimp libreoffice-fresh neofetch kate kwrite virtualbox \
        linux-headers steam ocs-url wine winetricks obs-studio spectacle \
        xournalpp proton proton-tricks extension-manager ark vulkan-intel lib32-vulkan-intel vulkan-tools --noconfirm

    sudo pacman -S --noconfirm clang cmake ninja gtk3

    if [[ "$install_hypr_pkgs" =~ ^[Yy]$ ]]; then
        $aur_helper -S wallust-git rofi-lbonn-wayland rofi-lbonn-wayland-git \
                    pokemon-colorscripts-git wlogout zsh-theme-powerlevel10k-git \
                    python-pyamdgpuinfo oh-my-zsh-git hyde-cli-git swaylock-effects-git
    fi
}

install_gaming_packages() {
    update_system
    choose_aur_helper
    echo "🎮 Installing Gaming Packages..."
    $aur_helper -S steam lutris wine wine-gecko wine-mono gamemode \
        goverlay protonup-qt heroic-games-launcher-bin bottles --noconfirm
}

install_hacking_tools() {
    update_system
    echo "🔧 Installing Hacking Tools..."
    yay -S --noconfirm metasploit bettercap beef nmap zenmap nikto masscan gobuster recon-ng scapy tcpdump wireshark-qt john hydra rainbowcrack wordlists sqlmap aircrack-ng reaver airgeddon autopsy sleuthkit volatility3 burpsuite zaproxy gophish maltego s
}

show_menu() {
    while true; do
        clear
        echo "===================================="
        echo "  ⚡ Arch Linux Package Installer ⚡"
        echo "        ⚡ Script by aarushLohit ⚡"
        echo "===================================="
        echo "1) Install Paru"
        echo "2) Install Yay"
        echo "3) Install BlackArch Repository"
        echo "4) Install Chaotic AUR"
        echo "5) Install Hyprland"
        echo "6) Install GNOME"
        echo "7) Install Cinnamon"
        echo "8) Install General Software"
        echo "9) Install Gaming Packages"
        echo "10) Install Hacking Tools" # New menu option
        echo "11) Exit"
        echo "===================================="
        read -p "Enter choice (1-11): " choice

        case "$choice" in
            1) install_paru ;;
            2) install_yay ;;
            3) install_blackarch_repo ;;
            4) install_chaotic_aur ;;
            5) install_hyprland ;;
            6) install_gnome ;;
            7) install_cinnamon ;;
            8) install_general_software ;;
            9) install_gaming_packages ;;
            10) install_hacking_tools ;; # Call new function for hacking tools
            11) echo "👋 Bye!"; exit 0 ;;
            *) echo "❌ Invalid choice!" ;;
        esac

        echo "🎉 Returning to menu in 3 seconds..."
        sleep 3
        timeout 3 curl -s parrot.live || true
    done
}

show_menu #add new option flutter install append this code #!/bin/bash

echo "✨ Setting up Flutter environment..."

# Step 1: Install Android Studio and Chrome using yay
yay -S --needed android-studio google-chrome

# Ask user if Android Studio is configured
read -p "🛠️  Did you finish configuring Android Studio (SDK path, etc)? (y/n): " studio_configured

if [[ "$studio_configured" == "y" || "$studio_configured" == "Y" ]]; then
    # Step 2: Create flutter directory and clone the stable channel
    mkdir -p ~/.flutter
    git clone https://github.com/flutter/flutter.git -b stable ~/.flutter

    # Step 3: Add Flutter to PATH
    if ! grep -q ".flutter/bin" ~/.bashrc; then
        echo 'export PATH="$HOME/.flutter/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.flutter/bin:$PATH"
        echo "✅ Flutter path added to .bashrc"
    else
        echo "ℹ️ Flutter path already exists in .bashrc"
    fi

    # Step 4: Fix Chrome path issue
    if [ -f /usr/bin/google-chrome-stable ]; then
        sudo cp /usr/bin/google-chrome-stable /usr/bin/google-chrome
        echo "🔧 Linked google-chrome-stable to google-chrome"
    fi

    # Step 5: Run Flutter doctor
    echo "🚀 Running Flutter Doctor..."
    flutter doctor
    flutter doctor --android-licenses
    flutter doctor

    echo "🎉 Flutter setup complete, baby! You're all set to code 🌈"
else
    echo "⏸️ Okay baby, finish your Android Studio setup first and then run me again 💕"
fi
