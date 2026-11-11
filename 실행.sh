#!/bin/bash
# 결제 없는 깨끗한 윈도 시험 한 번에: (1) 공개 저장소 geoningi/ncentric-ci-run 이 없으면 만들고 묶음 열쇠를 비밀값으로 넣는다
# (2) 오늘 사슬이 만든 설치 EXE 두 개 + 업그레이드용 옛 판을 암호화 묶음으로 올린다 (3) e2e·설치·Defender 시험을 띄운다.
# 공개되는 것: 작업 정의·README·이 스크립트·암호화된 묶음(열쇠 없이는 못 푼다). 각 단계 출력은 암호화 결과로만 나온다.
set -euo pipefail
R=geoningi/ncentric-ci-run; H=D:/centric_work/ci_public; T="E:/개발/통합도구"
cd "$H"
if ! gh repo view $R >/dev/null 2>&1; then
  [ -d .git ] || git init -q -b main
  git add .github README.md pack.sh unseal.sh 실행.sh
  git -c user.name=geoningi -c user.email=saramg963@gmail.com commit -q -m "시험 실행 작업 정의(e2e·install-test) — 입출력은 암호화 묶음

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" || true
  gh repo create $R --public --source . --push
fi
gh secret set BUNDLE_KEY -R $R < D:/centric_work/ci_public_key.txt
nc="$T/N-CENTRIC AI_설치.exe"; in="$T/[권건영] 실무자용 CENTRIC AI_설치.exe"
for f in "$nc" "$in"; do [ -f "$f" ] || { echo "설치 EXE 없음: $f"; exit 1; }; echo "$(date -r "$f" '+%m-%d %H:%M')  $f"; done
old=E:/centric_tmp/nc_setup_1106.exe
[ -f $old ] || gh release download base1106 -R geoningi/ncentric-install-test -p nc_setup_1106.exe -O $old 2>/dev/null || gh release download final1111 -R geoningi/ncentric-install-test -p nc_setup_1106.exe -O $old
tag=run$(date +%m%d%H%M)
bash pack.sh $tag "$nc" "$in" $old
gh workflow run e2e.yml -R $R -f tag=$tag
gh workflow run install-test.yml -R $R -f tag=$tag
echo "띄움: $tag — https://github.com/$R/actions"
