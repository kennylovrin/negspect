//
//  Filter.swift
//  Negspect
//
//  Created by Erik Alfredsson on 01/07/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import UIKit

enum Filter: Int {
    case BW, Color
}

class FilterConfiguration {

    private struct Defaults {
        static let SelectedFilter = "selected.filter"
        static let RGBValues = "rgb.values"
    }

    var selectedFilter: Filter? {
        get {
            return Filter(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(Defaults.SelectedFilter))
        }

        set (newValue) {
            guard let newValue = newValue else {
                return
            }
            print("saving \(newValue) to defaults")
            NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: Defaults.SelectedFilter)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    var rgbArray: [CGFloat] {
        get {
            guard let rgbValues = NSUserDefaults.standardUserDefaults().objectForKey(Defaults.RGBValues) as? [CGFloat]  else {
                return [0.8, 1.7, 1.6]
            }

            return rgbValues
        }

        set (newValue) {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Defaults.RGBValues)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}