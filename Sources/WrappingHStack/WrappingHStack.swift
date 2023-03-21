import SwiftUI

public struct WrappingHStack<Content: View>: View {
    public enum WrappingHStackLineHeight {
        case equal
        case variable
    }

    @State var containerWidth: CGFloat = .zero
    private let content: [Content]
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let horizontalAlignment: HorizontalAlignment
    private let verticalAlignment: VerticalAlignment
    private let lineHeight: WrappingHStackLineHeight
    private var frameAlignment: Alignment {
        switch horizontalAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        default:
            return .leading
        }
    }

    public init(
        horizontalSpacing: CGFloat? = nil,
        horizontatAlignment: HorizontalAlignment? = nil,
        verticalSpacing: CGFloat? = nil,
        verticalAlignment: VerticalAlignment? = nil,
        lineHeight: WrappingHStackLineHeight? = nil,
        content: [Content]
    ) {
        self.horizontalSpacing = horizontalSpacing ?? 5
        self.horizontalAlignment = horizontatAlignment ?? .leading
        self.verticalSpacing = verticalSpacing ?? 5
        self.verticalAlignment = verticalAlignment ?? .top
        self.lineHeight = lineHeight ?? .variable
        self.content = content
    }

    public var body: some View {
        GeometryReader { reader in
            Rectangle().foregroundColor(.clear)
                .onAppear {
                    containerWidth = reader.size.width
                }
        }
        .frame(height: 0)
        let rows = buildRows()
        let rowHeight = calculateRowHeightFor(rows: rows)
        VStack(alignment: horizontalAlignment, spacing: verticalSpacing) {
            ForEach(rows.indices, id: \.self) { index in
                rows[index]
            }
        }
        .frame(idealWidth: containerWidth, alignment: frameAlignment)
    }

    private func calculateRowHeightFor(rows: [AnyView]) -> CGFloat? {
        switch lineHeight {
        case .variable:
            return nil
        case .equal:
            return rows.map({ $0.size.height }).max()
        }
    }

    private func buildRows() -> [AnyView] {
        var rows = [AnyView]()
        var rowViews = [Content]()
        var rowWidth = CGFloat.zero
        for view in content {
            let viewWidth = view.size.width
            if rowWidth + viewWidth + horizontalSpacing > containerWidth {
                rows.append(buildRowFrom(views: rowViews))
                rowViews = []
                rowWidth = .zero
            }
            rowViews.append(view)
            rowWidth += viewWidth
        }
        if !rowViews.isEmpty {
            rows.append(buildRowFrom(views: rowViews))
        }
        return rows
    }

    private func buildRowFrom(views: [Content]) -> AnyView {
        AnyView(
            HStack(alignment: verticalAlignment, spacing: horizontalSpacing) {
                ForEach(views.indices, id: \.self) { index in
                    views[index]
                }
            }
        )
    }
}

public extension WrappingHStack {
    init(
        horizontalSpacing: CGFloat? = nil,
        horizontatAlignment: HorizontalAlignment? = nil,
        verticalSpacing: CGFloat? = nil,
        verticalAlignment: VerticalAlignment? = nil,
        lineHeight: WrappingHStackLineHeight? = nil,
        content: () -> [Content]
    ) {
        self.init(
            horizontalSpacing: horizontalSpacing,
            horizontatAlignment: horizontatAlignment,
            verticalSpacing: verticalSpacing,
            verticalAlignment: verticalAlignment,
            lineHeight: lineHeight,
            content: content()
        )
    }

    init<Data, ID: Hashable>(
        horizontalSpacing: CGFloat? = nil,
        horizontatAlignment: HorizontalAlignment? = nil,
        verticalSpacing: CGFloat? = nil,
        verticalAlignment: VerticalAlignment? = nil,
        lineHeight: WrappingHStackLineHeight? = nil,
        @ViewBuilder content: () -> ForEach<Data, ID, Content>
    ) {
        let views = content()
        self.init(
            horizontalSpacing: horizontalSpacing,
            horizontatAlignment: horizontatAlignment,
            verticalSpacing: verticalSpacing,
            verticalAlignment: verticalAlignment,
            lineHeight: lineHeight,
            content: views.data.map(views.content)
        )
    }
}
