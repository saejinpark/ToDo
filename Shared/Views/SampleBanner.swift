import SwiftUI
import SwiftData

/// 예시 데이터가 들어 있을 때만 보이는 안내 줄.
struct SampleBanner: View {
    @Environment(\.modelContext) private var context
    @AppStorage(SampleData.bannerKey) private var shows = false

    var body: some View {
        if shows {
            HStack(spacing: 12) {
                Text("예시 할 일이 보이고 있어요.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Button("비우고 시작") {
                    withAnimation { SampleData.clearAll(in: context) }
                }
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderless)
                Button("유지") { shows = false }
                    .font(.subheadline)
                    .buttonStyle(.borderless)
            }
        }
    }
}
