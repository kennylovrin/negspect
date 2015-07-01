//
//  Filter.swift
//  Negspect
//
//  Created by Erik Alfredsson on 01/07/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import Foundation

enum Filter: Int {
    case BW, Color
}

class FilterConfiguration {

    private struct Defaults {
        static let SelectedFilter = "selected.filter"
    }

    var selectedFilter: Filter? {
        get {
            return Filter(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(Defaults.SelectedFilter))
        }

        set {
            guard let selectedFilter = selectedFilter else {
                return
            }

            NSUserDefaults.standardUserDefaults().setInteger(selectedFilter.rawValue, forKey: Defaults.SelectedFilter)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}