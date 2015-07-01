//
//  AdjustmentDelegate.swift
//  Negspect
//
//  Created by Erik Alfredsson on 30/06/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import UIKit

protocol AdjustmentDelegate {

    func adjustmentViewController(adjustmentViewController: AdjustmentViewController, didSelectFilter filter: Filter)

    func adjustmentViewController(adjustmentViewController: AdjustmentViewController, didUpdateRedValue value: CGFloat)
    func adjustmentViewController(adjustmentViewController: AdjustmentViewController, didUpdateGreenValue value: CGFloat)
    func adjustmentViewController(adjustmentViewController: AdjustmentViewController, didUpdateBlueValue value: CGFloat)

}
