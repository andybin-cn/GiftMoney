//
//  TradeFunctionHeader.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/26.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import Common


class TradeFunctionHeader: UIView {
    let buttonStackView = UIStackView()
    let labelsStackView = UIStackView()
    
    let filterButton = UIButton()
    let sortButton = UIButton()
    
    let label1 = UILabel(textColor: UIColor.appSecondaryRed, font: .appFont(ofSize: 14))
    let label2 = UILabel(textColor: UIColor.appSecondaryRed, font: .appFont(ofSize: 14))
    
    
    let filterView = TradeFunctionFilterView()
    let sortView = TradeFuntionSortView()
    weak var parentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        filterButton.apply { (button) in
            button.addTarget(self, action: #selector(onFilterButtonTapped), for: .touchUpInside)
            button.setTitle("筛选", for: .normal)
            button.titleLabel?.font = UIFont.appFont(ofSize: 13)
            button.setTitleColor(UIColor.appGrayText, for: .normal)
            button.setImage(UIImage(named: "icons8-filter")?.ui_resizeImage(to: CGSize(width: 18, height: 18)).ui_renderImage(tintColor: UIColor.appGrayText), for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        }
        
        sortButton.apply { (button) in
            button.addTarget(self, action: #selector(onSortButton), for: .touchUpInside)
            button.setTitle("排序", for: .normal)
            button.setTitleColor(UIColor.appGrayText, for: .normal)
            button.setImage(UIImage(named: "icons8-generic_sorting")?.ui_resizeImage(to: CGSize(width: 18, height: 18)).ui_renderImage(tintColor: UIColor.appGrayText), for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        }
        
        buttonStackView.apply { (stackView) in
            let spilSetter = UIView.propertySetter { (spil) in
                spil.backgroundColor = UIColor.appGrayLine
                spil.snp.makeConstraints { (make) in
                    make.height.equalTo(30)
                    make.width.equalTo(0.5)
                }
            }
            
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.addTo(self) { (make) in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(35)
            }
            
            spilSetter(UIView()).addTo(filterButton) { (make) in
                make.left.equalTo(filterButton.snp.right)
                make.centerY.equalToSuperview()
            }
            stackView.addArrangedSubview(filterButton)
            stackView.addArrangedSubview(sortButton)
        }
        
        let spil = UIView().then { (spil) in
            spil.backgroundColor = UIColor.appGrayLine
            spil.addTo(self) { (make) in
                make.top.equalTo(buttonStackView.snp.bottom)
                make.width.equalToSuperview().offset(-20)
                make.centerX.equalToSuperview()
                make.height.equalTo(0.5)
            }
        }
        
        labelsStackView.apply { (stackView) in
            let spilSetter = UIView.propertySetter { (spil) in
                spil.backgroundColor = UIColor.appGrayLine
                spil.snp.makeConstraints { (make) in
                    make.height.equalTo(30)
                    make.width.equalTo(0.5)
                }
            }
            
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.addTo(self) { (make) in
                make.top.equalTo(spil.snp.bottom)
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(35)
            }
            
            spilSetter(UIView()).addTo(label1) { (make) in
                make.left.equalTo(label1.snp.right)
                make.centerY.equalToSuperview()
            }
            stackView.addArrangedSubview(label1)
            stackView.addArrangedSubview(label2)
        }
        
        self.backgroundColor = UIColor.appSecondaryGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showFilter() {
        guard let parentView = parentView else {
            return
        }
        sortView.removeFromSuperview()
        filterView.addTo(parentView) { (make) in
            make.top.equalTo(buttonStackView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func showSortView() {
        guard let parentView = parentView else {
            return
        }
        filterView.removeFromSuperview()
        sortView.addTo(parentView) { (make) in
            make.top.equalTo(buttonStackView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc func onFilterButtonTapped() {
        if filterView.superview != nil {
            filterView.removeFromSuperview()
        } else {
            showFilter()
        }
    }
    
    @objc func onSortButton() {
        if sortView.superview != nil {
            sortView.removeFromSuperview()
        } else {
            showSortView()
        }
    }
}
