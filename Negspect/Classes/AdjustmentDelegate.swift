//
//  AdjustmentDelegate.swift
//  Negspect
//
//  Created by Erik Alfredsson on 30/06/15.
//  Copyright © 2015 Kenny Lövrin. All rights reserved.
//

import UIKit

protocol AdjustmentDelegate {

    /* Valid focus range is between 0-1 */
    func adjustmentDelegateDidUpdateFocus(focus: Float)
    func adjustmentDelegateDidUpdateISO(ISO: Float)
    func adjustmentDelegateDidUpdateExposureDuration(exposureDurationInSeconds: Float64)

}
