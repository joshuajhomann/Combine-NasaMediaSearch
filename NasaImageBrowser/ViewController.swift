//
//  ViewController.swift
//  NasaImageBrowser
//
//  Created by Joshua Homann on 10/26/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit
import Combine

enum LoadingState<Output> {
  case loading
  case loaded(Output)
  case failed(Error)
  case empty
}

class ViewController: UIViewController {
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var segmentedControl: UISegmentedControl!
  @IBOutlet var tableView: UITableView!
  
  private var media: [Item] = []
  private var searchTermSubject = PassthroughSubject<String, Never>()
  private var mediaTypeSubject = PassthroughSubject<MediaType, Never>()
  private var refreshSubject = PassthroughSubject<Void, Never>()
  private var subscriptions = Set<AnyCancellable>()

  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    tableView.dataSource = self
    let background = UIView()
    tableView.backgroundView = background
    tableView.refreshControl = UIRefreshControl()
    tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

    let searchResults = Publishers
      .CombineLatest3(
        searchTermSubject,
        mediaTypeSubject,
        refreshSubject
      )
      .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
      .map { combined -> AnyPublisher<LoadingState<[Item]>,Never> in
        let (term, mediaType, _) = combined
        guard !(term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) else {
          return Just(.empty).eraseToAnyPublisher()
        }
        return NasaMediaService
          .search(query: term, mediaType: mediaType)
          .map { $0.isEmpty ? LoadingState.empty : .loaded($0)}
          .catch { Just(.failed($0)).eraseToAnyPublisher() }
          .prepend(.loading)
          .eraseToAnyPublisher()
    }
    .switchToLatest()
    .receive(on: RunLoop.main)
    .share()


    searchResults
      .map{ loadingState -> [Item] in
        switch loadingState {
        case .loaded(let items):
          return items
        case .empty, .failed, .loading:
          return []
        }
      }
      .sink(receiveValue: { [tableView, weak self] media in
        self?.media = media
        tableView?.reloadData()
        tableView?.refreshControl?.endRefreshing()
      })
      .store(in: &subscriptions)

    _ = LoadingView(
      parent: background,
      loadingState: searchResults.eraseToAnyPublisher()
    )
    
    mediaTypeSubject.send(MediaType.allCases[0])
    refreshSubject.send(())
  }

  @objc private func refresh() {
    refreshSubject.send(())
  }

  @IBAction private func tapSegmentedControl(_ sender: UISegmentedControl) {
    mediaTypeSubject.send(MediaType.allCases[sender.selectedSegmentIndex])
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return media.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NasaMediaTableViewCell.self))
    (cell as? NasaMediaTableViewCell)?.configure(with: media[indexPath.row])
    return cell ?? UITableViewCell()
  }
}

extension ViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchTermSubject.send(searchText)
  }
}

