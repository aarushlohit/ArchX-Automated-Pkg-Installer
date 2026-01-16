#!/bin/bash
# ==========================================================
# Arch Linux NVIDIA + AMD Hybrid GPU Auto-Fix Script
# Fully non-interactive (assumes YES)
# ==========================================================

set -euo pipefail

echo "🔍 Step 1: Checking GPU hardware..."
lspci | grep -E "VGA|3D" || true

echo
echo "🧰 Step 2: Updating system packages..."
sudo pacman -Syu --noconfirm --needed

echo
echo "⚙️ Step 3: Installing NVIDIA and GPU-related packages..."
sudo pacman -S  \
  nvidia \
  nvidia-utils \
  nvidia-prime \
  envycontrol \
  mesa \
  mesa-utils \
  vulkan-radeon \
  vulkan-icd-loader \
  linux-headers

echo
echo "🔧 Step 4: Ensuring EnvyControl configuration..."
sudo mkdir -p /etc
if [ ! -f /etc/EnvyControl.conf ]; then
  sudo tee /etc/EnvyControl.conf >/dev/null <<EOF
[envycontrol]
mode=hybrid
EOF
fi

echo
echo "💾 Step 5: Forcing EnvyControl hybrid mode..."
# --force avoids interactive prompts
sudo envycontrol --switch hybrid --force || true

echo
echo "🔁 Step 6: Regenerating initramfs..."
sudo mkinitcpio -P

echo
echo "🧠 Step 7: Checking NVIDIA driver status..."
if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi || echo "⚠️ NVIDIA driver installed but not active (reboot required)."
else
  echo "❌ nvidia-smi missing (unexpected)."
fi

echo
echo "🧩 Step 8: Checking OpenGL renderer..."
glxinfo | grep "OpenGL renderer" || echo "⚠️ OpenGL info unavailable."

echo
echo "✅ Setup complete!"
echo "➡️ GPU mode: hybrid (balanced)"
echo "➡️ Switch modes:"
echo "   sudo envycontrol --switch nvidia --force"
echo "   sudo envycontrol --switch integrated --force"
echo
echo "🔄 Reboot REQUIRED to apply changes:"
echo "   sudo reboot"

