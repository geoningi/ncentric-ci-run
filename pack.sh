#!/bin/bash
# 공개 시험 저장소용 묶음 만들기 — ci_repo 의 ci/ 와 설치 EXE 3개를 tar 로 묶어 AES-256(pbkdf2) 로 암호화해 릴리스에 올린다.
# 사용: bash pack.sh <태그> <nc_setup.exe> <in_setup.exe> <nc_setup_1106.exe>
# 열쇠는 D:/centric_work/ci_public_key.txt (저장소 밖) — 같은 값이 저장소 비밀값 BUNDLE_KEY 에 있다. 결과 풀기: bash unseal.sh <result.enc> <폴더>
set -euo pipefail
tag=$1; W=$(mktemp -d -p E:/centric_tmp pack.XXXX); trap 'rm -rf "$W"' EXIT
export BUNDLE_KEY=$(cat D:/centric_work/ci_public_key.txt)
git -C D:/centric_work/ci_repo archive HEAD ci | tar -x -C "$W"
mkdir "$W/dl"; cp "$2" "$W/dl/nc_setup.exe"; cp "$3" "$W/dl/in_setup.exe"; cp "$4" "$W/dl/nc_setup_1106.exe"
# 11-11 22시: install_test H·I·J 는 dl/probe.exe(ci/make_probe.ps1) 가 있어야 돈다 — 빠져 I·J 실패했다. 없으면 묶지 않는다.
P=D:/centric_work/ci_repo/probe.exe; [ -f $P ] || { echo "probe.exe 없음 — powershell -File D:/centric_work/ci_repo/ci/make_probe.ps1 먼저"; exit 1; }; cp $P "$W/dl/probe.exe"
tar -c -C "$W" ci dl | openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt -pass env:BUNDLE_KEY -out "$W/bundle.tar.enc"
ls -l "$W/bundle.tar.enc"
gh release create "$tag" -R geoningi/ncentric-ci-run --title "$tag" --notes "encrypted bundle" "$W/bundle.tar.enc"
