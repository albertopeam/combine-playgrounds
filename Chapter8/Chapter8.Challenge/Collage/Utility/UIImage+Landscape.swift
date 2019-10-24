//
//  UIImage+Landscape.swift
//  Collage
//
//  Created by Alberto Penas Amor on 27/10/2019.
//  Copyright © 2019 Alberto Penas Amor. All rights reserved.
//

import UIKit.UIImage

extension UIImage {
    var isLandscape: Bool {
        return size.width > size.height
    }
}
