#!/usr/bin/env bash

set -e

# ===== CONFIG =====
BASE_DIR="/workspace/lerobot_setup"

echo "=== Installing into $BASE_DIR ==="
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# ===== Miniforge =====
echo "=== Installing Miniforge ==="
MINIFORGE_SCRIPT="Miniforge3-$(uname)-$(uname -m).sh"
wget -q "https://github.com/conda-forge/miniforge/releases/latest/download/${MINIFORGE_SCRIPT}"

bash "${MINIFORGE_SCRIPT}" -b -p "$BASE_DIR/miniforge"

# Activate conda
source "$BASE_DIR/miniforge/bin/activate"

# ===== Environment =====
echo "=== Creating env ==="
conda create -y -n lerobot python=3.12
source "$BASE_DIR/miniforge/bin/activate" lerobot

# ===== Dependencies =====
echo "=== Installing dependencies ==="
conda install -y -c conda-forge ffmpeg=7.1.1

# ===== Clone repo =====
echo "=== Cloning LeRobot ==="
git clone https://github.com/huggingface/lerobot.git
cd lerobot

# ===== Install =====
echo "=== Installing LeRobot ==="
pip install -e .
pip install -e ".[pi]"

# ===== HF CLI =====
echo "=== Installing HF CLI ==="
curl -LsSf https://hf.co/cli/install.sh | bash

# ===== Cache redirection (CRITICAL) =====
echo "=== Redirecting caches ==="
mkdir -p "$BASE_DIR/.cache"

cat <<EOF >> ~/.bashrc
export HF_HOME=$BASE_DIR/.cache/huggingface
export TRANSFORMERS_CACHE=$BASE_DIR/.cache/huggingface
export TORCH_HOME=$BASE_DIR/.cache/torch
export TMPDIR=$BASE_DIR/tmp
EOF

mkdir -p "$BASE_DIR/tmp"

echo "=== Done ==="
echo "Activate with:"
echo "source $BASE_DIR/miniforge/bin/activate lerobot"
