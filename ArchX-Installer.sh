#!/bin/bash

# ==============================
# ⚡ Arch Linux Package Installer ⚡
#        Script by aarushLohit
# ==============================

update_system() {
    echo "🔄 Updating system..."
    sudo pacman -Syu base base-devel --noconfirm
}

is_installed() {
    pacman -Qq "$1" &>/dev/null
}

ask_reinstall() {
    local package=$1
    if is_installed "$package"; then
        read -p "⚠️ $package is already installed. Do you want to reinstall? (y/N): " choice
        [[ $choice =~ ^[Yy]$ ]] || return 1
    fi
    return 0
}

choose_aur_helper() {
    read -p "❓ Which AUR helper do you want to use (yay/paru)? " aur_helper
    [[ "$aur_helper" != "yay" && "$aur_helper" != "paru" ]] && aur_helper="yay"
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

install_blackarch_repo() {
    echo "🔧 Installing BlackArch Repository..."
    curl -O https://blackarch.org/strap.sh
    echo "🔐 Verifying script signature..."
    echo "Please manually verify the signature for now."
    chmod +x strap.sh
    sudo ./strap.sh
    sudo pacman -Syu
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

    if pacman -Qq hyprland &>/dev/null; then
        read -p "⚠️ Hyprland is already installed. Do you want to reinstall? (y/N): " reinstall_choice
        [[ ! "$reinstall_choice" =~ ^[Yy]$ ]] && return
    fi

    echo "🔧 Installing Hyprland and dependencies..."
    $aur_helper -Rns rofi-lbonn-wayland-git --noconfirm 2>/dev/null
    $aur_helper -S hyprland waybar rofi dunst alacritty thunar polkit-gnome nwg-look grimblast-git --noconfirm

    echo "🔧 Installing additional Hyprland packages..."
    $aur_helper -S wallust-git rofi-lbonn-wayland rofi-lbonn-wayland-git \
                pokemon-colorscripts-git wlogout zsh-theme-powerlevel10k-git \
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
    $aur_helper -S firefox vlc gimp libreoffice-fresh neofetch kate kwrite visual-studio-code-bin virtualbox linux-headers steam ocs-url wine winetricks obs-studio spectacle xournalpp proton proton-tricks --noconfirm

    if [[ "$install_hypr_pkgs" =~ ^[Yy]$ ]]; then
        $aur_helper -S wallust-git rofi-lbonn-wayland rofi-lbonn-wayland-git \
                    pokemon-colorscripts-git wlogout zsh-theme-powerlevel10k-git \
                    python-pyamdgpuinfo oh-my-zsh-git hyde-cli-git swaylock-effects-git --noconfirm
    fi
}

install_gaming_packages() {
    update_system
    choose_aur_helper
    echo "🎮 Installing Gaming Packages..."
    $aur_helper -S steam lutris wine wine-gecko wine-mono gamemode goverlay protonup-qt heroic-games-launcher-bin bottles --noconfirm
}

flutter_setup() {
cat <<EOF

⚠️  BEFORE WE START ⚠️
👉 Download Flutter SDK (Linux) from:
   https://docs.flutter.dev/get-started/install/linux

📂 Save it as: ~/Downloads/flutter.zip

EOF
read -p "✅ Press Enter once you've done that..."

echo "==> 🔄 Updating system..."
sudo pacman -Syu --noconfirm

echo "==> 🧰 Installing dependencies..."
sudo pacman -S --noconfirm git unzip wget curl base-devel jdk-openjdk zip yay

echo "==> 📁 Extracting Flutter SDK..."
mkdir -p ~/.flutter
[[ ! -f "$HOME/Downloads/flutter.zip" ]] && { echo "❌ flutter.zip not found!"; exit 1; }

unzip -q "$HOME/Downloads/flutter.zip" -d ~/.flutter-temp
mv ~/.flutter-temp/flutter/* ~/.flutter/
rm -rf ~/.flutter-temp
echo 'export PATH="$PATH:$HOME/.flutter/bin"' >> ~/.zshrc
export PATH="$PATH:$HOME/.flutter/bin"

echo "==> 📦 Installing Android SDK..."
yay -S --noconfirm android-sdk android-sdk-platform-tools android-sdk-build-tools

echo "==> ⚙️ Setting ANDROID_HOME..."
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.zshrc
echo 'export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"' >> ~/.zshrc
export ANDROID_HOME=$HOME/Android/Sdk
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"

echo "==> 📥 Downloading Android cmdline-tools..."
mkdir -p $ANDROID_HOME/cmdline-tools/latest
wget -O cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
unzip -q cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools/latest
mv $ANDROID_HOME/cmdline-tools/latest/cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest/
rm -rf $ANDROID_HOME/cmdline-tools/latest/cmdline-tools cmdline-tools.zip

echo "==> ✅ Accepting licenses..."
yes | sdkmanager --licenses
sdkmanager --install "cmdline-tools;latest"

echo "==> 💻 Installing Android Studio & VS Code..."
yay -S --noconfirm android-studio visual-studio-code-bin

echo "==> 🧱 Linux desktop toolchain..."
sudo pacman -S --noconfirm clang cmake ninja gtk3

echo "==> 🌐 Installing Google Chrome (optional)..."
yay -S --noconfirm google-chrome

echo "🎯 Running flutter doctor..."
flutter doctor

echo "🎉 Flutter setup complete, gorgeous 💕"
echo "💡 Restart terminal or run: source ~/.zshrc"
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
        echo "10) Flutter Setup"
        echo "11) Exit"
        echo "===================================="
        read -p "Enter choice (1-11): " choice

        case $choice in
            1) install_paru ;;
            2) install_yay ;;
            3) install_blackarch_repo ;;
            4) install_chaotic_aur ;;
            5) install_hyprland ;;
            6) install_gnome ;;
            7) install_cinnamon ;;
            8) install_general_software ;;
            9) install_gaming_packages ;;
            10) flutter_setup ;;
            11) exit 0 ;;
            *) echo "❌ Invalid choice!" ;;
        esac

        echo "🎉 Returning to menu in 3 seconds..."
        sleep 3
        timeout 3 curl -s parrot.live
    done
}

show_menu

