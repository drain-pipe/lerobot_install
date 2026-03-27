#!/usr/bin/env bash

set -e

# ===== CONFIG =====
BASE_DIR="/workspace/lerobot"

echo "=== Installing into $BASE_DIR ==="
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# ===== GLOBAL CACHE REDIRECTION (MUST BE FIRST) =====
export HF_HOME=$BASE_DIR/.cache/huggingface
export HUGGINGFACE_HUB_CACHE=$HF_HOME
export TRANSFORMERS_CACHE=$HF_HOME
export HF_DATASETS_CACHE=$BASE_DIR/.cache/datasets
export TORCH_HOME=$BASE_DIR/.cache/torch
export PIP_CACHE_DIR=$BASE_DIR/.cache/pip
export TMPDIR=$BASE_DIR/tmp

mkdir -p $HF_HOME $HF_DATASETS_CACHE $TORCH_HOME $PIP_CACHE_DIR $TMPDIR

# Force conda cache onto volume
conda config --add pkgs_dirs $BASE_DIR/conda_pkgs || true

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

# ===== Install (NO CACHE) =====
echo "=== Installing LeRobot ==="
pip install --no-cache-dir -e .
pip install --no-cache-dir -e ".[pi]"

# ===== HF CLI =====
echo "=== Installing HF CLI ==="
curl -LsSf https://hf.co/cli/install.sh | bash

# ===== Persist env vars =====
echo "=== Persisting cache settings ==="
cat <<EOF >> ~/.bashrc
export HF_HOME=$HF_HOME
export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_HUB_CACHE
export TRANSFORMERS_CACHE=$TRANSFORMERS_CACHE
export HF_DATASETS_CACHE=$HF_DATASETS_CACHE
export TORCH_HOME=$TORCH_HOME
export PIP_CACHE_DIR=$PIP_CACHE_DIR
export TMPDIR=$TMPDIR
EOF

echo "=== Done ==="
echo "Activate with:"
echo "source $BASE_DIR/miniforge/bin/activate lerobot"
