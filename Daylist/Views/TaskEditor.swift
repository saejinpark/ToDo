import SwiftUI
import SwiftData

/// 새 할 일 추가와 기존 할 일 편집을 함께 맡는 시트.
struct TaskEditor: View {
    enum When: String, CaseIterable, Identifiable {
        case inbox = "받은함", today = "오늘", tomorrow = "내일", pick = "날짜"
        var id: String { rawValue }
    }

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let item: TodoItem?

    @State private var title: String
    @State private var notes: String
    @State private var when: When
    @State private var pickedDate: Date
    @State private var slot: DaySlot?
    @State private var confirmingDelete = false
    @FocusState private var titleFocused: Bool

    init(item: TodoItem?, presetDate: Date? = nil, presetSlot: DaySlot? = nil) {
        self.item = item
        let date = item?.date ?? presetDate
        _title = State(initialValue: item?.title ?? "")
        _notes = State(initialValue: item?.notes ?? "")
        _pickedDate = State(initialValue: date ?? .startOfToday)
        _slot = State(initialValue: item?.slot ?? presetSlot)
        _when = State(initialValue: Self.when(for: date))
    }

    private static func when(for date: Date?) -> When {
        guard let date else { return .inbox }
        switch date.daysFromToday {
        case 0: return .today
        case 1: return .tomorrow
        default: return .pick
        }
    }

    private var isNew: Bool { item == nil }
    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("제목", text: $title)
                        .focused($titleFocused)
                        .onSubmit { if canSave { save() } }
                    TextField("메모", text: $notes, axis: .vertical)
                        .lineLimit(2...6)
                }

                Section("언제") {
                    Picker("언제", selection: $when) {
                        ForEach(When.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    if when == .pick {
                        DatePicker("날짜", selection: $pickedDate, displayedComponents: .date)
                    }
                }

                if when != .inbox {
                    Section("시간대") {
                        Picker("시간대", selection: $slot) {
                            ForEach(DaySlot.allCases) { Text($0.title).tag(Optional($0)) }
                            Text("미정").tag(DaySlot?.none)
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }
                }

                if let item {
                    Section {
                        Button("할 일 삭제", role: .destructive) { confirmingDelete = true }
                            .frame(maxWidth: .infinity)
                    } footer: {
                        Text(item.isDone
                             ? "완료: \((item.doneAt ?? .now).longDayLabel)"
                             : "추가: \(item.createdAt.longDayLabel)")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isNew ? "새로운 할 일" : "세부사항")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isNew ? "추가" : "완료", action: save)
                        .disabled(!canSave)
                        .keyboardShortcut(.defaultAction)
                }
            }
            .confirmationDialog("이 할 일을 삭제할까요?", isPresented: $confirmingDelete, titleVisibility: .visible) {
                Button("할 일 삭제", role: .destructive) {
                    if let item { context.delete(item) }
                    dismiss()
                }
            }
        }
        .onAppear { if isNew { titleFocused = true } }
        #if os(macOS)
        .frame(minWidth: 440, idealWidth: 480, minHeight: 420)
        #endif
    }

    private var resolvedDate: Date? {
        switch when {
        case .inbox: nil
        case .today: .startOfToday
        case .tomorrow: .startOfTomorrow
        case .pick: pickedDate.startOfDay
        }
    }

    private func save() {
        let cleanTitle = title.trimmingCharacters(in: .whitespaces)
        guard !cleanTitle.isEmpty else { return }
        let date = resolvedDate
        let finalSlot = date == nil ? nil : slot
        if let item {
            item.title = cleanTitle
            item.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            item.date = date
            item.slot = finalSlot
        } else {
            context.insert(TodoItem(
                title: cleanTitle,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                date: date,
                slot: finalSlot
            ))
        }
        dismiss()
    }
}
