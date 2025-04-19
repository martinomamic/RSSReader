import SwiftUI
import Common

public struct FeedImageView: View {
    let url: URL?
    let size: CGFloat
    
    public init(url: URL?, size: CGFloat = Constants.UI.feedIconSize) {
        self.url = url
        self.size = size
    }
    
    public var body: some View {
        if let imageURL = url {
            AsyncImage(url: imageURL) { image in
                image.resizable().aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: Constants.Images.placeholderImage)
            }
            .frame(width: size, height: size)
            .cornerRadius(Constants.UI.cornerRadius)
        } else {
            Image(systemName: Constants.Images.placeholderFeedIcon)
                .font(.title2)
                .frame(width: size, height: size)
                .foregroundStyle(.blue)
        }
    }
}