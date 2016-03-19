//
//  TaskCell.swift
//  Pom
//
//  Created by Corinne Krych on 27/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//
import UIKit

public class TaskCell: UITableViewCell {
  static let ReuseId = "TaskCell"
  
  @IBOutlet weak var nameLabel: UILabel!
  public var activity: TaskActivity!
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .None
  }
}

// MARK: Populate Cell
extension TaskCell {
    func updateWithTask(activity:TaskActivity) {
        self.activity = activity
        nameLabel.text = activity.name
        self.backgroundColor = activity.type.color
    }
}