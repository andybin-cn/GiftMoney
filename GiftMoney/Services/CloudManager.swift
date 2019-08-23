//
//  CloudManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/22.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import CloudKit

class CloudManager {
    
    init() {
        
    }
    
    func backupTrades() {
        let publicDB = CKContainer.default().privateCloudDatabase
        publicDB.fetch(withRecordZoneID: CKRecordZone.ID(zoneName: "Trades", ownerName: "GidtMoney")) { (zone, error) in
            
        }
    }
}
