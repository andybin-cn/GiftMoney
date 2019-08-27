//
//  TradeFunctionHeader.swift
//  GiftMoney
//
//  Created by andy.bin on 2019/8/26.
//  Copyright © 2019 binea. All rights reserved.
//

import Foundation
import Common


protocol TradeFunctionHeaderDelegate: class {
    func functionHeaderChanged(header: TradeFunctionHeader, filter: FilterOption, sortType: TradeFuntionSort)
}

class TradeFunctionHeader: UIView {
    let buttonStackView = UIStackView()
    let labelsStackView = UIStackView()
    
    let filterButton = UIButton()
    let sortButton = UIButton()
    
    let label1 = UILabel(textColor: UIColor.appSecondaryRed, font: .appFont(ofSize: 14))
    let label2 = UILabel(textColor: UIColor.appSecondaryRed, font: .appFont(ofSize: 14))
    
    
    let filterView = TradeFunctionFilterView()
    let sortView = TradeFuntionSortView()
    let toolBar = UIView()
    let containerMaskView = UIView()
    let containerView = UIView()
    weak var parentView: UIView?
    
    weak var delegate: TradeFunctionHeaderDelegate?
    
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
            button.titleLabel?.font = UIFont.appFont(ofSize: 13)
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
            label1.textAlignment = .center
            label2.textAlignment = .center
            stackView.addArrangedSubview(label1)
            stackView.addArrangedSubview(label2)
        }
        
        self.backgroundColor = UIColor.appSecondaryGray
        
        containerMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        containerView.backgroundColor = .white
        toolBar.backgroundColor = .white
        containerView.addTo(containerMaskView) { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(ScreenHelp.windoHeight * 0.5)
        }
        
        toolBar.apply { (toolBar) in
            toolBar.addTo(containerMaskView) { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(containerView.snp.bottom).offset(0.5)
                make.height.equalTo(50)
            }
            
            let saveButton = UIButton().then { (button) in
                button.setTitle("确定", for: .normal)
                button.setTitleColor(UIColor.white, for: .normal)
                button.setBackgroundImage(UIColor.appMainRed.toImage(), for: .normal)
                button.layer.cornerRadius = 17
                button.layer.masksToBounds = true
                button.addTarget(self, action: #selector(onSaveButtontapped), for: .touchUpInside)
                
                button.addTo(toolBar) { (make) in
                    make.height.equalTo(34)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(80)
                    make.right.equalTo(-15)
                }
            }
            
            UIButton().apply { (button) in
                button.setTitle("重置", for: .normal)
                button.setTitleColor(UIColor.appMainRed, for: .normal)
                button.setBackgroundImage(UIColor.white.toImage(), for: .normal)
                button.layer.borderColor = UIColor.appMainRed.cgColor
                button.layer.borderWidth = 1
                button.layer.cornerRadius = 17
                button.layer.masksToBounds = true
                button.addTarget(self, action: #selector(onResetButtontapped), for: .touchUpInside)
                
                button.addTo(toolBar) { (make) in
                    make.height.equalTo(34)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(80)
                    make.right.equalTo(saveButton.snp.left).offset(-15)
                }
            }
        }
        
        UIView().apply { (view) in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onContainerMaskViewTapped))
            view.addGestureRecognizer(tapGesture)
            view.addTo(containerMaskView) { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(toolBar.snp.bottom)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showContainerView() {
        guard let parentView = parentView else {
            return
        }
        if containerMaskView.superview == nil {
            containerMaskView.addTo(parentView) { (make) in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(buttonStackView.snp.bottom)
            }
        }
    }
    
    func showFilter() {
        showContainerView()
        sortView.removeFromSuperview()
        filterView.addTo(containerView) { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func showSortView() {
        showContainerView()
        filterView.removeFromSuperview()
        sortView.addTo(containerView) { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func onFilterButtonTapped() {
        if filterView.superview != nil {
            dissmisPopup()
        } else {
            showFilter()
        }
    }
    
    @objc func onSortButton() {
        if sortView.superview != nil {
            dissmisPopup()
        } else {
            showSortView()
        }
    }
    
    @objc func onSaveButtontapped() {
        dissmisPopup()
    }
    @objc func onResetButtontapped() {
        filterView.reset()
        sortView.reset()
    }
    @objc func onContainerMaskViewTapped() {
        dissmisPopup()
    }
    
    func dissmisPopup() {
        containerMaskView.removeFromSuperview()
        sortView.removeFromSuperview()
        filterView.removeFromSuperview()
        
        delegate?.functionHeaderChanged(header: self, filter: filterView.filteroptions, sortType: sortView.sortType)
    }
}
