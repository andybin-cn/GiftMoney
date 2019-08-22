//
//  TempExcelPreviewVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/21.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import QuickLook

class TempExcelPreviewVC: QLPreviewController, QLPreviewControllerDataSource, QLPreviewItem {
    
    let url: URL
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        try? FileManager.default.removeItem(at: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        currentPreviewItemIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self
    }
    
    //MARK: - QLPreviewItem
    var previewItemURL: URL? {
        url
    }
    var previewItemTitle: String? {
        return "导出预览"
    }
}
