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
        }, onCompleted: {
            self.allFullNameDictEmit.accept(self.allFullNameDict.keys.map { $0 } )
            self.allFirstNameDictEmit.accept(self.allFirstNameDict.keys.map { $0 } )
            self.allLastNameDictEmit.accept(self.allLastNameDict.keys.map { $0 } )
        })
    }
}
