//
//  Form.swift
//  GiftMoney
//
//  Created by binea on 2019/8/6.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit

protocol FormValue {
    
}

protocol Form {
    func formValues() -> [String: FormValue]
    func validateForm() throws -> [String: FormValue]
}

protocol FormInput {
    var fieldName: String { get }
    var fieldValue: FormValue { get set }
    func validateField() throws -> FormValue
}

extension Int: FormValue {}
extension Double: FormValue {}
extension Float: FormValue {}
extension String: FormValue {}
extension Bool: FormValue {}

extension UIView: Form {
    var formInputs: [FormInput] {
        var result = [FormInput]()
        subviews.forEach { (subView) in
            if let formInput = subView as? FormInput {
                result.append(formInput)
            } else if subView.subviews.count > 0 {
                result.append(contentsOf: subView.formInputs)
            }
        }
        return result
    }
    
    func formValues() -> [String : FormValue] {
        var result = [String : FormValue]()
        formInputs.forEach { (input) in
            result[input.fieldName] = input.fieldValue
        }
        return result
    }
    
    func validateForm() throws -> [String : FormValue] {
        var result = [String : FormValue]()
        for input in formInputs {
            result[input.fieldName] = try input.validateField()
        }
        return result
    }
}

extension UIViewController: Form {
    
    var formInputs: [FormInput] {
        return view?.formInputs ?? [FormInput]()
    }

    func formValues() -> [String : FormValue] {
        view?.formValues() ?? [String : FormValue]()
    }
    
    func validateForm() throws -> [String : FormValue] {
        try view?.validateForm() ?? [String : FormValue]()
    }


}
