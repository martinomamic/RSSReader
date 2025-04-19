import SwiftUI
import Kingfisher
import Common

public struct FeedImageView: View {
    let url: URL?
    let size: CGFloat
    
    public init(url: URL?, size: CGFloat = Constants.UI.feedIconSize) {
        self.url = url
        self.size = size
    }
    
    public var body: some View {
        KFImage(url)
            .placeholder {
                if url != nil {
                    Image(systemName: Constants.Images.placeholderImage)
                } else {
                    Image(systemName: Constants.Images.placeholderFeedIcon)
                        .foregroundStyle(.blue)
                }
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .cornerRadius(Constants.UI.cornerRadius)
    }
}

#Preview {
    VStack(spacing: 20) {
        FeedImageView(url: URL(string: "https://example.com/image.jpg"))
        FeedImageView(url: nil)
    }
    .padding()
}
