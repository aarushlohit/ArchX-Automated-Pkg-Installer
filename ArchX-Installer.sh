#!/bin/bash

update_system() {
    echo "🔄 Updating system..."
    sudo pacman -Syu base base-devel --noconfirm
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

    echo "🔧 Installing additional Hyprland packages..."
    $aur_helper -S wallust-git rofi-lbonn-wayland rofi-lbonn-wayland-git \
                pokemon-colorscripts-git wlogout zsh-theme-powerlevel10k-git grimblast-git \
                python-pyamdgpuinfo oh-my-zsh-git hyde-cli-git swaylock-effects-git --noconfirm

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
    $aur_helper -S firefox vlc gimp libreoffice-fresh neofetch --noconfirm

    if [[ "$install_hypr_pkgs" =~ ^[Yy]$ ]]; then
        echo "🔧 Installing Hyprland necessary packages..."
        $aur_helper -S wallust-git rofi-lbonn-wayland rofi-lbonn-wayland-git \
                    pokemon-colorscripts-git wlogout zsh-theme-powerlevel10k-git grimblast-git \
                    python-pyamdgpuinfo oh-my-zsh-git hyde-cli-git swaylock-effects-git --noconfirm
    fi
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
        echo "3) Install Chaotic AUR"
        echo "4) Install Hyprland"
        echo "5) Install GNOME"
        echo "6) Install Cinnamon"
        echo "7) Install General Software"
        echo "8) Exit"
        echo "===================================="
        read -p "Enter choice (1-8): " choice

        case $choice in
            1) install_paru ;;
            2) install_yay ;;
            3) install_chaotic_aur ;;
            4) install_hyprland ;;
            5) install_gnome ;;
            6) install_cinnamon ;;
            7) install_general_software ;;
            8) exit 0 ;;
            *) echo "❌ Invalid choice!" ;;
        esac

        echo "🎉 Returning to menu in 3 seconds..."
        sleep 3
        timeout 3 curl -s parrot.live
    done
}

show_menu
