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
    func formValues() -> [String: Any]
    func validateForm() throws -> [String: Any]
}

enum FormInputValueSrtuct {
    case sigle
    case array
//    case dictionary
}

protocol FormInput {
    var fieldName: String { get }
    var valueSrtuct: FormInputValueSrtuct { get }
    var fieldValue: FormValue { get set }
    func validateField() throws -> FormValue
}

extension FormInput {
    var valueSrtuct: FormInputValueSrtuct {
        return FormInputValueSrtuct.sigle
    }
}

extension Int: FormValue {}
extension Double: FormValue {}
extension Float: FormValue {}
extension String: FormValue {}
extension Bool: FormValue {}
extension Date: FormValue {}
extension Array: FormValue where Element: FormValue {}
extension Dictionary: FormValue where Value: FormValue, Key == String {}

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
    
    func formValues() -> Dictionary<String, Any> {
        var result = [String : Any]()
        formInputs.forEach { (input) in
            if input.valueSrtuct == .array {
                if var array = result[input.fieldName] as? Array<FormValue> {
                    array.append(input.fieldValue)
                    result[input.fieldName] = array
                } else {
                    result[input.fieldName] = [input.fieldValue]
                }
            } else {
                result[input.fieldName] = input.fieldValue
            }
        }
        return result
    }
    
    func validateForm() throws -> Dictionary<String, Any> {
        var result = Dictionary<String, Any>()
        for input in formInputs {
            let value = try input.validateField()
            if input.valueSrtuct == .array {
                if var array = result[input.fieldName] as? Array<FormValue> {
                    array.append(value)
                    result[input.fieldName] = array
                } else {
                    result[input.fieldName] = [value]
                }
            } else {
                result[input.fieldName] = value
            }
        }
        return result
    }
}

extension UIViewController: Form {
    
    var formInputs: [FormInput] {
        return view?.formInputs ?? [FormInput]()
    }

    func formValues() -> [String : Any] {
        return view?.formValues() ?? [String : Any]()
    }
    
    func validateForm() throws -> [String : Any] {
        return try view?.validateForm() ?? [String : Any]()
    }
}
