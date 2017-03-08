//
//  MXItemsChecksView.swift
//  MXCheckBox
//
//  Created by mx on 2017/3/5.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

fileprivate let itemHeight = 40
fileprivate let itemGap = 5

enum MXItemsCheckViewOperationType{
    case close
    case clickItem
}

protocol MXItemsCheckViewDelegate {
    func itemsCheck(_ itemsView : MXItemsCheckView,type : MXItemsCheckViewOperationType,with at: Int?)
}

class MXItemsCheckView: UIScrollView {
    //当前可用的items
    var availableItems : Int = 0
    //上一次移动倍数
    var formerIndex : Int = 0
    //总共有多少需要显示
    var allItems : Int = 0
    //正在使用的items
    var unavaliableItems : [UIButton] = [UIButton]()
    //关闭View
    var closeView : UIView!
    //关闭线
    var closeLeftLayer : CAShapeLayer!
    
    var closeRightLayer : CAShapeLayer!
    
    fileprivate var contentLayer : CAShapeLayer!
    //加载动画
    fileprivate var contentLoadAnimation : CAKeyframeAnimation!
    
    fileprivate var closeLeftLoadAnimation : CABasicAnimation!
    
    fileprivate var closeRightLoadAnimation : CABasicAnimation!
    //关闭动画
    fileprivate var contentCloseAnimation : CAKeyframeAnimation!
    
    fileprivate var closeLeftCloseAnimation : CABasicAnimation!
    
    fileprivate var closeRightCloseAnimation : CABasicAnimation!
    
    //block
    var completion : (()->Void)!
    //代理
    var itemsDelegate : MXItemsCheckViewDelegate!
    
    var dataSource : MXCheckBoxViewDataSource! {
        didSet{
            //获取数据
            let numbers = self.dataSource.numberOfItems()
            //获取所有要显示的
            self.allItems = numbers
            
            //当前能显示的最大数量
            let maxShow = (Int(self.frame.size.height) - numbers * itemGap) / (itemHeight)
            
            //当前显示的最后一个位置
            self.availableItems = maxShow
            
            if numbers <= maxShow {
                self.contentSize = self.bounds.size
            }else{
                self.contentSize = CGSize.init(width: self.bounds.size.width, height: CGFloat(numbers * (itemHeight + itemGap) + itemGap))
            }
            
            //复用
            //创建Button
            for index in 0..<numbers {
                //没设置Frame
                let y = index * (itemHeight + itemGap) + itemGap
                
                let button = UIButton.init(frame: CGRect.init(x: itemGap, y: y, width: Int(self.frame.size.width) - 2 * itemGap, height: itemHeight))
                
                //计算位置
                button.titleLabel?.textAlignment = .center
                
                button.setTitle(self.dataSource.itemFor(checkBoxView: self, row: index), for: .normal)
                
                button.alpha = 0
                
                button.setTitleColor(colorWith(red: 252, green: 68, blue: 130), for: .normal)
                
                button.addTarget(self, action:#selector(MXItemsCheckView.selectItem(item:)), for: .touchUpInside)
                
                self.unavaliableItems.append(button)
            }
        }
    }
    
    
    override init(frame : CGRect){
        super.init(frame: frame)
        //初始化
        self.closeView = UIView.init(frame: CGRect.init(x: self.frame.size.width - 17, y: 2, width: 16, height: 16))
        
        self.closeView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(MXItemsCheckView.close)))
        //设置代理
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        //Initialize
        self.initSubLayers()
        self.initAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: Init
    private func initSubLayers(){
        //ContentLayer
        self.contentLayer = CAShapeLayer()
        
        self.contentLayer.frame = self.bounds
        
        //path
        //目标path
        let contentPath = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: self.contentLayer.bounds.size.width, height: 4))
        
        self.contentLayer.path = contentPath.cgPath
        
        self.contentLayer.strokeColor = UIColor.white.cgColor
        
        self.contentLayer.fillColor = UIColor.white.cgColor
        
        self.contentLayer.cornerRadius = 4
        
        self.contentLayer.masksToBounds = true
        
        self.layer.addSublayer(self.contentLayer)
        
        //closeLeftLayer
        self.closeLeftLayer = CAShapeLayer()
        
        self.closeLeftLayer.frame = CGRect.init(x: 2, y:self.closeView.bounds.size.width / 2 - 1, width: 12, height: 2)
        
        let closeLeftPath = UIBezierPath.init()
        
        closeLeftPath.move(to: CGPoint.init(x: 0, y: 1))
        
        closeLeftPath.addLine(to: CGPoint.init(x: self.closeLeftLayer.frame.size.width, y: 1))
        
        self.closeLeftLayer.path = closeLeftPath.cgPath
        
        self.closeLeftLayer.strokeColor = colorWith(red: 252, green: 68, blue: 130).cgColor
        
        self.closeLeftLayer.lineWidth = 2
        
        self.closeLeftLayer.cornerRadius = 1
        
        self.closeLeftLayer.masksToBounds = true
        
        self.closeView.layer.addSublayer(self.closeLeftLayer)
        
        //closeRightLayer
        
        self.closeRightLayer = CAShapeLayer.init()
        
        self.closeRightLayer.frame = CGRect.init(x: self.closeView.bounds.size.width / 2 - 1, y: 2, width: 2, height: 12)
        
        let closeRightPath = UIBezierPath.init()
        
        closeRightPath.move(to: CGPoint.init(x: 1, y: 0))
        
        closeRightPath.addLine(to: CGPoint.init(x: 1, y: self.closeRightLayer.frame.size.height))
        
        self.closeRightLayer.path = closeRightPath.cgPath
        
        self.closeRightLayer.strokeColor = colorWith(red: 252, green: 68, blue: 130).cgColor

        self.closeRightLayer.lineWidth = 2
        
        self.closeRightLayer.cornerRadius = 1
        
        self.closeRightLayer.masksToBounds = true
        
        self.closeView.layer.addSublayer(self.closeRightLayer)
        
        //设置旋转
        self.closeView.transform = self.closeView.transform.rotated(by: CGFloat(angle(value: 45.0)))
    }
    
    private func initAnimations(){
        //load Animation
        //contentAnimation
        self.contentLoadAnimation = CAKeyframeAnimation.init(keyPath: "path")
        
        self.contentLoadAnimation.values = [
        UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: self.contentLayer.bounds.size.width, height: 4)).cgPath,
        UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: self.contentLayer.bounds.size.width, height: 2)).cgPath,
        UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: self.contentLayer.bounds.size.width, height: self.contentLayer.bounds.size.height)).cgPath]
        
        self.contentLoadAnimation.keyTimes = [0,0.4,1]
        
        self.contentLoadAnimation.autoreverses = false
        
        self.contentLoadAnimation.duration = 1
        
        self.contentLoadAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionDefault)]
        
        self.contentLoadAnimation.fillMode = kCAFillModeForwards
        
        self.contentLoadAnimation.calculationMode = kCAAnimationLinear
        
        self.contentLoadAnimation.isRemovedOnCompletion = false
        
        //leftLayerAnimation
        
        self.closeLeftLoadAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        
        self.closeLeftLoadAnimation.fromValue = 0.0
        
        self.closeLeftLoadAnimation.toValue = 1.0
        
        self.closeLeftLoadAnimation.duration = 0.5
        
        self.closeLeftLoadAnimation.isRemovedOnCompletion = false
        
        self.closeLeftLoadAnimation.autoreverses = false
        
        self.closeLeftLoadAnimation.fillMode = kCAFillModeForwards
        
        //RightLayerAnimation
        self.closeRightLoadAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        
        self.closeRightLoadAnimation.fromValue = 0.0
        
        self.closeRightLoadAnimation.toValue = 1.0
        
        self.closeRightLoadAnimation.duration = 0.75
        
        self.closeRightLoadAnimation.isRemovedOnCompletion = false
        
        self.closeRightLoadAnimation.autoreverses = false
        
        self.closeRightLoadAnimation.fillMode = kCAFillModeForwards
        
        //**************************************************
        //close Animation
        self.closeRightCloseAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        self.closeRightCloseAnimation.fromValue = 1
        self.closeRightCloseAnimation.toValue = 0
        self.closeRightCloseAnimation.duration = 0.5
        self.closeRightCloseAnimation.isRemovedOnCompletion = false
        self.closeRightCloseAnimation.autoreverses = false
        self.closeRightCloseAnimation.fillMode = kCAFillModeForwards
        
        //LeftCloseAnimation
        self.closeLeftCloseAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        self.closeLeftCloseAnimation.fromValue = 1
        self.closeLeftCloseAnimation.toValue = 0
        self.closeLeftCloseAnimation.duration = 0.75
        self.closeLeftCloseAnimation.isRemovedOnCompletion = false
        self.closeLeftCloseAnimation.autoreverses = false
        self.closeLeftCloseAnimation.fillMode = kCAFillModeForwards
        
        //ContentLayerCloseAnimation
        self.contentCloseAnimation = CAKeyframeAnimation.init(keyPath: "path")
        self.contentCloseAnimation.values = [
            UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: self.contentLayer.bounds.size.width, height: self.contentLayer.bounds.size.height)).cgPath,
            UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: self.contentLayer.bounds.size.width, height: 2)).cgPath,
            UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: self.contentLayer.bounds.size.width, height: 4)).cgPath
            ]
        
        self.contentCloseAnimation.keyTimes = [0,0.4,1]
        
        self.contentCloseAnimation.autoreverses = false
        
        self.contentCloseAnimation.duration = 1
        
        self.contentCloseAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionDefault)]
        
        self.contentCloseAnimation.fillMode = kCAFillModeForwards
        
        self.contentCloseAnimation.calculationMode = kCAAnimationLinear
        
        self.contentCloseAnimation.isRemovedOnCompletion = false
        
        //**************************************************
        //设置代理
        self.contentLoadAnimation.delegate = self
        self.contentLoadAnimation.setValue("contentLoad", forKey: "identifier")
        self.closeLeftCloseAnimation.delegate = self
        self.closeLeftCloseAnimation.setValue("closeLeftClose", forKey: "identifier")
        self.contentCloseAnimation.delegate = self
        self.contentCloseAnimation.setValue("contentClose", forKey: "identifier")
    }
    
    //MARK: Action
    func close(){
        //禁止操作
        self.isUserInteractionEnabled = false
        self.notificateDelegate(type: .close,with : nil)
    }
    
    func selectItem(item : UIButton){
        //禁止操作
        self.isUserInteractionEnabled = false
        self.notificateDelegate(type: .clickItem, with: self.unavaliableItems.index(of: item)!)
    }
    
    private func notificateDelegate(type : MXItemsCheckViewOperationType,with : Int?){
        if self.itemsDelegate != nil {
            if type == .clickItem {
                //选中了某一个Item
                self.itemsDelegate.itemsCheck(self, type: .clickItem, with: with!)
            }else{
                //关闭
                self.itemsDelegate.itemsCheck(self, type: type,with : nil)
            }
        }
    }
    //MARK: Animation
    func loadItemsAnimation(){
        //添加动画
        self.contentLayer.add(self.contentLoadAnimation, forKey: "contentLoad")
        //
    }
    
    func closeItemsAnimation(completion : @escaping ()->Void){
        //保存回调
        self.completion = completion
        //执行动画
        self.closeLeftLayer.add(self.closeLeftCloseAnimation, forKey: "closeLeftClose")
        self.closeRightLayer.add(self.closeRightCloseAnimation, forKey: "closeRightClose")
        //退出按钮按钮
        self.hideAllButtonAnimation()
    }
    
    //隐藏按钮
    func hideAllButtonAnimation(){
        for button in self.unavaliableItems {
            UIView.animate(withDuration: 0.75, animations: { 
                button.alpha = 0
            }, completion: { (isCompletion : Bool) in
                if isCompletion {
                    button.removeFromSuperview()
                }
            })
        }
    }
}

//MARK: ScrollViewDelegate
extension MXItemsCheckView : UIScrollViewDelegate {
    //这个方法不可行
    //滚动时候,用于判断位置
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //获取Y这个位置
        let positionY = scrollView.contentOffset.y
        //禁止向上拖动
        if positionY < 0 {
            scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: false)
            return
        }
        //求出向下移动了多少
        let index = (Int(positionY) - itemGap) / itemHeight
        
        //判断是否需要重用
        //求出Y的坐标
        let y = (index + self.availableItems) * (itemHeight + itemGap) + itemGap
        
        if index > self.formerIndex {
            //向下移动
            //重用最上边的
            //修改Position
            if self.availableItems + 1 < self.allItems{
                self.unavaliableItems[0].removeFromSuperview()
                self.unavaliableItems[0].setTitle(self.dataSource.itemFor(checkBoxView: self, row: index + self.availableItems - 1), for: .normal)
                //设置
                self.unavaliableItems[0].frame = CGRect.init(x: itemGap, y: y, width: Int(self.frame.size.width) - 2 * itemGap, height: itemHeight)
                
                self.availableItems += 1
            }
        }else if index < self.formerIndex{
            //向上移动
            //重用最下边的
            self.unavaliableItems[self.unavaliableItems.count - 1].setTitle(self.dataSource.itemFor(checkBoxView: self, row: self.availableItems - 8 - index), for: .normal)
            self.unavaliableItems[self.unavaliableItems.count - 1].frame = CGRect.init(x: itemGap, y: y, width: Int(self.frame.size.width) - 2 * itemGap, height: itemHeight)
            
            self.availableItems -= 1
        }
        self.formerIndex = index
    }
}



//MARK: AnimationDelegate
extension MXItemsCheckView : CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        switch anim.value(forKey: "identifier") as! String {
        case "contentLoad":
            //添加关闭View动画
            self.addSubview(self.closeView)
            self.closeLeftLayer.add(self.closeLeftLoadAnimation, forKey: "closeLeftLoad")
            self.closeRightLayer.add(self.closeRightLoadAnimation, forKey: "closeRightLoad")
            //添加Button了
            self.addButtonWithAnimation()
            //背景颜色
            if self.backgroundColor == nil {
                self.backgroundColor = UIColor.white
            }
            break
            
        case "closeLeftClose":
            if self.backgroundColor != nil {
                self.backgroundColor = nil
            }
            //关闭
            self.contentLayer.add(self.contentCloseAnimation, forKey: "ContentcloseAnimation")
            //去除关闭VIew
            self.closeView.removeFromSuperview()
            break
            
        case "contentClose":
            //完成了,调用回调函数
            self.completion()
            //删除所有动画
            self.removeAllAnimation()
            //允许操作
            self.isUserInteractionEnabled = true
            break
            
        default:
            break
        }
    }
    
    func addButtonWithAnimation(){
        for button in self.unavaliableItems {
            self.addSubview(button)
            UIView.animate(withDuration: 0.75, animations: {
                button.alpha = 1
            })
        }
    }
    
    func removeAllAnimation(){
        self.contentLayer.removeAllAnimations()
        self.closeLeftLayer.removeAllAnimations()
        self.closeRightLayer.removeAllAnimations()
        //删除回调
        self.completion = nil
    }
}
