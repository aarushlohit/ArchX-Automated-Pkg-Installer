#!/bin/bash

# ⚡ Arch Linux Package Installer ⚡
#        Script by aarushLohit

set -e

# Define colors for menu only
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'
show_success() {
    echo -e "✅ $1 is successfully installed!"
    echo -e "🔁 Returning to home in 3 seconds..."
    sleep 1

    # Check if cowsay is installed
    if ! command -v cowsay &> /dev/null; then
        echo "Cowsay not found. Installing cowsay..."
        sudo pacman -S --noconfirm cowsay
    fi

    # Run cowsay if installed
    if command -v cowsay &> /dev/null; then
        cowsay "Successfully installed"
    else
        echo "Cowsay installation failed. Skipping animation."
    fi

    sleep 3
}


# Update system
update_system() {
    echo "🔄 Updating system..."
    sudo pacman -Syu base base-devel --noconfirm
    rm -rf ~/.cache/vulkan
}
#!/bin/bash

setup_apache() {
  echo "🌐 Starting Apache Web Server setup..."

  echo "📦 Installing Apache (httpd)..."
  sudo pacman -S --noconfirm apache

  echo "🚀 Enabling and starting httpd service..."
  sudo systemctl enable httpd
  sudo systemctl start httpd

  echo "📄 Creating default index.html..."
  sudo mkdir -p /srv/http
  echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hello Baby</title>
</head>
<body>
    <h1>Hello baby 🥺</h1>
</body>
</html>' | sudo tee /srv/http/index.html > /dev/null

  echo "🔐 Setting permissions..."
  sudo chown -R root:http /srv/http
  sudo chmod -R 755 /srv/http

  echo "✅ Apache is installed and running!"
  echo "🌍 Visit: http://localhost to see your baby page~"
}
# Check if a package is installed
is_installed() {
    pacman -Qq "$1"
}
rate_mirrors() {
    # Install rate-mirrors if not installed
    if ! command -v rate-mirrors &> /dev/null; then
        echo "Rate-mirrors not found. Installing rate-mirrors..."
        yay -S --noconfirm rate-mirrors
    fi

    # Backup the current mirrorlist
    echo "Backing up current mirrorlist..."
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

    # Run rate-mirrors to rank mirrors and update the mirrorlist
    echo "Ranking mirrors and updating mirrorlist..."
    sudo rate-mirrors --allow-root arch | sudo tee /etc/pacman.d/mirrorlist

    # Display success message
    show_success "Rate-mirrors"
}

# Ask if reinstall
ask_reinstall() {
    local package=$1
    if is_installed "$package"; then
        read -p "⚠️ $package is already installed. Do you want to reinstall? (y/N): " choice
        [[ "$choice" =~ ^[Yy]$ ]] || return 1
    fi
    return 0
}

# Install BlackArch repo
install_blackarch_repo() {
    echo "🖤 Installing BlackArch Repository..."
    echo "🔐 Please manually verify the script signature before proceeding!"
    chmod +x strap.sh
    sudo ./strap.sh
    rm -f strap.sh
    sudo pacman -S --needed ettercap dnsmasq bully pixiewps isc-dhcp asleap hashcat hostapd tcpdump tshark mdk4 reaver hcxdumptool hcxtools john crunch lighttpd
    sudo pacman -Syu
    show_success "BlackArch Repository"
}

# Choose AUR helper
choose_aur_helper() {
    read -p "Which AUR helper do you want to use? (yay/paru): " aur_helper
    if [[ "$aur_helper" != "yay" && "$aur_helper" != "paru" ]]; then
        echo "⚠️ Invalid choice. Defaulting to yay."
        aur_helper="yay"
    fi
}

# Install Paru
install_paru() {
    update_system
    ask_reinstall "paru" || return
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru/
    show_success "Paru"
}

# Install Yay
install_yay() {
    sudo pacman -Syy
    update_system
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay/
    show_success "Yay"
}

# Install Chaotic AUR
install_chaotic_aur() {
    update_system
    git clone https://github.com/SharafatKarim/chaotic-AUR-installer.git
    cd chaotic-AUR-installer
    chmod +x install.bash
    sudo ./install.bash
    cd ..
    rm -rf chaotic-AUR-installer/
    show_success "Chaotic AUR"
}

# Hyprland packages
install_hyprland_packages_only() {
    hyprland_pkgs=(
        "hyprland" "waybar" "dunst" "alacritty" "thunar"
        "polkit-gnome" "nwg-look" "grimblast-git" "wallust-git"
        "rofi-lbonn-wayland" "rofi-lbonn-wayland-git" "pokemon-colorscripts-git"
        "wlogout" "zsh-theme-powerlevel10k-git" "python-pyamdgpuinfo"
        "oh-my-zsh-git" "hyde-cli-git" "swaylock-effects-git"
    )
    $aur_helper -S "${hyprland_pkgs[@]}"
}

# Full Hyprland install
install_hyprland() {
    update_system
    choose_aur_helper
    read -p "Do you want to install Chaotic AUR for smoother Hyprland installation? (y/N): " choice
    [[ "$choice" =~ ^[Yy]$ ]] && install_chaotic_aur

    if is_installed "hyprland"; then
        read -p "⚠️ Hyprland is already installed. Do you want to reinstall? (y/N): " reinstall_choice
        [[ ! "$reinstall_choice" =~ ^[Yy]$ ]] && return
    fi

    install_hyprland_packages_only

    echo "Select Hyprland dotfiles:"
    echo "1) Jakoolit"
    echo "2) Prasanth Rangan"
    read -p "Enter your choice (1 or 2): " hypr_choice

    case "$hypr_choice" in
        1)
            read -p "Enter your username: " user
            git clone https://github.com/Jakoolit/Arch-Hyprland.git
            cd Arch-Hyprland
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
    show_success "Hyprland"
}

install_gnome() {
    update_system
    ask_reinstall "gnome" || return
    sudo pacman -S gnome gnome-extra --noconfirm
    show_success "GNOME"
}

install_cinnamon() {
    update_system
    ask_reinstall "cinnamon" || return
    sudo pacman -S cinnamon --noconfirm
    show_success "Cinnamon"
}

install_plasma() {
    update_system
    ask_reinstall "plasma" || return
    sudo pacman -S plasma-meta --noconfirm
    show_success "Plasma"
}

install_flutter() {
    read -p "🛠️  Did you finish configuring Android Studio (SDK path, etc)? (y/n): " studio_configured
    if [[ "$studio_configured" =~ ^[Yy]$ ]]; then
        mkdir -p ~/.flutter
        git clone https://github.com/flutter/flutter.git -b stable ~/.flutter
        echo 'export PATH="$HOME/.flutter/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/.flutter/bin:$PATH"' >> ~/.zshrc
        show_success "Flutter"
    else
        echo "⏸️ Please finish setting up Android Studio first and then run again."
    fi
}

install_general_software() {
    update_system
    choose_aur_helper
    read -p "Do you want to install Hyprland packages? (y/N): " hypr_pkgs_choice
    install_hyprland_pkgs=false
    [[ "$hypr_pkgs_choice" =~ ^[Yy]$ ]] && install_hyprland_pkgs=true

    # Flatpak setup - errors are not suppressed
    sudo flatpak install flathub org.gnome.Platform/x86_64/48
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-add --if-not-exists --subset=verified flathub-verified https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-add --if-not-exists --subset=verified_floss flathub-verified_floss https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-add --if-not-exists gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
    sudo flatpak remote-add --if-not-exists eclipse-nightly https://download.eclipse.org/linuxtools/flatpak-I-builds/eclipse.flatpakrepo

    # Install general software packages (without suppression)
    sudo pacman -S --noconfirm clang cmake ninja gtk3

    # Install AUR packages, suppress output
    $aur_helper -S visual-studio-code-bin google-chrome \
        android-sdk-platform-tools android-sdk-build-tools \
        firefox vlc gimp libreoffice-fresh kate kwrite \
        virtualbox steam ocs-url obs-studio spectacle \
        xournalpp protontricks extension-manager ark \
        vulkan-intel lib32-vulkan-intel vulkan-tools zapzap thunderbird \
        rate-mirrors power-profiles-daemon 
    
    # Install Hyprland packages only if needed
    if $install_hyprland_pkgs; then
        install_hyprland_packages_only
    fi

    # Remove debug packages (without output suppression)
    yay -Rns rofi-lbonn-wayland-git-debug yay-debug || true

    show_success "General Software"
}

install_gaming_packages() {
    update_system
    choose_aur_helper
    $aur_helper -S steam lutris wine wine-gecko wine-mono gamemode \
        protonup-qt heroic-games-launcher-bin bottles --noconfirm
    show_success "Gaming Packages"
}

install_hacking_tools() {
    update_system
    # Install hacking tools with output suppression
    sudo pacman -S --noconfirm metasploit bettercap beef nmap zenmap \
        nikto masscan gobuster recon-ng scapy tcpdump wireshark-qt \
        john hydra rainbowcrack sqlmap aircrack-ng reaver airgeddon \
        autopsy sleuthkit volatility3 burpsuite zaproxy gophish maltego
    show_success "Hacking Tools"
}


setup_android_studio() {
    read -p "Have you downloaded Android Studio to your Downloads folder? (y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        mkdir -p ~/development
        mv ~/Downloads/android-studio-*.tar.gz ~/development/
        cd ~/development
        tar -xf android-studio-*.tar.gz
        echo 'export PATH="$HOME/development/android-studio/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/development/android-studio/bin:$PATH"' >> ~/.zshrc
        source ~/.bashrc
        source ~/.zshrc
        show_success "Android Studio"
    else
        echo "❌ Please download Android Studio first."
    fi
}
main_menu() {
    clear
    echo " Welcome to your lovely Arch installer menu, baby 💖"
    echo "Please choose an option:"
    echo " 1) Install Paru"
    echo " 2) Install Yay"
    echo " 3) Install Hyprland"
    echo " 4) Install GNOME"
    echo " 5) Install Cinnamon"
    echo " 6) Install Plasma"
    echo " 7) Install Flutter"
    echo " 8) Install General Software"
    echo " 9) Install Gaming Packages"
    echo "10) Install Hacking Tools"
    echo "11) Setup Android Studio"
    echo "12) Install Chaotic AUR"
    echo "13) Install BlackArch Repo"
    echo "14) Setup Apache Server"
    echo "15) Install Rate-Mirrors"
    echo "16) 💕 Exit"
    echo -n "Enter your choice (1-16): "
    read choice
}

# Infinite loop for menu
while true; do
    main_menu
    case "$choice" in
        1) install_paru ;;
        2) install_yay ;;
        3) install_hyprland ;;
        4) install_gnome ;;
        5) install_cinnamon ;;
        6) install_plasma ;;
        7) install_flutter ;;
        8) install_general_software ;;
        9) install_gaming_packages ;;
        10) install_hacking_tools ;;
        11) setup_android_studio ;;
        12) install_chaotic_aur ;;
        13) install_blackarch_repo ;;
        14) setup_apache ;;
        15) rate_mirrors ;;   # Updated to call the rate_mirrors function
        16) echo "👋 Exiting... Have a lovely Arch day, baby 💕"; exit 0 ;;  # Keep the exit option
        *) echo "❌ Invalid choice. Please try again." ; sleep 2 ;;
    esac
done
