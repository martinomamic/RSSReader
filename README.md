# RSS Reader

A modular iOS application with a Swift package core for reading and displaying RSS feeds built with SwiftUI and Swift Concurrency.

## Features

### Core Features
- ✅ Add RSS feeds by specifying an RSS feed URL
- ✅ Remove RSS feeds
- ✅ View added RSS feeds with name, image, and description
- ✅ Select an RSS feed to open a screen with feed items
- ✅ View feed items with image, title, and description
- ✅ Open RSS item links in WebView or device browser

### Optional Features
- ⬜️ Turn on notifications for new feed items
- ⬜️ Add RSS feeds to Favorites

## Architecture

This project uses a clean architecture approach with the following components:

- **RSSClient**: Core module for fetching and parsing RSS feeds
- **SharedModels**: Common models used across modules
- **FeedListFeature**: UI components for displaying and managing feeds

The project implements:
- Dependency injection using swift-dependencies
- Swift Concurrency with async/await
- Protocol-oriented programming for testability
- SwiftUI with the Observation framework
- Modular architecture with a thin app layer on top of a Swift package core

## Project Structure

```
RSSReader/
├── RSSClient/
├── RSSReaderKit/
│   ├── Package
│   ├── Sources/
│   │   ├── FeedListFeature/
│   │   │   ├── AddFeed/
│   │   │   │   ├── AddFeedView
│   │   │   │   └── AddFeedViewModel
│   │   │   ├── FeedList/
│   │   │   │   ├── FeedListView
│   │   │   │   └── FeedListViewModel
│   │   │   ├── FeedView/
│   │   │   │   ├── FeedView
│   │   │   │   └── FeedViewModel
│   │   │   └── Helpers/
│   │   │       ├── Constants
│   │   │       ├── RSSErrorMapper
│   │   │       └── RSSViewError
│   │   ├── RSSClient/
│   │   │   ├── RSSClient
│   │   │   ├── RSSClientLive
│   │   │   ├── RSSElement
│   │   │   ├── RSSError
│   │   │   ├── RSSParser
│   │   │   ├── RSSParserDelegate
│   │   │   └── RSSParserDelegateProtocol
│   │   └── SharedModels/
│   │       ├── Feed
│   │       └── FeedItem
│   └── Tests/
│       ├── RSSClientTests/
│       │   └── RSSClientTests
│       └── SharedModelsTests/
├── RSSReader/
│   ├── Preview Content/
│   │   └── Preview Assets
│   ├── Assets
│   ├── RSSReader
│   └── RSSReaderApp
├── RSSReaderTests/
│   └── RSSReaderTests
└── RSSReaderUITests/
    └── RSSReaderUITests
```

## Getting Started

### Requirements
- iOS 17+
- Swift 6+
- Xcode 15+

### Installation

1. Clone the repository
2. Open the project in Xcode
3. Build and run

## Sample RSS Feeds

For testing these feeds can be used:
https://blog.feedspot.com/world_news_rss_feeds/

These feeds are extracted from the link above and can be added directly in the app without searching by tapping on them:
- BBC News: https://feeds.bbci.co.uk/news/world/rss.xml
- NBC News: https://feeds.nbcnews.com/nbcnews/public/news



## Testing

Run the tests using Xcode's test navigator or with the following command:

```bash
swift test
```

## License

This project is available under the MIT license.

