import SwiftUI
import SwiftData

struct InboxView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var items: [TodoItem]

    @State private var quick = ""
    @State private var editing: TodoItem?
    @FocusState private var quickFocused: Bool

    private var inbox: [TodoItem] { items.filter(\.isInbox) }
    private var upcoming: [TodoItem] {
        items.filter(\.isUpcoming).sorted {
            ($0.date ?? .distantFuture, $0.createdAt) < ($1.date ?? .distantFuture, $1.createdAt)
        }
    }
    private var upcomingDays: [Date] {
        var seen = Set<Date>()
        return upcoming.compactMap { $0.date?.startOfDay }.filter { seen.insert($0).inserted }
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.accentColor)
                    TextField("떠오른 일 적기", text: $quick)
                        .focused($quickFocused)
                        .onSubmit(addQuick)
                    if !quick.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button("추가", action: addQuick)
                            .font(.body.weight(.semibold))
                            .buttonStyle(.borderless)
                    }
                }
                SampleBanner()
            } header: {
                Text(inbox.isEmpty ? "떠오른 일을 먼저 적어두세요" : "\(inbox.count)개 · 오른쪽으로 밀면 오늘로 옮겨요")
                    .textCase(nil)
            }

            if inbox.isEmpty {
                Section {
                    ContentUnavailableView(
                        "받은함이 비었어요",
                        systemImage: "tray",
                        description: Text("날짜를 정하지 않은 일은 여기에 모여요. 위에 적으면 바로 담겨요.")
                    )
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(inbox) { item in
                        TaskRow(item: item, rowContext: .inbox) { editing = item }
                    }
                }
            }

            if !upcoming.isEmpty {
                ForEach(upcomingDays, id: \.self) { day in
                    Section {
                        ForEach(upcoming.filter { $0.date?.startOfDay == day }) { item in
                            TaskRow(item: item, rowContext: .upcoming) { editing = item }
                        }
                    } header: {
                        VStack(alignment: .leading, spacing: 6) {
                            if day == upcomingDays.first {
                                HStack(spacing: 8) {
                                    Text("예정")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text("\(upcoming.count)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                            }
                            Text(day.longDayLabel)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                        .textCase(nil)
                    }
                }
            }
        }
        .listSectionSpacingCompat()
        .navigationTitle("받은함")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { appState.isPresentingNewTask = true } label: {
                    Label("새로운 할 일", systemImage: "plus")
                }
            }
        }
        .sheet(item: $editing) { TaskEditor(item: $0) }
    }

    private func addQuick() {
        let text = quick.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        withAnimation { context.insert(TodoItem(title: text)) }
        quick = ""
        quickFocused = true
    }
}
