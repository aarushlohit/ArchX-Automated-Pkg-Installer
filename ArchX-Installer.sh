#!/bin/bash

update_system() {
    echo "🔄 Updating system..."
    sudo pacman -Syu base base-devel git --noconfirm
}

ask_reinstall() {
    local package=$1
    if pacman -Qi $package &>/dev/null; then
        read -p "⚠️ $package is already installed. Do you want to reinstall? (y/N): " choice
        [[ $choice =~ ^[Yy]$ ]] || return 1
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
    git clone https://aur.archlinux.org/paru.git && cd paru
    makepkg -si
    cd ..
}

install_yay() {
    update_system
    ask_reinstall "yay" || return
    echo "🔧 Installing Yay..."
    git clone https://aur.archlinux.org/yay.git && cd yay
    makepkg -si
    cd ..
}

install_blackarch() {
    echo "🔧 Installing BlackArch repository..."
    curl -O https://blackarch.org/strap.sh
    chmod +x strap.sh
    sudo ./strap.sh
    sudo pacman -Syyu --noconfirm
    echo "✅ BlackArch repository installed!"
}

install_chaotic_aur() {
    update_system
    echo "🔧 Installing Chaotic AUR..."
    git clone https://github.com/SharafatKarim/chaotic-AUR-installer.git && cd chaotic-AUR-installer
    chmod +x *
    sudo ./install.bash
    cd ..
}

install_hyprland() {
    update_system
    choose_aur_helper
    read -p "⚠️ Do you want to install Chaotic AUR for smoother Hyprland installation? (y/N): " choice
    [[ $choice =~ ^[Yy]$ ]] && install_chaotic_aur

    ask_reinstall "hyprland" || return

    echo "🔧 Installing Hyprland..."
    $aur_helper -S hyprland waybar rofi dunst alacritty thunar polkit-gnome nwg-look grimblast-git --noconfirm

    echo "🎨 Select Hyprland dotfiles:"
    echo "1) Jakoolit"
    echo "2) Prasanth Rangan"
    read -p "Enter choice (1 or 2): " hypr_choice

    case $hypr_choice in
        1)
            read -p "Enter your username: " user
            git clone https://github.com/Jakoolit/Arch-Hyprland.git && cd Arch-Hyprland
            mkdir -p install-scripts/Install-Logs
            sudo chmod -R 777 install-scripts/Install-Logs
            sudo chown -R ${user}:${user} install-scripts/Install-Logs
            chmod -R u+w install-scripts/Install-Logs
            ./install.sh
            cd ..
            ;;
        2)
            git clone https://github.com/prasanthrangan/hyprdots.git && cd hyprdots
            cd Scripts
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
    echo "🔧 Installing GNOME..."
    sudo pacman -S gnome gnome-extra --noconfirm
}

install_cinnamon() {
    update_system
    ask_reinstall "cinnamon" || return
    echo "🔧 Installing Cinnamon..."
    sudo pacman -S cinnamon --noconfirm
}

install_general_software() {
    update_system
    choose_aur_helper
    read -p "❓ Do you want to install Hyprland necessary packages as well? (y/N): " install_hypr_pkgs

    echo "🔧 Installing general software..."
    $aur_helper -S firefox vlc gimp libreoffice-fresh neofetch kate kwrite visual-studio-code-bin virtualbox linux-headers steam ocs-url wine winetricks obs-studio spectacle xournalpp proton proton-tricks --noconfirm

    if [[ "$install_hypr_pkgs" =~ ^[Yy]$ ]]; then
        echo "🔧 Installing Hyprland necessary packages..."
        $aur_helper -S wallust-git rofi-lbonn-wayland rofi-lbonn-wayland-git \
                    pokemon-colorscripts-git wlogout zsh-theme-powerlevel10k-git grimblast-git \
                    python-pyamdgpuinfo oh-my-zsh-git hyde-cli-git swaylock-effects-git --noconfirm
    fi
}

install_gaming_packages() {
    update_system
    read -p "❓ Do you want to use Yay (Y) or Paru (P) for installation? " choice
    case "$choice" in
        [Yy]) aur_helper="yay" ;;
        [Pp]) aur_helper="paru" ;;
        *)
            echo "⚠️ Invalid choice. Defaulting to yay."
            aur_helper="yay"
            ;;
    esac

    echo "🎮 Installing Gaming Packages..."
    $aur_helper -S heroic-games-launcher-bin lutris steam steam-native-runtime steamtinkerlaunch \
        dxvk-mingw-git gamemode mangohud lib32-mangohud vkbasalt lib32-vkbasalt protontricks-git \
        boxtron reshade-shaders-git corectrl game-devices-udev input-devices-support \
        keyboard-visualizer-git piper retroarch-autoconfig-udev-git wine-staging wine-meta --noconfirm
}

show_menu() {
    while true; do
        clear
        echo "===================================="
        echo "  ⚡ Arch Linux Package Installer ⚡"
        echo "        ⚡ Script by AarushLohit ⚡"
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
        echo "10) Exit"
        echo "===================================="
        read -p "Enter choice (1-10): " choice

        case $choice in
            1) install_paru ;;
            2) install_yay ;;
            3) install_blackarch ;;
            4) install_chaotic_aur ;;
            5) install_hyprland ;;
            6) install_gnome ;;
            7) install_cinnamon ;;
            8) install_general_software ;;
            9) install_gaming_packages ;;
            10) exit 0 ;;
            *) echo "❌ Invalid choice!" ;;
        esac

        echo "🎉 Returning to menu in 3 seconds..."
        sleep 3
        timeout 3 curl -s parrot.live
    done
}

show_menu
