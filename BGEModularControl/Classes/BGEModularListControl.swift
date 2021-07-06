//
//  BGEModularControl.swift
//  BGEModularControl
//
//  Created by bge on 2021/7/5.
//

import UIKit
import Foundation
import Masonry

@objc public protocol BGEModularControlDataSource: NSObjectProtocol {
    //每行多少个cell(每个cell宽度相等)
    func numberOfItemsPerRow(in modularControl: BGEModularControl) -> Int

    //最大允许多少行cell(超过最大允许行数，加pageControl翻页)
    func maxNumberOfRows(in modularControl: BGEModularControl) -> Int

    //cell的个数(总个数)
    func numberOfItems(in modularControl: BGEModularControl) -> Int

    //cell的高度(宽度和高度并不要求一定是一样的)
    func heightForItem(in modularControl: BGEModularControl) -> CGFloat
   
    //每个cell显示的内容
    func modularControl(_ modularControl: BGEModularControl, cellForItemAt index: Int) -> BGEModularViewCell
}

@objc public protocol BGEModularControlDelegate: NSObjectProtocol {
    @objc optional func modularControl(_ modularControl: BGEModularControl, willDisplayItemAt index: Int)
    @objc optional func modularControl(_ modularControl: BGEModularControl, didDisplayItemAt index: Int)
    @objc optional func modularControl(_ modularControl: BGEModularControl, didSelectItemAt index: Int)
}

public class BGEModularControl: UIView {
    weak public var delegate: BGEModularControlDelegate?
    weak public var dataSource: BGEModularControlDataSource? {
        didSet {
            self.reloadData()
        }
    }
    
    public var pageIndicatorTintColor: UIColor = .lightGray {
        didSet {
            self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        }
    }
    
    public var currentPageIndicatorTintColor: UIColor = .darkGray {
        didSet {
            self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        }
    }
    
    public var scrollEnabled: Bool = true {
        didSet {
            self.collectionView.isScrollEnabled = scrollEnabled
        }
    }
    
    public var numberOfItemsPerRow: Int = 0
    public var maxNumberOfRows: Int = 0
    public var numberOfItems: Int = 0
    public var heightForItem: CGFloat = 0.0
    
    private let pageControlHeight: CGFloat = 10.0//pageControl控件的高度：10
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl.init()
        pageControl.pageIndicatorTintColor = self.pageIndicatorTintColor
        pageControl.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor
        self.addSubview(pageControl)
        pageControl.mas_makeConstraints { (make) in
            make?.left.bottom()?.and()?.right()?.offset()
            make?.height.offset()(pageControlHeight)
        }
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(sender:)), for: .valueChanged)
        
        return pageControl
    }()
    private var flowLayout: BGEModularControlLayout = BGEModularControlLayout.init()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: frame, collectionViewLayout: self.flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        self.insertSubview(collectionView, belowSubview: self.pageControl)
        collectionView.mas_makeConstraints { (make) in
            make?.left.top()?.and()?.right()?.offset()
            if (self.onlyOnePage) {
                make?.bottom.offset()
            } else {
                make?.bottom.offset()(0 - pageControlHeight)
            }
        }
        
        return collectionView
    }()
    
    //控件的宽度，layoutSubviews中获取的self.frame.size.width
    private var viewWidth: CGFloat = 0
    private var numberOfItemPerPage: Int {
        get {
            return self.numberOfItemsPerRow * self.maxNumberOfRows
        }
    }
    private var onlyOnePage: Bool {
        get {
            self.numberOfItems <= self.numberOfItemPerPage
        }
    }
    
    //初始化方法，设置默认属性的值，初始化pageControl控件。由于collectionView的初始化要先指定flowlayout，而flowlayout需要用到数据源dataSource传入的值，所以collectionView的初始化放在了reloadData方法中
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func viewHeight() -> CGFloat {
        var numberOfRows = 0
        
        //一共有多少行
        numberOfRows = (self.numberOfItems + self.numberOfItemsPerRow - 1) / self.numberOfItemsPerRow
        
        //超过最大行数的显示最大行数
        numberOfRows = numberOfRows > self.maxNumberOfRows ? self.maxNumberOfRows : numberOfRows
        
        //超过一页的要加pageControl的高度，只有一页不加
        if (self.onlyOnePage) {
            return CGFloat(numberOfRows) * self.heightForItem
        }
        else {
            return CGFloat(numberOfRows) * self.heightForItem + pageControlHeight
        }
    }
    
    public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
        
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> BGEModularViewCell {
        let indexPath = self.collectionViewIndexPath(with: index)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! BGEModularViewCell
        
        return cell
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        //先通过add一个pageControl触发layoutSubviews，来保存当前view的宽度。初始化flowlayout的时候根据这个宽度来计算cell的宽度。由于这个方法是异步被调用，所以要加一个延时来确保高度设置正确
        self.viewWidth = self.frame.size.width
    }
    
    public func reloadData() {
        //获取datasource回调的各种值，然后通过属性保存，用到的时候不重复调用datasource的回调。给调用者的感觉是回调方法只调用了一次。避免意外
        self.numberOfItemsPerRow = self.dataSource?.numberOfItemsPerRow(in: self) ?? 0
        self.numberOfItems = self.dataSource?.numberOfItems(in: self) ?? 0
        self.maxNumberOfRows = self.dataSource?.maxNumberOfRows(in: self) ?? 0
        self.heightForItem = self.dataSource?.heightForItem(in: self) ?? 0
        
        //判断cell是否只有一页，显示或者隐藏pageControl
        if (self.onlyOnePage) {
            self.pageControl.isHidden = true
        } else {
            self.pageControl.numberOfPages = (self.numberOfItems + self.numberOfItemPerPage - 1) / self.numberOfItemPerPage
            self.pageControl.currentPage = 0
            self.pageControl.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
            self.flowLayout.itemSize = CGSize.init(width: self.viewWidth / CGFloat(self.numberOfItemsPerRow), height: self.heightForItem)
            self.flowLayout.numberOfRows = self.maxNumberOfRows
            self.flowLayout.numberOfItemsPerRow = self.numberOfItemsPerRow
            
            self.collectionView.reloadData()
            
            //reloadData之后显示第一页
            self.collectionView.setContentOffset(.zero, animated: false)
        }
    }
    
    @objc private func pageControlValueChanged(sender: Any) -> () {
        let currentPage = CGFloat(self.pageControl.currentPage)
        self.collectionView.setContentOffset(CGPoint.init(x: self.viewWidth * currentPage, y: 0), animated: true)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //currentPage for pageControl
        if (scrollView.contentOffset.x >= self.viewWidth * CGFloat((self.collectionView.numberOfSections - 1)) || scrollView.contentOffset.x == 0) {
            self.pageControl.currentPage = 0
        }
        else {
            let page = Int(scrollView.contentOffset.x / self.viewWidth)
            self.pageControl.currentPage = page
        }
        
        //循环滚动的实现，在后面加了一个section重复第0个section。
        //允许collectionView的bounces，触底反弹
        if (scrollView.contentOffset.x < 0) {
            self.collectionView.contentOffset = CGPoint.init(x: self.viewWidth * CGFloat((self.collectionView.numberOfSections - 1)), y: 0)
        }
        else if (scrollView.contentOffset.x > scrollView.contentSize.width - self.viewWidth) {
            self.collectionView.contentOffset = .zero
        }
    }
    
    func indexWithCollectionView(indexPath: IndexPath) -> Int {
        var section: Int = 0
        if (indexPath.section < (self.numberOfItems + self.numberOfItemPerPage - 1) / self.numberOfItemPerPage) {
            section = indexPath.section
        }
        let index = section * self.numberOfItemPerPage + indexPath.item
        
        return index
    }
    
    func collectionViewIndexPath(with index: Int) -> IndexPath {
        let itemIndex = index % self.numberOfItemPerPage
        let sectionIndex = index / self.numberOfItemPerPage
        let indexPath = IndexPath.init(item: itemIndex, section: sectionIndex)
        return indexPath
    }
}

extension BGEModularControl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //只有一页的时候不滚动
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        var sections = (self.numberOfItems + self.numberOfItemPerPage - 1) / self.numberOfItemPerPage
        if (!self.onlyOnePage) {
            sections += 1
        }
        
        return sections
    }
    
    //除最后一页外都显示满cell
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == self.numberOfItems / self.numberOfItemPerPage && self.numberOfItems % self.numberOfItemPerPage != 0) {
            return self.numberOfItems % self.numberOfItemPerPage
        } else {
            return self.numberOfItemPerPage
        }
    }
    
    //对外开放的类是JFModularViewCell，所有使用本控件的cell继承此类
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = self.indexWithCollectionView(indexPath: indexPath)
        
        self.delegate?.modularControl?(self, willDisplayItemAt: index)
        
        let cell = self.dataSource?.modularControl(self, cellForItemAt: index)
        
        self.delegate?.modularControl?(self, didDisplayItemAt: index)
        
        return cell ?? UICollectionViewCell.init()
    }
    
    //cell之间默认是没有间距的，如要实现间距在cell内部自己留margin
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    //cell的宽度都一样，由总宽度/cell个数得到；高度是dataSource回调
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize.init(width: self.viewWidth / CGFloat(self.numberOfItemsPerRow), height: self.heightForItem)
    }
    
    //点击选中的delegate回调转发
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = self.indexWithCollectionView(indexPath: indexPath)
        self.delegate?.modularControl?(self, didSelectItemAt: index)
    }
}
