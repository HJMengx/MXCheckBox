//
//  MXCheckBoxButton.swift
//  MXCheckBox
//
//  Created by mx on 2017/3/5.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

enum MXCheckButtonOperationType{
    case expand
    case shrink
}

protocol MXCheckBoxButtonDelegate {
    func checkBoxButton(_ checkBoxButton : MXCheckBoxButton,type : MXCheckButtonOperationType)
}

class MXCheckBoxButton: UIView {
    
    //是否处于展开位置
    var isExpand : Bool = false
    
    var delegate : MXCheckBoxButtonDelegate!
    //最外圈的圆
    fileprivate var outsideCircleLayer : CAShapeLayer!
    //倒数第二圈的圆
    fileprivate var secondCircleLayer : CAShapeLayer!
    //内圈圆
    fileprivate var insideCircleLayer : CAShapeLayer!
    //垂直线条
    fileprivate var verticalLayer : CAShapeLayer!
    //水平线条
    fileprivate var horizontalLayer : CAShapeLayer!
    //动画
    fileprivate var horizontalAnimation : CABasicAnimation!
    
    fileprivate var verticalAnimation : CABasicAnimation!
    
    //回收动画
    fileprivate var horizontalShrinkAnimation : CABasicAnimation!
    
    fileprivate var verticalShrinkAnimation : CABasicAnimation!
    
    //最外圈和第二圈动画效果一样
    fileprivate var outsideAnimation : CAKeyframeAnimation!
    
    fileprivate var insideCircleAnimation : CAKeyframeAnimation!
    
    fileprivate var isAddInsideCircleAnimation : Bool = false
    
    //回收动画
    fileprivate var outsideShrinkAnimation : CAKeyframeAnimation!
    
    fileprivate var insideCircleShrinkAnimation : CAKeyframeAnimation!
    
    var completion : (()->Void)!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initSubLayers()
        
        self.initAnimations()
        
        //添加手势
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(MXCheckBoxButton.checkBoxClicked)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: initialize
    private func initSubLayers(){
        //最外圈的圆
        self.outsideCircleLayer = CAShapeLayer()
        
        self.outsideCircleLayer.frame = self.bounds
        
        let outsideCirclePath = UIBezierPath.init(arcCenter: CGPoint.init(x: self.frame.size.width / 2, y: self.frame.size.width / 2), radius: self.frame.size.width / 2, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        
        self.outsideCircleLayer.path = outsideCirclePath.cgPath
     
        self.outsideCircleLayer.strokeColor = colorWith(red: 252, green: 68, blue: 130).cgColor
        
        self.outsideCircleLayer.lineWidth = 2
        
        self.outsideCircleLayer.fillColor = UIColor.white.cgColor
        
        //第二圈的圆
        self.secondCircleLayer = CAShapeLayer()
        
        self.secondCircleLayer.frame = CGRect.init(x: 3, y: 3, width: self.frame.size.width - 6 , height: self.frame.size.width - 6)
        
        let secondCirclePath = UIBezierPath.init(arcCenter: CGPoint.init(x: self.secondCircleLayer.frame.size.width / 2, y:self.secondCircleLayer.frame.size.width / 2), radius: self.secondCircleLayer.frame.size.width / 2, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        
        self.secondCircleLayer.path = secondCirclePath.cgPath
        
        self.secondCircleLayer.strokeColor = colorWith(red: 252, green: 68, blue: 130).cgColor
        
        self.secondCircleLayer.lineWidth = 1
        
        self.secondCircleLayer.fillColor = UIColor.white.cgColor
        
        //最内圈的圆,给Frame
        self.insideCircleLayer = CAShapeLayer()
        
        self.insideCircleLayer.frame = CGRect.init(x: 6, y: 6, width: self.frame.size.width - 12, height: self.frame.size.width  - 12)
        //
        let insideCirclePath = UIBezierPath.init(arcCenter: CGPoint.init(x: self.insideCircleLayer.frame.size.width / 2, y:self.insideCircleLayer.frame.size.width / 2), radius: self.insideCircleLayer.frame.size.width / 2, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        
        self.insideCircleLayer.path = insideCirclePath.cgPath
        
        self.insideCircleLayer.lineWidth = 1
        
        self.insideCircleLayer.strokeColor = colorWith(red: 252, green: 68, blue: 130).cgColor
        
        self.insideCircleLayer.fillColor = colorWith(red: 252, green: 68, blue: 130).cgColor
        
        self.layer.addSublayer(self.insideCircleLayer)
        
        //垂直直线
        self.verticalLayer = CAShapeLayer.init()
        
        //设置frame才能设置旋转点
        self.verticalLayer.frame = CGRect.init(x: self.frame.size.width / 2 - 2, y: 10, width: 4, height: self.frame.size.width - 20)
        
        let verticalPath = UIBezierPath.init()
        
        verticalPath.move(to: CGPoint.init(x: 2,y: 0))
        
        verticalPath.addLine(to: CGPoint.init(x: 2, y: self.frame.size.width - 20))
        
        self.verticalLayer.path = verticalPath.cgPath
        
        self.verticalLayer.strokeColor = UIColor.white.cgColor
        
        self.verticalLayer.cornerRadius = 2
        
        self.verticalLayer.lineWidth = 4
        
        self.verticalLayer.masksToBounds = true
        
        self.layer.addSublayer(self.verticalLayer)
        
        //水平直线
        self.horizontalLayer = CAShapeLayer()
        
        horizontalLayer.frame = CGRect.init(x: 10, y: self.frame.size.width / 2 - 2, width: self.frame.size.width - 20, height: 4)
        
        let horizontalPath = UIBezierPath.init()
        
        horizontalPath.move(to: CGPoint.init(x: 0, y: 2))
        
        horizontalPath.addLine(to: CGPoint.init(x: self.frame.size.width - 20, y: 2))
        
        self.horizontalLayer.path = horizontalPath.cgPath
        
        self.horizontalLayer.strokeColor = UIColor.white.cgColor
        
        self.horizontalLayer.lineWidth = 4
        
        self.horizontalLayer.cornerRadius = 2
        
        self.horizontalLayer.masksToBounds = true
        
        self.layer.addSublayer(self.horizontalLayer)
    }
    
    private func initAnimations(){
        //初始化动画
        //垂直线动画
        self.verticalAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        
        self.verticalAnimation.fromValue = angle(value: 0)
        
        self.verticalAnimation.toValue = angle(value: 450.0)
        
        self.verticalAnimation.repeatCount = 0.0
        
        self.verticalAnimation.autoreverses = false
        
        self.verticalAnimation.duration = 1
        
        self.verticalAnimation.fillMode = kCAFillModeForwards
        
        self.verticalAnimation.isRemovedOnCompletion = false
        //水平线动画
        self.horizontalAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        
        self.horizontalAnimation.fromValue = angle(value: 0)
        
        self.horizontalAnimation.toValue = angle(value: 360.0)
        
        self.horizontalAnimation.repeatCount = 0.0
        
        self.horizontalAnimation.autoreverses = false
        
        self.horizontalAnimation.duration = 0.75
        
        self.horizontalAnimation.fillMode = kCAFillModeForwards
        
        self.horizontalAnimation.isRemovedOnCompletion = false
        //最内圈圆动画
        
        self.insideCircleAnimation = CAKeyframeAnimation.init(keyPath: "path")
        
        self.insideCircleAnimation.values = [
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.insideCircleLayer.frame.size.width / 2, y:self.insideCircleLayer.frame.size.width / 2), radius: self.insideCircleLayer.frame.size.width / 2, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true).cgPath,
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.insideCircleLayer.frame.size.width / 2, y:self.insideCircleLayer.frame.size.width / 2), radius: self.insideCircleLayer.frame.size.width / 2 - 3, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true).cgPath,
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.insideCircleLayer.frame.size.width / 2, y:self.insideCircleLayer.frame.size.width / 2), radius: 4500, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true).cgPath]

        self.insideCircleAnimation.keyTimes = [0,0.4,1]
        
        self.insideCircleAnimation.autoreverses = false
        
        self.insideCircleAnimation.duration = 1
        
        self.insideCircleAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionDefault)]
        
        self.insideCircleAnimation.fillMode = kCAFillModeForwards
        
        self.insideCircleAnimation.calculationMode = kCAAnimationLinear
        
        self.insideCircleAnimation.isRemovedOnCompletion = false
        
        //外圈圆动画
        self.outsideAnimation = CAKeyframeAnimation.init(keyPath: "opacity")
        
        self.outsideAnimation.values = [0,0.5,0.0]
        
        self.outsideAnimation.keyTimes = [0,0.4,1]
        
        self.outsideAnimation.autoreverses = false
        
        self.outsideAnimation.duration = 0.5
        
        self.outsideAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionDefault)]
        
        self.outsideAnimation.fillMode = kCAFillModeForwards
        
        self.outsideAnimation.calculationMode = kCAAnimationLinear
        
        self.outsideAnimation.isRemovedOnCompletion = false
        
        //*********************************************************************
        //shrink Animation
        self.outsideShrinkAnimation = CAKeyframeAnimation.init(keyPath: "opacity")
        
        self.outsideShrinkAnimation.values = [0,0.5,0.0]
        
        self.outsideShrinkAnimation.keyTimes = [0,0.4,1]
        
        self.outsideShrinkAnimation.autoreverses = false
        
        self.outsideShrinkAnimation.duration = 0.5
        
        self.outsideShrinkAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionDefault)]
        
        self.outsideShrinkAnimation.fillMode = kCAFillModeForwards
        
        self.outsideShrinkAnimation.calculationMode = kCAAnimationLinear
        
        self.outsideShrinkAnimation.isRemovedOnCompletion = false
        
        //vertical Shrink
        self.verticalShrinkAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        
        self.verticalShrinkAnimation.fromValue = angle(value: 450.0)
        
        self.verticalShrinkAnimation.toValue = angle(value: 0)
        
        self.verticalShrinkAnimation.repeatCount = 0.0
        
        self.verticalShrinkAnimation.autoreverses = false
        
        self.verticalShrinkAnimation.duration = 1
        
        self.verticalShrinkAnimation.fillMode = kCAFillModeForwards
        
        self.verticalShrinkAnimation.isRemovedOnCompletion = false
        
        //horizantol shrink
        self.horizontalShrinkAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        
        self.horizontalShrinkAnimation.fromValue = angle(value: 360.0)
        
        self.horizontalShrinkAnimation.toValue = angle(value: 0.0)
        
        self.horizontalShrinkAnimation.repeatCount = 0.0
        
        self.horizontalShrinkAnimation.autoreverses = false
        
        self.horizontalShrinkAnimation.duration = 0.75
        
        self.horizontalShrinkAnimation.fillMode = kCAFillModeForwards
        
        self.horizontalShrinkAnimation.isRemovedOnCompletion = false
        
        
        //insideCircle shrink
        self.insideCircleShrinkAnimation = CAKeyframeAnimation.init(keyPath: "path")
        
        self.insideCircleShrinkAnimation.values = [
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.insideCircleLayer.frame.size.width / 2, y:self.insideCircleLayer.frame.size.width / 2), radius: 4500, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true).cgPath,
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.insideCircleLayer.frame.size.width / 2, y:self.insideCircleLayer.frame.size.width / 2), radius: self.insideCircleLayer.frame.size.width / 2 - 3, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true).cgPath,
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.insideCircleLayer.frame.size.width / 2, y:self.insideCircleLayer.frame.size.width / 2), radius: self.insideCircleLayer.frame.size.width / 2, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true).cgPath
        ]
        
        self.insideCircleShrinkAnimation.keyTimes = [0,0.5,1]
        
        self.insideCircleShrinkAnimation.autoreverses = false
        
        self.insideCircleShrinkAnimation.duration = 1.5
        
        self.insideCircleShrinkAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut),CAMediaTimingFunction.init(name: kCAMediaTimingFunctionDefault)]
        
        self.insideCircleShrinkAnimation.fillMode = kCAFillModeForwards
        
        self.insideCircleShrinkAnimation.calculationMode = kCAAnimationLinear
        
        self.insideCircleShrinkAnimation.isRemovedOnCompletion = false

        //*********************************************************************
        //设置垂直动画的代理为本身以及Value
        self.verticalAnimation.delegate = self
        self.verticalAnimation.setValue("verticalExpandAnimation", forKey: "identifier")
        self.verticalShrinkAnimation.delegate = self
        self.verticalShrinkAnimation.setValue("verticalShrinkAnimation", forKey: "identifier")
        //外圈圆动画
        self.outsideAnimation.delegate = self
        self.outsideAnimation.setValue("outsideCircleExpandAnimation", forKey: "identifier")
        //内圈圆
        self.insideCircleAnimation.delegate = self
        self.insideCircleAnimation.setValue("insideCircleExpandAnimation", forKey: "identifier")
        self.insideCircleShrinkAnimation.delegate = self
        self.insideCircleShrinkAnimation.setValue("InsideshrinkAnimation", forKey: "identifier")
    }
    //MARK: Action
    func checkBoxClicked(){
        //动画过程禁止操作
        guard !self.isExpand else {
            return
        }
        
        if !self.isExpand {
            //展开动画
            self.notificationDelegate(type: .expand)
        }else{
            //不执行,已经展开
            
        }
        self.isExpand = !self.isExpand
    }
    
    private func notificationDelegate(type : MXCheckButtonOperationType){
        if self.delegate != nil {
            self.delegate.checkBoxButton(self, type: type)
        }
    }
    
    //MARK: Animation
    func expandAnimation(completion : @escaping ()->Void){
        
        //添加外面两圈圆
        self.layer.addSublayer(self.outsideCircleLayer)
        self.layer.addSublayer(self.secondCircleLayer)
        //保存completion
        self.completion = completion
        //执行动画
        self.outsideCircleLayer.add(self.outsideAnimation, forKey: "outsideCircleExpandAnimation")
        self.secondCircleLayer.add(self.outsideAnimation, forKey: "outsideCircleExpandAnimation")
    }
    
    func shrinkAnimation(){
        //首先添加Inside
        self.insideCircleLayer.add(self.insideCircleShrinkAnimation, forKey: "InsideshrinkAnimation")
    }
}

extension MXCheckBoxButton : CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        switch anim.value(forKey: "identifier") as! String {
        case "verticalExpandAnimation":
            self.insideCircleLayer.add(self.insideCircleAnimation, forKey: "insideCircleExpandAnimation")
            self.horizontalLayer.opacity = 0.0
            self.verticalLayer.opacity = 0.0
            break
        case "outsideCircleExpandAnimation":
            //会调用两次
            if !self.isAddInsideCircleAnimation {
                
                self.isAddInsideCircleAnimation = !self.isAddInsideCircleAnimation
                
                self.verticalLayer.add(self.verticalAnimation, forKey: "verticalExpandAnimation")
                
                self.horizontalLayer.add(self.horizontalAnimation, forKey: "horizontalExpandAnimation")
            }
            break
            
        case "insideCircleExpandAnimation":
            //所有动画完成后调用
            self.completion()
            //设置没有添加过动画
            self.isAddInsideCircleAnimation = false
            //去除outsideCircleLayer
            self.outsideCircleLayer.removeFromSuperlayer()
            self.secondCircleLayer.removeFromSuperlayer()
            break
            
        case "InsideshrinkAnimation":
            //直线显示
            self.horizontalLayer.opacity = 1.0
            self.verticalLayer.opacity = 1.0
            //添加其他动画
            self.horizontalLayer.add(self.horizontalShrinkAnimation, forKey: "horizontalShrinkAnimation")
            self.verticalLayer.add(self.verticalShrinkAnimation, forKey: "verticalShrinkAnimation")
            break
        case "verticalShrinkAnimation":
            //所有动画完成
            self.removeAllAnimations()
            //设置可以点击
            self.isExpand = false
            break
            
        default:
            
            break
        }
    }
    
    private func removeAllAnimations(){
        self.outsideCircleLayer.removeAllAnimations()
        self.secondCircleLayer.removeAllAnimations()
        self.insideCircleLayer.removeAllAnimations()
        self.horizontalLayer.removeAllAnimations()
        self.verticalLayer.removeAllAnimations()
    }
}
