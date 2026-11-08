import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @Query(sort: \TodoItem.createdAt) private var items: [TodoItem]

    @State private var editing: TodoItem?
    @State private var drafts: [String: String] = [:]
    @FocusState private var focusedDraft: String?

    private var overdue: [TodoItem] {
        items.filter(\.isOverdue).sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
    }
    private var todays: [TodoItem] { items.filter { $0.date?.startOfDay == Date.startOfToday } }
    private var doneCount: Int { todays.filter(\.isDone).count }
    private var openCount: Int { todays.count - doneCount }
    private var upcomingCount: Int { items.filter(\.isUpcoming).count }

    var body: some View {
        List {
            Section {
                header
                SampleBanner()
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            if !overdue.isEmpty {
                Section {
                    ForEach(overdue) { item in
                        TaskRow(item: item, rowContext: .overdue) { editing = item }
                    }
                } header: {
                    sectionHeader(title: "지난 항목", color: .red, count: overdue.count) {
                        Button("모두 오늘로") {
                            withAnimation { overdue.forEach { $0.move(to: .startOfToday) } }
                        }
                        .font(.subheadline)
                        .buttonStyle(.borderless)
                    }
                }
            }

            ForEach(DaySlot.allCases) { slot in
                slotSection(slot)
            }

            let untimed = todays.filter { $0.slot == nil && !$0.isDone }
            if !untimed.isEmpty || drafts["untimed"] != nil {
                Section {
                    ForEach(untimed) { item in
                        TaskRow(item: item, rowContext: .today) { editing = item }
                    }
                    addRow(key: "untimed", slot: nil)
                } header: {
                    sectionHeader(title: "시간 미정", dot: .gray, count: untimed.count, hint: "틈나면")
                }
            }

            Section {
                EmptyView()
            } footer: {
                Text(footnote)
            }
        }
        .listSectionSpacingCompat()
        .navigationTitle("오늘")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { appState.isPresentingNewTask = true } label: {
                    Label("새로운 할 일", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .sheet(item: $editing) { TaskEditor(item: $0) }
    }

    // MARK: - Pieces

    private var header: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Date.now.fullDayLabel)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(subline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ProgressRing(done: doneCount, total: todays.count)
        }
        .padding(.vertical, 4)
    }

    private var subline: String {
        if todays.isEmpty { return "오늘 할 일이 없어요" }
        if openCount == 0 { return "오늘 할 일 \(todays.count)개를 모두 마쳤어요" }
        return "\(openCount)개 남음 · \(doneCount)개 완료"
    }

    private var footnote: String {
        var parts: [String] = []
        if upcomingCount > 0 { parts.append("예정된 할 일 \(upcomingCount)개는 날짜가 되면 여기에 나타나요.") }
        if doneCount > 0 { parts.append("오늘 완료한 \(doneCount)개는 기록에서 볼 수 있어요.") }
        return parts.isEmpty ? "시간 미정 할 일은 틈날 때 처리하면 돼요." : parts.joined(separator: " ")
    }

    private func slotSection(_ slot: DaySlot) -> some View {
        let open = todays.filter { $0.slot == slot && !$0.isDone }
        return Section {
            ForEach(open) { item in
                TaskRow(item: item, rowContext: .today) { editing = item }
            }
            addRow(key: slot.rawValue, slot: slot)
        } header: {
            sectionHeader(title: slot.title, dot: slot.color, count: open.count, hint: slot.hint)
        }
    }

    private func sectionHeader<Trailing: View>(
        title: String,
        color: Color = .primary,
        dot: Color? = nil,
        count: Int,
        hint: String? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) -> some View {
        HStack(spacing: 8) {
            if let dot {
                Circle().fill(dot).frame(width: 10, height: 10)
            }
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
            Text(count > 0 ? "\(count)" : (hint ?? ""))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Spacer()
            trailing()
        }
        .textCase(nil)
        .padding(.bottom, 2)
    }

    private func addRow(key: String, slot: DaySlot?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "plus.circle")
                .font(.title2)
                .foregroundStyle(Color.accentColor)
            TextField("추가", text: Binding(
                get: { drafts[key] ?? "" },
                set: { drafts[key] = $0 }
            ))
            .focused($focusedDraft, equals: key)
            .onSubmit {
                let text = (drafts[key] ?? "").trimmingCharacters(in: .whitespaces)
                guard !text.isEmpty else { drafts[key] = nil; return }
                withAnimation {
                    context.insert(TodoItem(title: text, date: .startOfToday, slot: slot))
                }
                drafts[key] = ""
                focusedDraft = key
            }
            #if os(iOS)
            .submitLabel(.done)
            #endif
        }
    }
}

extension View {
    /// iOS 17+ 의 섹션 간격 조절. macOS에는 없다.
    @ViewBuilder
    func listSectionSpacingCompat() -> some View {
        #if os(iOS)
        self.listSectionSpacing(.compact)
        #else
        self
        #endif
    }
}
