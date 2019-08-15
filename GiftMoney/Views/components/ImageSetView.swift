//
//  ImageSetView.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/14.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import PhotosUI

extension AVAsset {
    var thumbnailImage: UIImage? {
        if self.tracks(withMediaType: AVMediaType.video).count > 0 {
            let imageGenerator = AVAssetImageGenerator(asset: self)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.apertureMode = .encodedPixels
            if let cgImage = try? imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

extension UIImageView {
    func ab_setImage(media: TradeMedia) {
        let path = media.path
        image = UIImage(named: "placeHoldeImage")
        if media.hasSaved {
            if media.type == TradeMedia.MediaType.image {
                DispatchQueue.global().async { [weak self] in
                    let image = UIImage(contentsOfFile: path)
                    DispatchQueue.main.sync { [weak self] in
                        self?.image = image
                    }
                }
            } else if media.type == TradeMedia.MediaType.video {
                DispatchQueue.global().async { [weak self] in
                    let image = AVAsset(url: URL(fileURLWithPath: path)).thumbnailImage
                    DispatchQueue.main.sync { [weak self] in
                        self?.image = image
                    }
                }
            }
        } else {
            if media.type == TradeMedia.MediaType.video, let asset = media.phAsset {
                DispatchQueue.global().async { [weak self] in
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, info) in
                        if let urlAsset = asset as? AVURLAsset, let image = urlAsset.thumbnailImage {
                            DispatchQueue.main.sync { [weak self] in
                                self?.image = image
                            }
                        }
                    }
                }
            } else if media.type == TradeMedia.MediaType.image, let image = media.phImage {
                self.image = image
            }
        }
    }
}

protocol ImageSetViewDelegate: class {
    func imageSet(view: ImageSetView, didSelectMedia media: TradeMedia, atIndex index: Int)
//    func imageSet(view: ImageSetView, didDeleteMedia media: TradeMedia, atIndex index: Int)
    func imageSetDidAddbuttonTapped(view: ImageSetView)
}

class ImageSetView: UIView {
    
    private(set) var medias: [TradeMedia] = []
    private(set) var imageSize: CGSize = CGSize(width: 100, height: 100)
    private(set) var imageCountInLine: Int = 4
    
    var verticalStackView: UIStackView = UIStackView()
    var horizontalStackViews: [UIStackView] = []
    weak var delegate: ImageSetViewDelegate?
    
    init() {
        super.init(frame: .zero)
        verticalStackView.apply { (stackView) in
            stackView.axis = .vertical
            stackView.alignment = .top
            stackView.distribution = .equalSpacing
            stackView.spacing = 8
            stackView.addTo(self, layout: { (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init error")
    }
    
    func setImageViews(showMedias: [TradeMedia], imageSize: CGSize, imageCountInLine: Int, isShowAddButton: Bool = false) {
        medias = showMedias
        self.imageSize = imageSize
        self.imageCountInLine = imageCountInLine
        
        if isShowAddButton {
            medias.append(TradeMedia())
        }
        
        for subView in verticalStackView.arrangedSubviews {
            verticalStackView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
        var stackView = UIStackView()
        
        for (index, media) in medias.enumerated() {
            if index % imageCountInLine == 0 {
                stackView = UIStackView().then { (stackView) in
                    stackView.axis = .horizontal
                    stackView.alignment = .leading
                    stackView.distribution = .equalSpacing
                    stackView.spacing = 8
                }
                verticalStackView.addArrangedSubview(stackView)
            }
            
            let imageView = UIImageView().then({ (imageView) in
//                imageView.image = image
                imageView.ab_setImage(media: media)
                imageView.tag = index + 100
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTapped(sender:)))
                imageView.addGestureRecognizer(tapGesture)
                imageView.snp.makeConstraints({ (make) in
                    make.size.equalTo(imageSize)
                })
            })
            
            if isShowAddButton {
                if index == medias.count - 1 {
                    imageView.tag = 11
                    imageView.image = UIImage(named: "tianjiazhaop")
                    imageView.contentMode = .scaleToFill
                }
            }
            
            stackView.addArrangedSubview(imageView)
        }
    }
    
    @objc func imageViewTapped(sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }
        if imageView.tag == 11 {
            delegate?.imageSetDidAddbuttonTapped(view: self)
            return
        }
        let index = imageView.tag - 100
        if index >= 0 && index < medias.count {
            delegate?.imageSet(view: self, didSelectMedia: medias[index], atIndex: index)
        }
    }
    
    @objc func deleteButtonTapped(sender: UIButton) {
        let index = sender.tag - 100
        if index >= 0 && index < medias.count {
//            delegate?.imageSet(view: self, didDeleteMedia: medias[index], atIndex: index)
        }
    }
}
