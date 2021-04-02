//
//  File.swift
//  Nosoky
//
//  Created by Yahya Saddiq on 4/2/21.
//

import UIKit
import XCTest

extension UIViewController {
    public class func instance<T: UIViewController>(
        from storyboardName: String,
        with identifier: String = String("\(T.self)"),
        bundle: Bundle? = nil
    ) -> T {
        // if storyboard with storyboardName doesn't exist or bundle doesn't contain storyboard then init
        // of UIStoryboard will throw NSException
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        guard let storyboardVC = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            XCTFail("Can't init \(T.self) with \(storyboardName):\(identifier) using \(T.self)()")
            return T()
        }
        return storyboardVC
    }
}
