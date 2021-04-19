//
//  ArrangeSubviews.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/04/16.
//

import UIKit

extension UIStackView {
    func addArrangeSubviews(_ views: [UIView]) {
        for view in views {
            addArrangedSubview(view)
        }
    }
}
