//
//  SettingViewController.swift
//  AppleChat
//
//  Created by pengyunchou on 14-8-26.
//  Copyright (c) 2014年 swift. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    var usernameField:UITextField?
    var serverIpField:UITextField?
    var confirmButton:UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor=UIColor.whiteColor()
        self.usernameField=UITextField(frame: CGRect(x:10, y: 44+30, width: self.view.frame.size.width-20, height: 40))
        self.usernameField!.backgroundColor=UIColor.lightGrayColor()
        self.usernameField!.textAlignment=NSTextAlignment.Center
        self.usernameField!.placeholder="Your name"
        self.usernameField!.layer.cornerRadius=5;
        self.usernameField!.text="小p"
        self.view.addSubview(self.usernameField!)
    
        self.serverIpField=UITextField(frame: CGRect(x:10, y: 44+30+45, width: self.view.frame.size.width-20, height: 40))
        self.serverIpField!.backgroundColor=UIColor.lightGrayColor()
        self.serverIpField!.textAlignment=NSTextAlignment.Center
        self.serverIpField!.placeholder="server ip"
        self.serverIpField!.layer.cornerRadius=5;
        self.serverIpField!.text="192.168.2.87"
        self.view.addSubview(self.serverIpField!)
        
        self.confirmButton=UIButton(frame: CGRect(x: 10, y:44+30+45+45 , width: self.view.frame.size.width-20, height: 40))
        self.confirmButton!.backgroundColor=UIColor.lightGrayColor()
        self.confirmButton!.setTitle("确定", forState: UIControlState.Normal)
        self.confirmButton!.addTarget(self, action: "confirmBtnClicked", forControlEvents: UIControlEvents.TouchUpInside)
        self.confirmButton!.layer.cornerRadius=5;
        self.view.addSubview(self.confirmButton)
    }
    
    func confirmBtnClicked(){
        var messageViewController=MessageViewController()
        messageViewController.serverIp=self.serverIpField!.text
        messageViewController.nickname=self.usernameField!.text
        self.navigationController.pushViewController(messageViewController, animated: true)
    }
}

