import SwiftUI

struct FlexibleWrap<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let items: Data
    var spacing: CGFloat = 8
    var runSpacing: CGFloat = 8
    let content: (Data.Element) -> Content

    init(items: Data, spacing: CGFloat = 8, runSpacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.spacing = spacing
        self.runSpacing = runSpacing
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
        .frame(minHeight: 0)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.items) { item in
                content(item)
                    .padding(.trailing, spacing)
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height + runSpacing
                        }
                        let res = width
                        if item.id == items.last?.id { width = 0 }
                        else { width -= d.width }
                        return res
                    }
                    .alignmentGuide(.top) { _ in
                        let res = height
                        if item.id == items.last?.id { height = 0 }
                        return res
                    }
            }
        }
    }
}
