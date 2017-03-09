//
//  MXCheckBoxView.swift
//  MXCheckBox
//
//  Created by mx on 2017/3/5.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

fileprivate let size = CGSize.init(width: 66, height: 66)
class MXCheckBoxView: NSObject {
    /*
    * 按钮的背景颜色
    */
    var buttonBackgroundColor : UIColor!
    /*
    * 展开后的背景颜色
    */
    var allbackgroundColor : UIColor!
    
    var delegate : MXCheckBoxViewDelegate!
    /*
     * 必须赋值，拓展按钮的显示
    */
    var items : [String]!
    
    weak var parentView : UIView!
    
    //ParentView会强引用
    fileprivate weak var checkButton : MXCheckBoxButton!
    
    fileprivate weak var checkItemsBoxView : MXItemsCheckView!
    
    init(items : [String],parentView : UIView) {
        super.init()
        
        //注册屏幕改变方向通知
        NotificationCenter.default.addObserver(self, selector: #selector(MXCheckBoxView.orientationHasChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.items = items
        self.parentView = parentView
        self.initSubViews()
    }
    
    
    private func initSubViews(){
        //在右下角实现
        //实例化SubViews
        //Button
        self.checkButton = MXCheckBoxButton.init(frame:CGRect.init(x: self.parentView.frame.size.height - size.height, y: self.parentView.frame.size.width - size.width, width: size.width, height: size.height))
        
        self.checkButton.delegate = self
        //CheckItems
        self.checkItemsBoxView = MXItemsCheckView.init(frame: CGRect.init(x: screenWidth / 4, y: screenHeight / 4, width: screenWidth / 2, height: screenHeight / 2))
        
        self.checkItemsBoxView.itemsDelegate = self
        self.checkItemsBoxView.dataSource = self
    }
    func orientationHasChange(){
        //改变方向了
        switch UIDevice.current.orientation {
        case .portraitUpsideDown,.portrait:
            self.checkButton.frame = CGRect.init(x: self.parentView.frame.size.width - size.width, y: self.parentView.frame.size.height - size.height, width: size.width, height: size.height)
            break
        default:
            self.checkButton.frame = CGRect.init(x: self.parentView.frame.size.width - size.height, y: self.parentView.frame.size.height - size.width, width: size.width, height: size.height)
            break
        }
    }
    
    /*
     * 显示控件
     */
    func show(){
        if self.parentView != nil {
            self.parentView = parentView!
            self.parentView!.addSubview(self.checkButton)
            //验证动画
        }else{
            //直接通过Window来添加
            
        }
    }
    
}

//MARK: dataSource
extension MXCheckBoxView : MXCheckBoxViewDataSource {
    func numberOfItems() -> Int {
        return self.items.count
    }
    
    func itemFor(checkBoxView: MXItemsCheckView, row: Int) -> String {
        return self.items[row]
    }
}

//MARK: delegate
extension MXCheckBoxView : MXCheckBoxButtonDelegate,MXItemsCheckViewDelegate{
   
    func itemsCheck(_ itemsView: MXItemsCheckView, type: MXItemsCheckViewOperationType, with at: Int?) {
        //通知代理
        switch type {
        case .clickItem:
            //通知代理跳转
            if self.delegate != nil {
                //关闭动画
                self.checkItemsBoxView.closeItemsAnimation { [weak self] ()->Void in
                    self?.checkItemsBoxView.removeFromSuperview()
                    self?.checkButton.shrinkAnimation()
                }
                //位置
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    self.delegate.checkBox(checkBoxView: self, didSelect: at!)
                })
            }
            break
        default:
            //close
            //执行另一个动画
            self.checkItemsBoxView.closeItemsAnimation(completion: { [weak self] ()->Void in
                self?.checkItemsBoxView.removeFromSuperview()
                //执行收缩动画
                self?.checkButton.shrinkAnimation()
            })
            break
        }
    }
    
    func checkBoxButton(_ checkBoxButton: MXCheckBoxButton, type: MXCheckButtonOperationType) {
        switch type {
        case .expand:
            //张开
            self.checkButton.expandAnimation(completion: { [weak self] ()->Void in
                self?.parentView.addSubview((self?.checkItemsBoxView)!)
                //执行动画
                self?.checkItemsBoxView.loadItemsAnimation()
            })
            break
        default:
            //shrink
            break
        }
    }
}

