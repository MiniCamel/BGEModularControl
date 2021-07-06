//
//  ModularListViewCell.swift
//  BGEModularControl_Example
//
//  Created by bge on 2021/7/6.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import BGEModularControl
import Masonry

class ModularListViewCell: BGEModularViewCell {
    var imageView: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel.font = .systemFont(ofSize: 14)
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .darkText
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.mas_makeConstraints { (make) in
            make?.left.and()?.right()?.offset()
            make?.height.offset()(15)
            make?.bottom.offset()(-12)
        }
        
        self.imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(self.imageView)
        self.imageView.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(self.contentView)
            make?.top.offset()(12)
            make?.bottom.equalTo()(self.titleLabel.mas_top)?.offset()(-12)
            make?.width.equalTo()(self.imageView.mas_height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
