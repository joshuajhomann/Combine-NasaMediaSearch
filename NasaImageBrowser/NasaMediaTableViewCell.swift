//
//  NasaMediaTableViewCell.swift
//  NasaImageBrowser
//
//  Created by Joshua Homann on 10/28/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit
import Kingfisher
import Tags

class NasaMediaTableViewCell: UITableViewCell {
  
  @IBOutlet private var previewImageView: UIImageView!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var detailLabel: UILabel!
  @IBOutlet private var tagsView: TagsView!
  
  func configure(with model: Item) {
    if let url = (model.links?.first?.href).flatMap(URL.init(string:)) {
      previewImageView.kf.setImage(with: url)
    }
    titleLabel.text = model.data.first?.title
    detailLabel.text = model.data.first?.description508
    tagsView.append(contentsOf: model.data.first?.keywords ?? [])
  }
  
}
