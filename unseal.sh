#!/bin/bash
# 공개 시험 결과(result.enc) 풀기: bash unseal.sh <result.enc> <풀 폴더>
set -euo pipefail; mkdir -p "$2"
BUNDLE_KEY=$(cat D:/centric_work/ci_public_key.txt) openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -pass env:BUNDLE_KEY -in "$1" | tar -x -C "$2"
