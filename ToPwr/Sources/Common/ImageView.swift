import SwiftUI
import Nuke
import NukeUI

// MARK: - ImageView
public struct ImageView<Placeholder: View>: View {
    let url: URL?
    let contentMode: ImageResizingMode
    let placeholder: Placeholder?
    
    public init(
        url: URL?,
        contentMode: ImageResizingMode = .aspectFit,
        placeholder: (() -> Placeholder)? = nil
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder?()
    }
    
    public var body: some View {
        if let url = url {
            LazyImage(
                source: url,
                content: { (state: LazyImageState) in
                    if let image = state.image {
                        image
                            .resizingMode(contentMode)
                    }
                }
            )
            .onDisappear(nil)
        } else {
            if let placeholder = placeholder {
                placeholder
            } else {
                Image("placeholder", bundle: Bundle.module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped()
                    .background(K.Colors.firstColorDark)
            }
        }
    }
}

public extension ImageView where Placeholder == EmptyView {
    init(
        url: URL?,
        contentMode: ImageResizingMode = .aspectFit
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = nil
    }
}
