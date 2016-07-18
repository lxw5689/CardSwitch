//
//  ViewController.swift
//  Demo
//
//  Created by xiangwenlai on 16/7/16.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class CardSwithLayout: UICollectionViewLayout {
    
    var offsetGap: CGFloat = 60
    var visibleCnt: Int = 3
    var transYFactor: Int = 12
    
    var attributeArr: [UICollectionViewLayoutAttributes] = []
    var translation: CGPoint = CGPoint.zero
    var isDragging: Bool = false
    var deletedItem: Bool = false
    
    override func prepare() {
        self.attributeArr.removeAll()
        let cnt: Int = (self.collectionView?.numberOfItems(inSection: 0))!
        for i in 0 ..< cnt {
            var attribute: UICollectionViewLayoutAttributes!
            if i >= self.attributeArr.count {
                attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
                attributeArr.append(attribute!)
            } else {
                attribute = self.attributeArr[i]
            }
            attribute.size = CGSize(width: 300, height: 300)
            attribute.center = CGPoint(x: (self.collectionView?.bounds.width)! / 2, y: (self.collectionView?.bounds.height)! / 2)
            attribute.zIndex = -(i + 1)
            
            var idx = min(i, (visibleCnt - 1))
            let trany = idx * transYFactor
            let scale = CGFloat(1 - CGFloat(idx) / CGFloat((visibleCnt - 1)) * 0.06)
            var transform3D = CATransform3DMakeTranslation(0, CGFloat(trany), 0)
            transform3D = CATransform3DScale(transform3D, scale, scale, 1)
            attribute?.transform3D = transform3D
            if i >= visibleCnt {
                attribute?.isHidden = true
            }
            
            if isDragging {
                if i == 0 {
                    attribute.transform3D = CATransform3DTranslate(transform3D, translation.x, translation.y, 1)
                } else {
                    if i < visibleCnt {
                        idx = i//min(i, DemoFlowLayout.visibleCnt - 1)
                        let sl = min(fabs(translation.x) / offsetGap, 1.0)
                        let ty = (CGFloat(idx) - CGFloat(1.0 * sl)) * CGFloat(transYFactor)
                        let scal = CGFloat(1 - CGFloat(CGFloat(idx) - 1 * sl) / CGFloat(visibleCnt - 1) * 0.06)
                        transform3D = CATransform3DMakeTranslation(0, ty, 0)
                        transform3D = CATransform3DScale(transform3D, scal, scal, 1)
                        attribute.transform3D = transform3D
                    }
                    
                    if (i == visibleCnt) && (fabs(translation.x)) > 0 {
                        attribute.isHidden = false
                    }
                }
            }
        }
    }
    
    func endPanGesture() {
        let cnt: Int = min((visibleCnt + 1), attributeArr.count)
        for i in 0 ..< cnt {
            let attribute = attributeArr[i]
            attribute.size = CGSize(width: 300, height: 300)
            attribute.center = CGPoint(x: (self.collectionView?.bounds.width)! / 2, y: (self.collectionView?.bounds.height)! / 2)
            attribute.zIndex = -(i + 1)
            
            let idx = min(i, (visibleCnt - 1))
            let trany = idx * transYFactor
            let scale = CGFloat(1 - CGFloat(idx) / CGFloat((visibleCnt - 1)) * 0.06)
            var transform3D = CATransform3DMakeTranslation(0, CGFloat(trany), 0)
            transform3D = CATransform3DScale(transform3D, scale, scale, 1)
            attribute.transform3D = transform3D
            if i >= visibleCnt {
                attribute.isHidden = true
            }
        }
    }
    
    func updatePosition(x: CGPoint) {
        self.translation = x
        self.invalidateLayout()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var arr: [UICollectionViewLayoutAttributes] = []
        for tempAttr in attributeArr {
            if rect.intersects(tempAttr.frame) {
                arr.append(tempAttr)
            }
        }
        
        return arr
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute: UICollectionViewLayoutAttributes? = attributeArr[indexPath.item!]
        
        return attribute
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: 300, height: 300)
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if itemIndexPath.item == 0 && attributeArr.count > 0 && deletedItem {
            let att = attributeArr[0]
            att.center.x = translation.x < 0 ? -300 : 600
            return att
        }
        return nil
    }
    
}

class DemoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(image: UIImage?) {
        imageView.image = image
    }
}

class ViewController: UICollectionViewController {
    
    var imageNames = ["1", "2", "3", "4","1", "2", "3", "4"]

    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = CardSwithLayout()
        self.collectionView?.collectionViewLayout = layout
        self.collectionView?.backgroundColor = UIColor.white()
    }

    @IBAction func panGestureAction(_ sender: AnyObject) {
        let panGesture: UIPanGestureRecognizer = sender as! UIPanGestureRecognizer
        let point = panGesture.translation(in: panGesture.view)
        let layout = self.collectionView?.collectionViewLayout as! CardSwithLayout
        var updatePos = true
        layout.deletedItem = false
        
        switch panGesture.state {
            case .began:
                layout.isDragging = true
                break
            case .changed:
                break
            case .ended:
                layout.isDragging = false
                if fabs(point.x) > layout.offsetGap {
                    layout.deletedItem = true
                    self.collectionView?.performBatchUpdates({
                        self.imageNames.remove(at: 0)
                        let indexPath = IndexPath(item: 0, section: 0)
                        self.collectionView?.deleteItems(at: [indexPath])
                        }, completion: { (finish) in
                            
                    })
                } else {
                    updatePos = false
                    self.collectionView?.performBatchUpdates({
                         layout.endPanGesture()
                        }, completion: { (finish) in
                            
                    })
                }
                break
            case .cancelled:
                layout.isDragging = false
                break
            default:
                break
        }
        if updatePos {
            layout.updatePosition(x: point)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: DemoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DemoCell", for: indexPath) as! DemoCell
        
        cell.setImage(image: UIImage(named: imageNames[indexPath.item!]))
        return cell
    }

}

