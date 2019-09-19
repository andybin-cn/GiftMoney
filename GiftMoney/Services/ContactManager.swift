//
//  ContactManager.swift
//  GiftMoney
//
//  Created by binea on 2019/9/19.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RxSwift
import Contacts
import Common
import RxRelay

class Contact {
//    var name: String = ""
//    var mobile: String?
//    var firstName: String?
//    var lastName: String?
}

class ContactManager {
    static let shared = ContactManager()
    
    var allFullNameDictEmit = PublishRelay<[String]>()
    var allFirstNameDictEmit = PublishRelay<[String]>()
    var allLastNameDictEmit = PublishRelay<[String]>()
    
    var allFullNameDict = [String: String]() {
        didSet {
            UserDefaults.standard.set(allFullNameDict, forKey: "ContactManager-allFullNameDict")
        }
    }
    var allFirstNameDict = [String: String]() {
        didSet {
            UserDefaults.standard.set(allFirstNameDict, forKey: "ContactManager-allFirstNameDict")
        }
    }
    var allLastNameDict = [String: String]() {
        didSet {
            UserDefaults.standard.set(allLastNameDict, forKey: "ContactManager-allLastNameDict")
        }
    }
    
    func loadLocalData() {
        allFullNameDict = UserDefaults.standard.object(forKey: "ContactManager-allFullNameDict") as? [String: String] ?? [String: String]()
        allFirstNameDict = UserDefaults.standard.object(forKey: "ContactManager-allFirstNameDict") as? [String: String] ?? [String: String]()
        allLastNameDict = UserDefaults.standard.object(forKey: "ContactManager-allLastNameDict") as? [String: String] ?? [String: String]()
        allFullNameDictEmit.accept(allFullNameDict.keys.map { $0 })
        allFirstNameDictEmit.accept(allFirstNameDict.keys.map { $0 })
        allLastNameDictEmit.accept(allLastNameDict.keys.map { $0 })
    }
    
    private var hasInitContacts = false
    var initContactsObservable: Observable<CNContact>?
    func initContactsAndReqAuthorizationIfNeed() -> Observable<CNContact> {
        if let initContactsObservable = initContactsObservable {
            return initContactsObservable
        }
        if hasInitContacts {
            return Observable<CNContact>.empty()
        }
        let initContactsObservable = requestAuthorizationIfNeed().flatMap { (status) -> Observable<CNContact> in
            return self.fetchContacts()
        }.do(onError: { (_) in
           self.initContactsObservable = nil
        }, onCompleted: {
            self.hasInitContacts = true
            self.initContactsObservable = nil
        }) {
            self.initContactsObservable = nil
        }
        self.initContactsObservable = initContactsObservable
        return initContactsObservable
    }
    
    func requestAuthorizationIfNeed() -> Observable<CNAuthorizationStatus> {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status != .notDetermined {
            return Observable<CNAuthorizationStatus>.from(optional: status)
        }
        return Observable<CNAuthorizationStatus>.create({ (observer) -> Disposable in
            CNContactStore().requestAccess(for: .contacts) { (granted, error) in
                let status = CNContactStore.authorizationStatus(for: .contacts)
                observer.onNext(status)
                observer.onCompleted()
            }
            return Disposables.create { }
        })
    }
    
    func fetchContacts() -> Observable<CNContact> {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        guard status == .authorized else {
            return Observable<CNContact>.error(AuthorizationError(type: .contact))
        }
        
        return Observable<CNContact>.create({ (observer) -> Disposable in
            let store = CNContactStore()
            let keys = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactNicknameKey,
                        CNContactOrganizationNameKey, CNContactJobTitleKey,
                        CNContactDepartmentNameKey, CNContactNoteKey, CNContactPhoneNumbersKey,
                        CNContactEmailAddressesKey, CNContactPostalAddressesKey,
                        CNContactDatesKey, CNContactInstantMessageAddressesKey
            ]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            do {
                try store.enumerateContacts(with: request, usingBlock: {
                    (contact : CNContact, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
                    observer.onNext(contact)
                    if stop.pointee.boolValue {
                        observer.onCompleted()
                    }
                })
            } catch {
                observer.onError(error)
                SLog.error(error)
            }
            return Disposables.create { }
        }).do(onNext: { (contact) in
            //获取姓名
            let lastName = contact.familyName
            let firstName = contact.givenName
            SLog.debug("姓名：\(lastName)\(firstName)")
            self.allFullNameDict["\(lastName)\(firstName)"] = "\(lastName)\(firstName)"
            self.allLastNameDict[lastName] = lastName
            self.allFirstNameDict[firstName] = firstName
            
            //获取昵称
            let nikeName = contact.nickname
            SLog.debug("昵称：\(nikeName)")
            self.allFullNameDict[nikeName] = nikeName
            
            //获取公司（组织）
            let organization = contact.organizationName
            SLog.debug("公司（组织）：\(organization)")
            
            //获取职位
            let jobTitle = contact.jobTitle
            SLog.debug("职位：\(jobTitle)")
            
            //获取部门
            let department = contact.departmentName
            SLog.debug("部门：\(department)")
            
            //获取备注
            let note = contact.note
            SLog.debug("备注：\(note)")
            
            //获取电话号码
            SLog.debug("电话：")
            for phone in contact.phoneNumbers {
                //获得标签名（转为能看得懂的本地标签名，比如work、home）
                var label = "未知标签"
                if phone.label != nil {
                    label = CNLabeledValue<NSString>.localizedString(forLabel:
                        phone.label!)
                }
                
                //获取号码
                let value = phone.value.stringValue
                SLog.debug("\t\(label)：\(value)")
            }
            
            //获取Email
            SLog.debug("Email：")
            for email in contact.emailAddresses {
                //获得标签名（转为能看得懂的本地标签名）
                var label = "未知标签"
                if email.label != nil {
                    label = CNLabeledValue<NSString>.localizedString(forLabel:
                        email.label!)
                }
                
                //获取值
                let value = email.value
                SLog.debug("\t\(label)：\(value)")
            }
            
            //获取地址
            SLog.debug("地址：")
            for address in contact.postalAddresses {
                //获得标签名（转为能看得懂的本地标签名）
                var label = "未知标签"
                if address.label != nil {
                    label = CNLabeledValue<NSString>.localizedString(forLabel:
                        address.label!)
                }
                
                //获取值
                let detail = address.value
                let contry = detail.value(forKey: CNPostalAddressCountryKey) ?? ""
                let state = detail.value(forKey: CNPostalAddressStateKey) ?? ""
                let city = detail.value(forKey: CNPostalAddressCityKey) ?? ""
                let street = detail.value(forKey: CNPostalAddressStreetKey) ?? ""
                let code = detail.value(forKey: CNPostalAddressPostalCodeKey) ?? ""
                let str = "国家:\(contry) 省:\(state) 城市:\(city) 街道:\(street)"
                    + " 邮编:\(code)"
                SLog.debug("\t\(label)：\(str)")
            }
            
            //获取纪念日
            SLog.debug("纪念日：")
            for date in contact.dates {
                //获得标签名（转为能看得懂的本地标签名）
                var label = "未知标签"
                if date.label != nil {
                    label = CNLabeledValue<NSString>.localizedString(forLabel:
                        date.label!)
                }
                
                //获取值
                let dateComponents = date.value as DateComponents
                let value = NSCalendar.current.date(from: dateComponents)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
                SLog.debug("\t\(label)：\(dateFormatter.string(from: value!))")
            }
            
            //获取即时通讯(IM)
            SLog.debug("即时通讯(IM)：")
            for im in contact.instantMessageAddresses {
                //获得标签名（转为能看得懂的本地标签名）
                var label = "未知标签"
                if im.label != nil {
                    label = CNLabeledValue<NSString>.localizedString(forLabel:
                        im.label!)
                }
                
                //获取值
                let detail = im.value
                let username = detail.value(forKey: CNInstantMessageAddressUsernameKey)
                    ?? ""
                let service = detail.value(forKey: CNInstantMessageAddressServiceKey)
                    ?? ""
                SLog.debug("\t\(label)：\(username) 服务:\(service)")
            }
        }, onCompleted: {
            self.allFullNameDictEmit.accept(self.allFullNameDict.keys.map { $0 } )
            self.allFirstNameDictEmit.accept(self.allFirstNameDict.keys.map { $0 } )
            self.allLastNameDictEmit.accept(self.allLastNameDict.keys.map { $0 } )
        })
    }
}
