//
//  LoadingView.swift
//  RxTvMaze
//
//  Created by Joshua Homann on 9/28/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit
import Combine

class LoadingView: UIView {

  private var loadingStateSubscription: AnyCancellable?

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init<Output>(parent: UIView, loadingState: AnyPublisher<LoadingState<Output>, Never>) {
    super.init(frame: .zero)

    translatesAutoresizingMaskIntoConstraints = false
    parent.addSubview(self)
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: parent.leadingAnchor),
      trailingAnchor.constraint(equalTo: parent.trailingAnchor),
      topAnchor.constraint(equalTo: parent.topAnchor),
      bottomAnchor.constraint(equalTo: parent.bottomAnchor)
    ])

    let loadingView = makeSubview(ofType: StandardLoadingView.self)
    let emptyView = makeSubview(ofType: StandardEmptyView.self)
    let errorView = makeSubview(ofType: StandardErrorView.self)

    loadingStateSubscription = loadingState
      .sink(receiveValue: { state in
        [loadingView, emptyView, errorView].forEach { $0.isHidden = true }
        switch state {
        case .loading:
          loadingView.isHidden = false
        case .empty:
          emptyView.isHidden = false
        case .failed:
          errorView.isHidden = false
        case .loaded:
          break
        }
      })
    }

  func makeSubview<View: UIView>(ofType type: View.Type)  -> UIView {
    let view = UINib(nibName: String(describing: type), bundle: nil).instantiate(withOwner: nil, options: nil).first as! UIView
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false
    addSubview(view)
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: leadingAnchor),
      view.trailingAnchor.constraint(equalTo: trailingAnchor),
      view.topAnchor.constraint(equalTo: topAnchor),
      view.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
    return view
  }
}

