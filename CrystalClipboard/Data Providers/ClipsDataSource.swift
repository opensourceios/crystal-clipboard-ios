//
//  ClipsDataSource.swift
//  CrystalClipboard
//
//  Created by Justin Mazzocchi on 9/5/17.
//  Copyright © 2017 Justin Mazzocchi. All rights reserved.
//

import CellHelpers

// This isn't the most elegant way of doing this,
// but I can't currently think of a better way given
// how the fetched results controller delegate is set up

class ClipsDataSource: DataSource {
    private let noClipsView = NoClipsView.fromNib()!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = super.tableView(tableView, numberOfRowsInSection: section)
        tableView.backgroundView = rows == 0 ? noClipsView : nil
        return rows
    }
}
