import Foundation
import SwiftData

enum SampleData {
    static let bannerKey = "showsSampleBanner"
    private static let seededKey = "didSeedSampleData"

    /// 첫 실행에 저장소가 비어 있으면 예시 할 일을 넣는다. 한 번만.
    static func seedIfNeeded(in context: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: seededKey) else { return }
        defaults.set(true, forKey: seededKey)

        let count = (try? context.fetchCount(FetchDescriptor<TodoItem>())) ?? 0
        guard count == 0 else { return }

        let today = Date.startOfToday
        let yesterday = today.adding(days: -1)
        var created = Date.now.addingTimeInterval(-1_000)
        func next() -> Date { created.addTimeInterval(1); return created }

        let items: [TodoItem] = [
            TodoItem(title: "관리비 자동이체 확인", date: yesterday, slot: .afternoon, createdAt: next()),
            TodoItem(title: "세탁소에서 코트 찾기", notes: "영수증 지갑에 있음", date: today, slot: .morning, createdAt: next()),
            TodoItem(title: "분기 리뷰 슬라이드 초안", notes: "핵심 지표 3개, 10장 이내", date: today, slot: .morning, createdAt: next()),
            TodoItem(title: "디자인 QA 피드백 회신", date: today, slot: .afternoon, createdAt: next()),
            TodoItem(title: "운동 30분", date: today, slot: .evening, createdAt: next()),
            TodoItem(title: "치과 정기검진 예약", date: today.adding(days: 1), slot: .morning, createdAt: next()),
            TodoItem(title: "팀 회식 장소 예약", date: today.adding(days: 3), slot: .afternoon, createdAt: next()),
            TodoItem(title: "여권 갱신 알아보기", createdAt: next()),
            TodoItem(title: "책장 정리", createdAt: next()),
            TodoItem(title: "친구 생일 선물 고르기", createdAt: next()),
            TodoItem(title: "주간 회의록 공유", date: today, slot: .morning, isDone: true,
                     doneAt: Date.now.addingTimeInterval(-3_600), createdAt: next()),
            TodoItem(title: "여권 사진 찍기", date: yesterday, slot: .afternoon, isDone: true,
                     doneAt: Date.now.addingTimeInterval(-86_400 - 7_200), createdAt: next()),
            TodoItem(title: "은행 서류 제출", date: yesterday, slot: .morning, isDone: true,
                     doneAt: Date.now.addingTimeInterval(-86_400 - 18_000), createdAt: next()),
            TodoItem(title: "화분 물 주기", date: today.adding(days: -2), slot: .evening, isDone: true,
                     doneAt: Date.now.addingTimeInterval(-2 * 86_400), createdAt: next()),
        ]
        items.forEach(context.insert)
        try? context.save()
        defaults.set(true, forKey: bannerKey)
    }

    static func clearAll(in context: ModelContext) {
        try? context.delete(model: TodoItem.self)
        UserDefaults.standard.set(false, forKey: bannerKey)
    }
}
