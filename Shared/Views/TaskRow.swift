import SwiftUI
import SwiftData

/// 행이 어느 목록에 있는지. 스와이프 동작과 메타 정보가 달라진다.
enum RowContext {
    case today, overdue, inbox, upcoming, history

    /// 왼쪽 스와이프(앞쪽 가장자리)로 옮길 곳.
    var moveTitle: String? {
        switch self {
        case .today: "내일로"
        case .overdue, .inbox, .upcoming: "오늘로"
        case .history: nil
        }
    }

    var moveImage: String {
        self == .today ? "arrow.right" : "sun.max"
    }
}

struct TaskRow: View {
    @Environment(\.modelContext) private var context
    @Bindable var item: TodoItem
    var rowContext: RowContext
    var onEdit: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                withAnimation(.snappy) { item.setDone(!item.isDone) }
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isDone ? item.slot.color : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isDone ? "완료 취소" : "완료")

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title.isEmpty ? "제목 없음" : item.title)
                    .strikethrough(item.isDone, color: .secondary)
                    .foregroundStyle(item.isDone ? .secondary : .primary)
                if !item.notes.isEmpty && rowContext != .history {
                    Text(item.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                meta
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onEdit)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if let title = rowContext.moveTitle {
                Button {
                    withAnimation { moveForward() }
                } label: {
                    Label(title, systemImage: rowContext.moveImage)
                }
                .tint(.blue)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation { context.delete(item) }
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
        .contextMenu { menu }
    }

    @ViewBuilder
    private var meta: some View {
        switch rowContext {
        case .overdue:
            if let date = item.date {
                Text("\(-date.daysFromToday)일 지남 · \(date.dayLabel)")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        case .history:
            HStack(spacing: 6) {
                if let slot = item.slot {
                    Text(slot.title)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .background(slot.color.opacity(0.16), in: Capsule())
                        .foregroundStyle(slot.color)
                }
                if let doneAt = item.doneAt {
                    Text("\(doneAt.timeLabel) 완료")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        case .upcoming, .inbox:
            if let slot = item.slot, rowContext == .upcoming {
                Text(slot.title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        case .today:
            EmptyView()
        }
    }

    @ViewBuilder
    private var menu: some View {
        if !item.isDone {
            if !item.isToday {
                Button { withAnimation { item.move(to: .startOfToday) } } label: { Label("오늘로", systemImage: "sun.max") }
            }
            if item.date?.startOfDay != Date.startOfTomorrow {
                Button { withAnimation { item.move(to: .startOfTomorrow) } } label: { Label("내일로", systemImage: "arrow.right") }
            }
            if item.date != nil {
                Button { withAnimation { item.move(to: nil) } } label: { Label("받은함으로", systemImage: "tray") }
            }
            Button { withAnimation { item.setDone(true) } } label: { Label("완료", systemImage: "checkmark") }
        } else {
            Button { withAnimation { item.setDone(false) } } label: { Label("완료 취소", systemImage: "arrow.uturn.backward") }
        }
        Button(action: onEdit) { Label("세부사항", systemImage: "pencil") }
        Divider()
        Button(role: .destructive) { withAnimation { context.delete(item) } } label: { Label("삭제", systemImage: "trash") }
    }

    private func moveForward() {
        switch rowContext {
        case .today: item.move(to: .startOfTomorrow)
        case .overdue, .inbox, .upcoming: item.move(to: .startOfToday)
        case .history: break
        }
    }
}
