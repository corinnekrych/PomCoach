//
//  TaskCell.swift
//  Pom
//
//  Created by Corinne Krych on 27/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//
import UIKit

class TaskCell: UITableViewCell {
  static let ReuseId = "TaskCell"
  
  @IBOutlet weak var progressView: ProgressView!
  @IBOutlet weak var nameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .None
  }
}

// MARK: Populate Cell
extension TaskCell {
    func updateWithTask(activity:Activity) {
        nameLabel.text = activity.name
        var timePassed: Int = 0
        let totalTime: Int = Int(activity.duration)
        if let timer = activity.timer {
            timePassed = Int(timer.timeInterval - timer.fireDate.timeIntervalSinceNow)
        }
        progressView.update(activity.type.color, current: timePassed, total: totalTime)
    }
}