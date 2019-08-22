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
import QuickLook

class TradeMedia: Object, Mappable, QLPreviewItem {
    enum MediaType: String {
        case image = "image"
        case video = "video"
    }
    
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var tradeID: String = ""
    @objc dynamic private var typeString: String = ""
    var url: URL {
        var url = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/Medias")
        let suffix = type == .image ? "png" : "mp4"
        url.appendPathComponent(id)
        url.appendPathExtension(suffix)
        return url
    }
    
    var phAsset: PHAsset?
    var phImage: UIImage?
    var originURL: URL?
    
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
        if map.mappingType == .fromJSON {
            id <- map["id"]
        } else {
            id >>> map["id"]
        }
        tradeID <- map["tradeID"]
        typeString <- map["type"]
//        path <- map["path"]
    }
    func prepareForOriginUrl() -> Observable<TradeMedia> {
        return Observable<TradeMedia>.create { (observable) -> Disposable in
            if self.type == TradeMedia.MediaType.video, let asset = self.phAsset {
                PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { [weak self] (asset, audioMix, info) in
                    if let urlAsset = asset as? AVURLAsset {
                        self?.originURL = urlAsset.url
                        DispatchQueue.main.sync {
                            observable.onCompleted()
                        }
                    }
                }
            } else if self.type == TradeMedia.MediaType.image, let asset = self.phAsset {
                asset.requestContentEditingInput(with: nil) { [weak self] (input, info) in
                    self?.originURL = input?.fullSizeImageURL
                    observable.onCompleted()
                }
            } else {
                observable.onCompleted()
            }
            return Disposables.create { }
        }
    }
    func saveResourceIntoApp() -> Observable<TradeMedia> {
        return Observable<TradeMedia>.create { (observable) -> Disposable in
            let destURL = self.url
            if let originURL = self.originURL {
                DispatchQueue.global().async {
                    if ImagesManager.shared.saveMedia(at: originURL, to: destURL) {
                        DispatchQueue.main.sync {
                            observable.onCompleted()
                        }
                    } else {
                        DispatchQueue.main.sync {
                            observable.onError(CommonError(message: "图片资源保存失败"))
                        }
                    }
                }
            } else {
                observable.onCompleted()
            }
            return Disposables.create { }
        }
    }
    
    //MARK: - QLPreviewItem
    var previewItemURL: URL? {
        return url
    }
    var previewItemTitle: String? {
        switch type {
        case .some(.image):
            return "图片"
        case .some(.video):
            return "视频"
        default:
            return "未知"
        }
    }
    
}
