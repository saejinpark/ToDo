import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<TodoItem> { $0.isDone }, sort: \TodoItem.doneAt, order: .reverse)
    private var done: [TodoItem]

    @State private var editing: TodoItem?
    @State private var confirmingClear = false

    private var days: [Date] {
        var seen = Set<Date>()
        return done.compactMap { $0.doneAt?.startOfDay }.filter { seen.insert($0).inserted }
    }
    private var todayCount: Int { done.filter { $0.doneAt?.startOfDay == Date.startOfToday }.count }
    private var weekCount: Int {
        let cutoff = Date.now.addingTimeInterval(-7 * 86_400)
        return done.filter { ($0.doneAt ?? .distantPast) > cutoff }.count
    }
    /// 오늘부터 거꾸로 하루도 빠짐없이 완료한 날의 수. 오늘 아직 없으면 어제부터 센다.
    private var streak: Int {
        let set = Set(days)
        var day = Date.startOfToday
        if !set.contains(day) { day = day.adding(days: -1) }
        var count = 0
        while set.contains(day) { count += 1; day = day.adding(days: -1) }
        return count
    }

    var body: some View {
        List {
            if done.isEmpty {
                Section {
                    ContentUnavailableView(
                        "아직 기록이 없어요",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("오늘에서 할 일을 완료하면 날짜별로 여기에 남아요.")
                    )
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    HStack(spacing: 10) {
                        stat(todayCount, "오늘")
                        stat(weekCount, "최근 7일")
                        stat(streak, "연속 일수")
                    }
                } header: {
                    Text("지금까지 \(done.count)개를 마쳤어요").textCase(nil)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                ForEach(days, id: \.self) { day in
                    let items = done.filter { $0.doneAt?.startOfDay == day }
                    Section {
                        ForEach(items) { item in
                            TaskRow(item: item, rowContext: .history) { editing = item }
                        }
                    } header: {
                        HStack {
                            Text(day.longDayLabel)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(items.count)개")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .textCase(nil)
                    }
                }

                Section {
                    Button("기록 모두 지우기", role: .destructive) { confirmingClear = true }
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            }
        }
        .listSectionSpacingCompat()
        .navigationTitle("기록")
        .sheet(item: $editing) { TaskEditor(item: $0) }
        .confirmationDialog(
            "완료한 할 일 \(done.count)개의 기록을 지울까요?",
            isPresented: $confirmingClear,
            titleVisibility: .visible
        ) {
            Button("기록 지우기", role: .destructive) {
                withAnimation { done.forEach(context.delete) }
            }
        } message: {
            Text("되돌릴 수 없어요.")
        }
    }

    private func stat(_ value: Int, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.title.weight(.bold))
                .monospacedDigit()
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
