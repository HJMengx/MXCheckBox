//
//  MXCheckBoxViewDataSource.swift
//  MXCheckBox
//
//  Created by mx on 2017/3/5.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

protocol MXCheckBoxViewDataSource {
    func numberOfItems()->Int
    func itemFor(checkBoxView : MXItemsCheckView,row : Int)->String
}
