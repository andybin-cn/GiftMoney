//
//  TradeMedia.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/8.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import PhotosUI
import RxSwift
import Common

class TradeMedia: Object, Mappable {
    enum MediaType: String {
        case image = "image"
        case video = "video"
    }
    
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var tradeID: String = ""
    @objc dynamic private var typeString: String = ""
    @objc dynamic var path: String = ""
    
    var phAsset: PHAsset?
    var phImage: UIImage?
    var hasSaved: Bool {
        return phAsset == nil && phImage == nil
    }
    
    var type: MediaType? {
        get {
            return MediaType.init(rawValue: typeString)
        }
        set {
            typeString = newValue?.rawValue ?? ""
        }
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        tradeID <- map["tradeID"]
        typeString <- map["type"]
        path <- map["path"]
    }
    
    func saveResourceIntoApp() -> Observable<TradeMedia> {
        return Observable<TradeMedia>.create { (observable) -> Disposable in
            if self.type == TradeMedia.MediaType.video, let asset = self.phAsset {
                PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, info) in
                    if let urlAsset = asset as? AVURLAsset {
                        do {
                            try FileManager.default.copyItem(at: urlAsset.url, to: URL(fileURLWithPath: self.path))
                            observable.onCompleted()
                        } catch let error {
                            observable.onError(error)
                        }
                    }
                }
            } else if self.type == TradeMedia.MediaType.image, let image = self.phImage {
                let path = self.path
                DispatchQueue.global().async {
                    do {
                        try image.write(toFile: path, format: ImageFormat.png)
                    } catch let error {
                        DispatchQueue.main.sync {
                            observable.onError(error)
                        }
                    }
                    DispatchQueue.main.sync {
                        observable.onCompleted()
                    }
                }
            }
            return Disposables.create { }
        }
    }
}
