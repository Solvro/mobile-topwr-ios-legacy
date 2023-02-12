import SwiftUI

// MARK: - ImageView
public struct ImageView<Placeholder: View>: View {
    let url: URL?
    let contentMode: ContentMode
    let placeholder: Placeholder?
    
    public init(
        url: URL?,
        contentMode: ContentMode,
        placeholder: (() -> Placeholder)? = nil
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder?()
    }
    
    public var body: some View {
        if let url = url {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                }   else if phase.error != nil {
                    if let placeholder {
                        placeholder
                    }
                }   else {
                    ProgressView()
                }
            }
        } else {
            if let placeholder = placeholder {
                placeholder
            } else {
                LinearGradient(
                    colors: [K.Colors.darkGray, K.Colors.lightGray],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            }
        }
    }
}

public extension ImageView where Placeholder == EmptyView{
    init(
        url: URL?,
        contentMode: ContentMode
    ) {
        self.url = url
        self.contentMode = contentMode
		self.placeholder = nil
    }
}

