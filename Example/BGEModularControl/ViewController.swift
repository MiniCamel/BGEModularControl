//
//  ViewController.swift
//  BGEModularControl
//
//  Created by Bge on 07/05/2021.
//  Copyright (c) 2021 Bge. All rights reserved.
//

import UIKit
import BGEModularControl

class ViewController: UIViewController {
    var modularListControl = BGEModularControl()
    var titleArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleArray = ["美食",
                           "美团超市",
                           "生鲜果蔬",
                           "家常菜",
                           "校园优选",
                           "美团专送",
                           "下午茶",
                           "跑腿代购",
                           "快餐简餐",
                           "免配送费",
                           "小吃馆",
                           "鲜花蛋糕",
                           "粥粉面",
                           "炸鸡零食",
                           "能量西餐"]
        
        self.modularListControl.delegate = self
        self.modularListControl.dataSource = self
        self.modularListControl.scrollEnabled = true
        self.modularListControl.register(ModularListViewCell.self, forCellWithReuseIdentifier: "ModularListViewCell")
        self.view.addSubview(self.modularListControl)
        self.modularListControl.mas_makeConstraints { (make) in
            make?.left.offset()(5)
            make?.right.offset()(-5)
            make?.top.offset()(100)
            make?.height.offset()(self.modularListControl.viewHeight())
        }
        
        let button = UIButton()
        button.setTitle("reload", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(reloadModularControl), for: .touchUpInside)
        self.view.addSubview(button)
        button.mas_makeConstraints { (make) in
            make?.top.equalTo()(self.modularListControl.mas_bottom)?.offset()(20)
            make?.centerX.equalTo()(self.view)
            make?.width.offset()(150)
            make?.height.offset()(30)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NSLog("" + String(self.modularListControl.scrollEnabled))
    }
    
    @objc func reloadModularControl() -> () {
        if self.titleArray.count < 12 {
            self.titleArray = ["美食",
                               "美团超市",
                               "生鲜果蔬",
                               "家常菜",
                               "校园优选",
                               "美团专送",
                               "下午茶",
                               "跑腿代购",
                               "快餐简餐",
                               "免配送费",
                               "小吃馆",
                               "鲜花蛋糕",
                               "粥粉面",
                               "炸鸡零食",
                               "能量西餐"]
        } else {
            self.titleArray = ["美食",
                               "美团超市",
                               "生鲜果蔬",
                               "家常菜",
                               "校园优选",
                               "美团专送",
                               "下午茶",
                               "跑腿代购",
                               "快餐简餐",
                               "免配送费",
                               "小吃馆"]
        }
        self.modularListControl.reloadData()
    }
}

extension ViewController: BGEModularControlDelegate, BGEModularControlDataSource {
    func numberOfItemsPerRow(in modularControl: BGEModularControl) -> Int {
        5
    }
    
    func maxNumberOfRows(in modularControl: BGEModularControl) -> Int {
        2
    }
    
    func numberOfItems(in modularControl: BGEModularControl) -> Int {
        self.titleArray.count
    }
    
    func heightForItem(in modularControl: BGEModularControl) -> CGFloat {
        UIScreen.main.bounds.size.width / 4.0 + 10
    }
    
    func modularControl(_ modularControl: BGEModularControl, cellForItemAt index: Int) -> BGEModularViewCell {
        let cell = modularControl.dequeueReusableCell(withReuseIdentifier: "ModularListViewCell", for: index) as! ModularListViewCell
        
        cell.titleLabel.text = self.titleArray[index]
        cell.imageView.image = UIImage.init(named: self.titleArray[index])
        
        return cell
    }
    
    func modularControl(_ modularControl: BGEModularControl, didSelectItemAt index: Int) {
        NSLog("did select at index: " + String(index))
    }
}
