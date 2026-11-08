# Daylist

Apple Human Interface Guidelines를 따르는 하루 흐름 중심 할 일 앱. SwiftUI + SwiftData로 만든 네이티브 앱이며, iPhone · iPad · Mac · Apple Watch에서 각 플랫폼의 관용구로 동작해요.

## 구조

- **오늘** — 오전 · 오후 · 저녁 · 시간 미정 구간으로 나뉜 오늘 할 일과 진행률 링. 기한이 지난 항목은 맨 위에 모여요.
- **받은함** — 날짜 없이 빠르게 적어두는 곳. 오른쪽으로 밀면 오늘로 옮겨요. 미래 날짜 항목은 아래 "예정"에 모여요.
- **기록** — 완료한 일을 날짜별 타임라인으로. 오늘 · 최근 7일 · 연속 일수.

## 플랫폼

| 플랫폼 | 타깃 | 모습 |
| --- | --- | --- |
| iPhone | `Daylist` | 탭 바, 큰 제목, 바텀 시트, 스와이프 · 길게 누르기 |
| iPad | `Daylist` | 사이드바로 전환 가능한 탭 바(`sidebarAdaptable`), 폼 시트, 컨텍스트 메뉴 |
| Mac | `Daylist` | 사이드바 + 툴바, 우클릭 메뉴, ⌘N 새 할 일, ⌘1 · ⌘2 · ⌘3 화면 이동 |
| Apple Watch | `DaylistWatch` | 세로 페이지 3장(오늘 · 받은함 · 기록), 행을 누르면 큰 버튼 목록 |

## 조작

- 체크 원 탭 → 완료 (기록으로 이동)
- 앞쪽 스와이프 → 오늘 화면에서는 **내일로**, 받은함 · 지난 항목에서는 **오늘로**
- 뒤쪽 스와이프 → 삭제
- 길게 누르기 / 우클릭 → 컨텍스트 메뉴 (오늘로 · 내일로 · 받은함으로 · 완료 · 세부사항 · 삭제)
- 각 구간 아래 "추가" 행에서 바로 입력, Enter로 계속 추가

## 프로젝트

```
Daylist.xcodeproj
Daylist/          iOS · iPadOS · macOS 앱 (RootView, TodayView, InboxView, HistoryView, TaskEditor)
DaylistWatch/     watchOS 앱
Shared/           두 타깃이 함께 쓰는 모델 · 날짜 도우미 · 공용 뷰
```

- 배포 타깃: iOS 18 · macOS 15 · watchOS 11
- 저장: SwiftData 로컬 저장소. 기기 간 동기화는 아직 없어요 (CloudKit을 붙이면 돼요).
- 첫 실행에는 예시 할 일이 들어 있고, "비우고 시작"으로 지울 수 있어요.

## 빌드

```bash
xcodebuild -project Daylist.xcodeproj -scheme Daylist -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Xcode에서 `Daylist.xcodeproj`를 열고 `Daylist` 또는 `DaylistWatch` 스킴을 골라 실행하면 돼요.
