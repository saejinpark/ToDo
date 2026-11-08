import SwiftUI
import SwiftData

/// 세로로 넘기는 세 페이지: 오늘 · 받은함 · 기록.
struct WatchRootView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            NavigationStack { WatchTodayView() }
            NavigationStack { WatchInboxView() }
            NavigationStack { WatchHistoryView() }
        }
        .tabViewStyle(.verticalPage)
        .onAppear { SampleData.seedIfNeeded(in: context) }
    }
}

/// 손목에서는 행을 누르면 큰 버튼 목록이 뜬다.
struct WatchRow: View {
    @Environment(\.modelContext) private var context
    @Bindable var item: TodoItem
    var showsDate = false
    @State private var showingActions = false

    var body: some View {
        Button { showingActions = true } label: {
            HStack(spacing: 8) {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isDone ? item.slot.color : Color.secondary)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.title)
                        .strikethrough(item.isDone, color: .secondary)
                        .foregroundStyle(item.isDone ? .secondary : .primary)
                        .lineLimit(2)
                    if showsDate, let date = item.date {
                        Text(date.dayLabel)
                            .font(.caption2)
                            .foregroundStyle(item.isOverdue ? .red : .secondary)
                    }
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) { context.delete(item) } label: { Label("삭제", systemImage: "trash") }
        }
        .sheet(isPresented: $showingActions) { WatchActions(item: item) }
    }
}

struct WatchActions: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: TodoItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .padding(.bottom, 4)
                if !item.isDone {
                    Button { item.setDone(true); dismiss() } label: { Label("완료", systemImage: "checkmark") }
                        .tint(.green)
                    if !item.isToday {
                        Button { item.move(to: .startOfToday); dismiss() } label: { Label("오늘로", systemImage: "sun.max") }
                    }
                    if item.date?.startOfDay != Date.startOfTomorrow {
                        Button { item.move(to: .startOfTomorrow); dismiss() } label: { Label("내일로", systemImage: "arrow.right") }
                    }
                    if item.date != nil {
                        Button { item.move(to: nil); dismiss() } label: { Label("받은함으로", systemImage: "tray") }
                    }
                } else {
                    Button { item.setDone(false); dismiss() } label: { Label("완료 취소", systemImage: "arrow.uturn.backward") }
                }
                Button(role: .destructive) { context.delete(item); dismiss() } label: { Label("삭제", systemImage: "trash") }
            }
        }
        .navigationTitle(item.date?.dayLabel ?? "받은함")
    }
}

struct WatchTodayView: View {
    @Query(sort: \TodoItem.createdAt) private var items: [TodoItem]

    private var overdue: [TodoItem] { items.filter(\.isOverdue) }
    private var todays: [TodoItem] { items.filter { $0.date?.startOfDay == Date.startOfToday } }
    private var doneCount: Int { todays.filter(\.isDone).count }

    var body: some View {
        List {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Date.now.fullDayLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(todays.isEmpty ? "할 일 없음" : "\(todays.count - doneCount)개 남음")
                        .font(.footnote)
                }
                Spacer()
                ProgressRing(done: doneCount, total: todays.count, size: 40, lineWidth: 6)
            }
            .listItemTint(.clear)

            if !overdue.isEmpty {
                Section {
                    ForEach(overdue) { WatchRow(item: $0, showsDate: true) }
                } header: {
                    Text("지난 항목").foregroundStyle(.red)
                }
            }

            ForEach(DaySlot.allCases) { slot in
                let open = todays.filter { $0.slot == slot && !$0.isDone }
                if !open.isEmpty {
                    Section {
                        ForEach(open) { WatchRow(item: $0) }
                    } header: {
                        Label(slot.title, systemImage: "circle.fill")
                            .foregroundStyle(slot.color)
                            .labelStyle(.titleAndIcon)
                            .imageScale(.small)
                    }
                }
            }

            let untimed = todays.filter { $0.slot == nil && !$0.isDone }
            if !untimed.isEmpty {
                Section("시간 미정") {
                    ForEach(untimed) { WatchRow(item: $0) }
                }
            }
        }
        .navigationTitle("오늘")
    }
}

struct WatchInboxView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var items: [TodoItem]
    @State private var quick = ""

    private var inbox: [TodoItem] { items.filter(\.isInbox) }

    var body: some View {
        List {
            TextField("떠오른 일 적기", text: $quick)
                .onSubmit {
                    let text = quick.trimmingCharacters(in: .whitespaces)
                    guard !text.isEmpty else { return }
                    context.insert(TodoItem(title: text))
                    quick = ""
                }
            if inbox.isEmpty {
                Text("받은함이 비었어요")
                    .foregroundStyle(.secondary)
                    .listItemTint(.clear)
            }
            ForEach(inbox) { WatchRow(item: $0) }
        }
        .navigationTitle("받은함")
    }
}

struct WatchHistoryView: View {
    @Query(filter: #Predicate<TodoItem> { $0.isDone }, sort: \TodoItem.doneAt, order: .reverse)
    private var done: [TodoItem]

    private var days: [Date] {
        var seen = Set<Date>()
        return done.compactMap { $0.doneAt?.startOfDay }.filter { seen.insert($0).inserted }
    }

    var body: some View {
        List {
            if done.isEmpty {
                Text("아직 기록이 없어요")
                    .foregroundStyle(.secondary)
                    .listItemTint(.clear)
            }
            ForEach(days, id: \.self) { day in
                Section(day.longDayLabel) {
                    ForEach(done.filter { $0.doneAt?.startOfDay == day }) { WatchRow(item: $0) }
                }
            }
        }
        .navigationTitle("기록")
    }
}
