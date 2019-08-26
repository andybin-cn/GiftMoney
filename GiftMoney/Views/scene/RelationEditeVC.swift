//
//  RelationEditeVC.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/16.
//  Copyright © 2019 binea. All rights reserved.
//

import UIKit
import SnapKit
import Common

class RelationEditeVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    
    let inputContainerView = UIView()
    let inputField = UITextField()
    let latestusedRelationships = Relationship.latestusedRelationships
    let customRelationships: [Relationship]
    
    var onResult: ((_ relation: Relationship) -> Void)?
    
    init(defaultValue: String? = "", onResult: ((_ relation: Relationship) -> Void)? = nil) {
        self.onResult = onResult
        inputField.text = defaultValue
        customRelationships = latestusedRelationships.filter({ (relation) -> Bool in
            return !Relationship.systemRelationship.contains { (systemRelation) -> Bool in
                relation.name == systemRelation.name
            }
        })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let saveButton = UIBarButtonItem(title: "保存", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonTapped))
        self.navigationItem.rightBarButtonItems = [saveButton]
        
        inputContainerView.apply { (inputView) in
            inputView.backgroundColor = .white
            inputView.addTo(view) { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(ScreenHelp.navBarHeight)
                make.height.equalTo(42)
            }
        }
        inputField.apply { (inputField) in
            inputField.placeholder = "自定义关系（直接保存即可）"
            inputField.font = .appFont(ofSize: 13)
            inputField.layer.cornerRadius = 18
            inputField.backgroundColor = .white
            inputField.layer.borderWidth = 0.5
            inputField.layer.borderColor = UIColor.appGrayLine.cgColor
            inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 20))
            inputField.leftViewMode = .always
            inputField.addTo(inputContainerView) { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.height.equalTo(36)
            }
        }
        
        tableView.apply { (tableView) in
            tableView.register(EventCell.self, forCellReuseIdentifier: EventCell.commonIdentifier)
            tableView.estimatedRowHeight = 80
            tableView.delegate = self
            tableView.dataSource = self
            tableView.setExtraCellLineHidden()
            
            tableView.addTo(self.view) { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(inputContainerView.snp.bottom)
            }
        }
    }
    
    //MARK: - ITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if latestusedRelationships.count > 0 {
            return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().then { (header) in
            header.backgroundColor = .appGrayLine
            UILabel().apply { (label) in
                label.text = section == 0 ? "最近使用" : "内置关系"
                label.textColor = UIColor.appSecondaryYellow
                label.font = .appFont(ofSize: 18)
                label.addTo(header) { (make) in
                    make.left.equalTo(15)
                    make.centerY.equalToSuperview()
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if latestusedRelationships.count > 0, section == 0  {
            return latestusedRelationships.count
        } else {
            return Relationship.systemRelationship.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let relation: Relationship
        if latestusedRelationships.count > 0, indexPath.section == 0  {
            relation = latestusedRelationships[indexPath.row]
        } else {
            relation = Relationship.systemRelationship[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.commonIdentifier, for: indexPath) as! EventCell
        cell.textLabel?.text = relation.name
//        cell.detailTextLabel?.text = relation.time?.toString(withFormat: "yyyy-MM-dd")
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let relation: Relationship
        if latestusedRelationships.count > 0, indexPath.section == 0  {
            relation = latestusedRelationships[indexPath.row]
        } else {
            relation = Relationship.systemRelationship[indexPath.row]
        }
        self.onResult?(relation)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveButtonTapped() {
        guard let name = inputField.text else {
            self.showTipsView(text: "请输入内容或者选择一个选项")
            return
        }
        guard MarketManager.shared.checkAuth(type: .relation, controller: self, count: customRelationships.count) else {
            return
        }
        let relation = Relationship(name: name)
        self.onResult?(relation)
        self.navigationController?.popViewController(animated: true)
    }
    
}
