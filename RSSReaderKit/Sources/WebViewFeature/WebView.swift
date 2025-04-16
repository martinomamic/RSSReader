//
//  WebView.swift
//  RSSReaderKit
//
//  Created by Martino Mamić on 16.04.25.
//

import SwiftUI
import WebKit

public struct WebView: UIViewRepresentable {
    public let url: URL
    public var onLoadingStateChanged: ((Bool) -> Void)?
    
    public init(url: URL, onLoadingStateChanged: ((Bool) -> Void)? = nil) {
        self.url = url
        self.onLoadingStateChanged = onLoadingStateChanged
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        public init(_ parent: WebView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onLoadingStateChanged?(false)
        }
        
        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.onLoadingStateChanged?(false)
        }
    }
}
