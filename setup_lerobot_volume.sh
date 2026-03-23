#!/usr/bin/env bash

set -e

# ===== CONFIG =====
VOLUME_DIR="/mnt"   # <-- CHANGE THIS to your actual mounted volume path
INSTALL_DIR="$VOLUME_DIR/lerobot_setup"

echo "=== Using volume at: $VOLUME_DIR ==="
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# ===== Miniforge =====
echo "=== Installing Miniforge on volume ==="
MINIFORGE_SCRIPT="Miniforge3-$(uname)-$(uname -m).sh"
wget -q "https://github.com/conda-forge/miniforge/releases/latest/download/${MINIFORGE_SCRIPT}"

bash "${MINIFORGE_SCRIPT}" -b -p "$INSTALL_DIR/miniforge"

# Activate conda directly from volume
source "$INSTALL_DIR/miniforge/bin/activate"

# ===== Conda env =====
echo "=== Creating environment ==="
conda create -y -n lerobot python=3.12
source "$INSTALL_DIR/miniforge/bin/activate" lerobot

# ===== Dependencies =====
echo "=== Installing dependencies ==="
conda install -y -c conda-forge ffmpeg=7.1.1

# ===== Clone repo to volume =====
echo "=== Cloning LeRobot ==="
git clone https://github.com/huggingface/lerobot.git "$INSTALL_DIR/lerobot"
cd "$INSTALL_DIR/lerobot"

# ===== Install =====
echo "=== Installing LeRobot ==="
pip install -e .
pip install -e ".[pi]"

# ===== Hugging Face CLI =====
echo "=== Installing HF CLI ==="
curl -LsSf https://hf.co/cli/install.sh | bash

# ===== Redirect caches to volume =====
echo "=== Setting cache dirs to volume ==="
mkdir -p "$INSTALL_DIR/.cache"

echo "export HF_HOME=$INSTALL_DIR/.cache/huggingface" >> ~/.bashrc
echo "export TRANSFORMERS_CACHE=$INSTALL_DIR/.cache/huggingface" >> ~/.bashrc
echo "export TORCH_HOME=$INSTALL_DIR/.cache/torch" >> ~/.bashrc

echo "=== Done ==="
echo "Activate with:"
echo "source $INSTALL_DIR/miniforge/bin/activate lerobot"
