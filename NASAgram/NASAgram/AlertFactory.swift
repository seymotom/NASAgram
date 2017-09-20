//
//  AlertFactory.swift
//  NASAgram
//
//  Created by Tom Seymour on 7/12/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

//enum AlertError: String {
//    case hasNoImage = ""
//    case cantGetImage = ""
//}

struct AlertFactory {
    
    private let defaultTitle = "Error"
    private let defaultMessage = "Something went wrong, please try again"
    private let okay = "OK"
    private let view: UIViewController
    
    init(for view: UIViewController) {
        self.view = view
    }
    
    func showDefaultOKAlert() {
        showCustomOKAlert(title: defaultTitle, message: defaultMessage)
    }
    
    func showErrorAlert(message: String, completion: (() -> Void)? = nil) {
        showCustomOKAlert(title: defaultTitle, message: message)
    }
    
    func showCustomOKAlert(title: String, message: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: okay, style: .cancel) { (_) in
            if let completionAction = completion {
                completionAction()
            }
        }
        alert.addAction(okayAction)
        DispatchQueue.main.async {
            self.view.present(alert, animated: true, completion: nil)
        }
    }
}
