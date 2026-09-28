#!/bin/bash

SERVER_DIR="<bedrock_server.sh launcher location here>"
cd "$SERVER_DIR" || exit 1

# ===== FEX-Emu RootFS Location =====
export FEX_ROOTFS="<fexemu rootFS location here>"

# ===== FEX-Emu Performance Tuning (OCI Ampere A1) =====
export FEX_DYNAREC=1
export FEX_DYNAREC_SIZE=256
export FEX_DYNAREC_BIGBLOCK=2
export FEX_DYNAREC_CALLRET=1
export FEX_DYNAREC_FORWARD=512
export FEX_SMC_CHECKS=0
export FEX_TSO_ENABLED=0
export FEX_NOBANNER=1
export FEX_WAITONSPIN=1
export FEX_SPIN_COUNT=0
export FEX_CPU0_ID=0
export FEX_CPUCOUNT=4

# ===== glibc Memory Tuning =====
export MALLOC_ARENA_MAX=2
export MALLOC_TRIM_THRESHOLD_=131072
export MALLOC_MMAP_THRESHOLD_=131072

# ===== Launch Server =====
echo "[INFO] Starting Bedrock Server via FEX-Emu..."
exec FEX ./bedrock_server
