# 양팔 저울 · Reserve Balance

Godot 4.7.2로 제작한 독립 웹 퍼즐 게임. 저울 양쪽의 질량을 같게 하고, **지정된 돌 하나를 예비 보관함에 남겨 다음 방으로 이어갑니다.** 정적 제작 퍼즐 18개를 5개 장에 나누었습니다. 숫자는 돌의 질량, 접시의 `칸`은 요구 돌 개수입니다.

## 플레이

- `docs/index.html`을 정적 HTTP 서버로 열면 됩니다. `file://` 직접 실행은 브라우저의 WASM 로딩 정책 때문에 지원하지 않습니다. 모바일은 가로 화면을 권장합니다.
- 첫 화면에서 처음부터, 이어서 또는 열린 방을 선택합니다. 튜토리얼을 읽은 뒤 게임을 시작할 수 있습니다.
- 마우스/터치: 돌을 선택하고 왼쪽 접시·오른쪽 접시·예비 보관함을 누르거나 돌을 직접 드래그합니다. 선반으로 되돌릴 수도 있습니다.
- 키보드: `1`–`7` 또는 `Tab` 돌 선택; `←`/`L` 왼쪽, `→`/`D` 오른쪽, `S` 예비, `↑`/`Backspace` 선반; `Z` 실행 취소, `R` 방 다시 시작, `Enter` 판정, `Esc` 표지.
- 무게 차이·바늘 기울기는 실시간으로 갱신됩니다. 모든 돌을 놓은 뒤 문을 열면 승패를 판정합니다. 완료 기록은 브라우저의 Godot `user://` 저장소에 보관됩니다. 브라우저 저장소를 지우면 진행 기록도 초기화됩니다.

## 빌드·검증

```sh
godot --headless --editor --path . --import --quit
godot --headless --path . --script res://tests/model_test.gd
godot --headless --path . --script res://tests/ui_test.gd
python3 tests/glyph_audit.py
godot --headless --path . --export-release Web docs/index.html
python3 -m http.server 8765 --directory docs
```

`tests/model_test.gd`는 18개 방의 해법을 완전탐색하고, 승계 돌·5개 장·승리/실패/되돌리기/재시작/18방 연속 진행을 검사합니다. `tests/ui_test.gd`는 제목, 설명, 터치 선택/배치·드래그, 저장 기록 읽기, 다음 방 진입을 검증합니다. `tests/author_levels.py`는 정적 퍼즐 데이터 `levels.json`을 생성하는 고정 시드 도구로 런타임에 쓰지 않습니다. `docs/.gdignore`는 내보낸 파일이 프로젝트 입력으로 재수집되지 않게 합니다. Web export는 스레드 미사용으로 별도 COOP/COEP 헤더가 필요 없습니다.

## 미술·음향·서체

저울, 돌, 종이 프레임, 바늘, 파티클, 아이콘과 시작 그림은 이 프로젝트를 위해 직접 그린 Godot 벡터 도형/SVG/PNG입니다. `tests/make_splash.py`로 시작 그림을 재생성할 수 있습니다. 클릭·승패 효과음은 코드에서 생성한 합성파이며 외부 샘플을 사용하지 않습니다. `assets/GowunDodum-Regular.ttf`는 Google Fonts의 Gowun Dodum 서체를 번들했으며 `assets/OFL.txt`의 SIL Open Font License 1.1을 따릅니다. 원본 출처: `https://github.com/google/fonts/tree/main/ofl/gowundodum`. 라이선스 전문은 웹 배포 디렉터리 `docs/OFL.txt`에도 포함합니다. `tests/glyph_audit.py`는 게임 코드·방 데이터의 표시 문자들을 글꼴 cmap과 대조합니다.

## 라이선스

이 프로젝트의 독자적인 소스 코드·그림·문서는 `LICENSE`의 MIT 라이선스에 따릅니다. 기여자의 실명은 확인되지 않아 저작권 표기는 프로젝트 원저작자 집합으로 기재했습니다. 번들된 Gowun Dodum 글꼴은 MIT 대상이 아니며 `assets/OFL.txt` 및 웹 배포용 `docs/OFL.txt`의 SIL OFL 1.1에 따릅니다.

## 범위

독립된 P1 게임 폴더만 사용합니다. 외부 서버, 계정, 분석, 광고, GitHub 업로드는 없습니다. 제작 퍼즐은 각 방에 적어도 하나의 정답이 있으며 일부 방은 대칭·서로 다른 유효 배치가 존재합니다. 자동 검증은 실제 휴대전화의 촉각·성능을 보장하지 않습니다.
