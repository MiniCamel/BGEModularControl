//
//  BGEModularControlLayout.swift
//  BGEModularControl
//
//  Created by bge on 2021/7/5.
//

import UIKit

public class BGEModularControlLayout: UICollectionViewLayout {
    public var numberOfRows: Int = 0//共多少行
    public var numberOfItemsPerRow: Int = 0//每行多少个item
    public var itemSize: CGSize = .zero//cell的大小
    
    override public var collectionViewContentSize: CGSize {
        get {
            let width = CGFloat((self.collectionView?.numberOfSections ?? 0) * self.numberOfItemsPerRow) * self.itemSize.width
            let height = self.itemSize.height * CGFloat(self.numberOfRows)

            return CGSize.init(width: width, height: height)
        }
    }
    
    private var layoutAttributesArray = [UICollectionViewLayoutAttributes]()
    
    //重写方法实现collectionView中每个cell显示的位置计算，UICollectionViewLayoutAttributes.frames
    override public func prepare() {
        super.prepare()
        
        self.layoutAttributesArray.removeAll()
        let sections = Int(self.collectionView?.numberOfSections ?? 0)
        for section: Int in 0..<sections {
            let items = Int(self.collectionView?.numberOfItems(inSection: section) ?? 0)
            for item: Int in 0..<items {
                let indexPath: IndexPath = IndexPath.init(item: item, section: section)

                //除数为0情况的处理
                var originX: CGFloat = 0, originY: CGFloat = 0
                if (self.numberOfItemsPerRow != 0) {
                    originX = self.itemSize.width * CGFloat((item % self.numberOfItemsPerRow)) + CGFloat(section * self.numberOfItemsPerRow) * self.itemSize.width

                    originY = self.itemSize.height * CGFloat((item / self.numberOfItemsPerRow))
                }
                
                let layoutAttributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
                layoutAttributes.frame = CGRect.init(x: originX, y: originY, width: self.itemSize.width, height: self.itemSize.height)
                self.layoutAttributesArray.append(layoutAttributes)
            }
        }
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layoutAttributesArray
    }
}


