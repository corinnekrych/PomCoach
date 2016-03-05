//
//  NewTaskCell.swift
//  Pom
//
//  Created by Corinne Krych on 27/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//
import UIKit

class ProgressView: UIView {
  @IBOutlet weak var progressBarView: UIView!
  @IBOutlet weak var progressBarLeftConstraint: NSLayoutConstraint!
    
  var total = 1
  var current = 1
  
  override func updateConstraints() {
    super.updateConstraints()
    if (total > 0) {
      let progress = CGFloat(current)/CGFloat(total)
      let width = CGRectGetWidth(bounds)      
      progressBarLeftConstraint.constant = progress * width
    }
  }
  
  func update(color: UIColor, current: Int, total: Int) {
    self.current = current
    self.total = total
    progressBarView.backgroundColor = color
    setNeedsUpdateConstraints()
  }
}
