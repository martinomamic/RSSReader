//
//  ViewState.swift
//  RSSReaderKit
//
//  Created by Martino Mamic on 05.05.25.
//

import Foundation

public enum ViewState<T>: Equatable where T: Equatable {
    case loading
    case content(T)
    case error(AppError)
    case empty
}
