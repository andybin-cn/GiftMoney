//
//  ImagesManager.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/22.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import RxSwift
import Common
import CloudKit

class ImagesManager {
    static let shared = ImagesManager()
    
    private init() {
        
    }
    
    func saveMedia(at srcURL: URL, to dstURL: URL) -> Bool {
        let directory = dstURL.deletingLastPathComponent()
        do {
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch {
            return false
        }
        return true
    }
    
    func exportImages() -> Observable<URL> {
        let workPath = "\(NSTemporaryDirectory())imageExport"
        let fileName = "礼尚往来-图片-\(Date().toString(withFormat: "MM月dd日HH-mm")).zip"
        let fileUrl = URL(fileURLWithPath: "\(workPath)/\(fileName)")
        let mediaDirectory = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/Medias")
        
        return Observable<URL>.create { (observable) -> Disposable in
            DispatchQueue.global().async {
                do {
                    if FileManager.default.fileExists(atPath: workPath) {
                        let contentsOfPath = try FileManager.default.contentsOfDirectory(atPath: workPath)
                        try contentsOfPath.forEach { (content) in
                            try FileManager.default.removeItem(atPath: "\(workPath)/\(content)")
                        }
                    }
                    try FileManager.default.createDirectory(atPath: workPath, withIntermediateDirectories: true, attributes: nil)
                } catch _ { }
                
                if SSZipArchive.createZipFile(atPath: fileUrl.path, withContentsOfDirectory: mediaDirectory.path) {
                    DispatchQueue.main.async {
                        observable.onNext(fileUrl)
                        observable.onCompleted()
                    }
                } else {
                    DispatchQueue.main.async {
                        observable.onError(CommonError(message: "导出失败，请重试。"))
                    }
                }
            }
            return Disposables.create {
                
            }
        }
    }
    
    func importFromZip(url: URL) -> Observable<Int> {
        return Observable<Int>.create { (observable) -> Disposable in
            let workPath = "\(NSTemporaryDirectory())imageImport"
            let tempUrlPath = "\(workPath)/\(UUID().uuidString).\(url.pathExtension)"
            let tempUrl = URL(fileURLWithPath: tempUrlPath)
            let tempMediasDirectory = URL(fileURLWithPath: "\(workPath)/Medias")
            DispatchQueue.global().async {
                do {
                    let manager = FileManager.default
                    
                    if manager.fileExists(atPath: workPath) {
                        let contentsOfPath = try manager.contentsOfDirectory(atPath: workPath)
                        try contentsOfPath.forEach { (content) in
                            try manager.removeItem(atPath: "\(workPath)/\(content)")
                        }
                    }
                    
                    try manager.createDirectory(at: tempMediasDirectory, withIntermediateDirectories: true, attributes: nil)
                    
                    
                    try manager.copyItem(at: url, to: tempUrl)
                    
                    if SSZipArchive.unzipFile(atPath: tempUrl.path, toDestination: tempMediasDirectory.path) {
                        let images = manager.enumerator(at: tempMediasDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
                        let successCount = self.enumeratorImages(images: images)
                        DispatchQueue.main.async {
                            observable.onNext(successCount)
                            observable.onCompleted()
                        }
                    } else {
                        DispatchQueue.main.async {
                            observable.onError(CommonError(message: "解压数据出错了"))
                        }
                    }
                    
                } catch let error {
                    DispatchQueue.main.async {
                        observable.onError(error)
                    }
                }
            }
            return Disposables.create {
                do {
                    try FileManager.default.removeItem(at: tempUrl)
                    try FileManager.default.removeItem(at: tempMediasDirectory)
                } catch _ {
                    
                }
            }
        }
    }
    
    func enumeratorImages(images: FileManager.DirectoryEnumerator?) -> Int {
        let realm = RealmManager.share.realm
        let mediaDirectory = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/Medias")
        var successCount = 0
        images?.forEach({ (imageUrl) in
            if let url = imageUrl as? URL {
                let fileID = url.deletingPathExtension().lastPathComponent
                let destination = URL(fileURLWithPath: "\(mediaDirectory.path)/\(url.lastPathComponent)")
                if realm.object(ofType: TradeMedia.self, forPrimaryKey: fileID) == nil {
                    return
                }
                if FileManager.default.fileExists(atPath: destination.path) {
                    return
                }
                if saveMedia(at: url, to: destination) {
                    successCount += 1
                }
            }
        })
        return successCount
    }
    
    func recoverImages(assets: [CKAsset], medias: [TradeMedia]) {
        let mediaDirectory = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/Medias")
        if !FileManager.default.fileExists(atPath: mediaDirectory.path) {
            try? FileManager.default.createDirectory(at: mediaDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        assets.enumerated().forEach { (index, asset) in
            if index >= medias.count {
                return
            }
            guard let srcUrl = asset.fileURL else {
                return
            }
            let dstURL = medias[index].url
            try? FileManager.default.copyItem(at: srcUrl, to: dstURL)
        }
    }
}
