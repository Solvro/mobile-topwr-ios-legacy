import SwiftUI

// MARK: - ImageView
public struct ImageView: View {
    let url: URL?
    let contentMode: ContentMode
    
    public init(
        url: URL?,
        contentMode: ContentMode = .fit
    ) {
        self.url = url
        self.contentMode = contentMode
    }
    
    public var body: some View {
        if let url = url {
            AsyncImage(
                url: url,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                },
                placeholder: {
                    ZStack {
                        K.Colors.lightGray
                        ProgressView()
                    }
                }
            )
        } else {
            ZStack {
                K.Colors.lightGray
                ProgressView()
            }
        }
    }
}

