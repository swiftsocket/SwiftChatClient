//
//  MessageViewController.swift
//  AppleChat
//
//  Created by pengyunchou on 14-8-27.
//  Copyright (c) 2014年 swift. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController,UITableViewDataSource{
    var serverIp:String=""
    var nickname:String=""
    var clientsocket:TCPClient?
    var toolBar:UIToolbar?
    var messageTableView:UITableView?
    var messages:[Message]=[]
    var textView:UITextView=UITextView(frame: CGRectZero)
    func doInBackground(block:()->()){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            block()
        })
    }
    func alert(msg:String,after:()->(Void)){
        var alertview=UIAlertView(title: "", message: msg, delegate: nil, cancelButtonTitle: nil)
        alertview.show()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3), dispatch_get_main_queue(),{
            alertview.dismissWithClickedButtonIndex(0, animated: true)
            after()
        })
    }
    func sendMessage(msgtosend:NSDictionary){
        var msgdata=NSJSONSerialization.dataWithJSONObject(msgtosend, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var len:Int32=Int32(msgdata.length)
        var data:NSMutableData=NSMutableData(bytes: &len, length: 4)
        self.clientsocket!.send(data: data)
        self.clientsocket!.send(data:msgdata)
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    func disconnect(){
        
    }
    func processMessage(msg:NSDictionary){
        var cmd:String=msg["cmd"] as String
        switch(cmd){
        case "msg":
            self.messages.append(Message(from: msg["from"] as String, incoming: true, text: msg["content"] as String, sentDate: NSDate()))
            self.messageTableView!.reloadData()
        default:
            println(msg)
        }
    }
    override var inputAccessoryView: UIView! {
    get {
        if toolBar == nil {
            toolBar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
            textView.backgroundColor = UIColor(white: 250/255, alpha: 1)

            textView.font = UIFont.systemFontOfSize(17)
            textView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 205/255, alpha:1).CGColor
            textView.layer.borderWidth = 0.5
            textView.layer.cornerRadius = 5
            textView.scrollsToTop = false
            textView.textContainerInset = UIEdgeInsetsMake(4, 3, 3, 3)
            toolBar!.addSubview(textView)
            
            var sendButton = UIButton.buttonWithType(.System) as UIButton
            sendButton.titleLabel.font = UIFont.boldSystemFontOfSize(17)
            sendButton.setTitle("Send", forState: .Normal)
            sendButton.setTitleColor(UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1), forState: .Disabled)
            sendButton.setTitleColor(UIColor(red: 1/255, green: 122/255, blue: 255/255, alpha: 1), forState: .Normal)
            sendButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
            sendButton.addTarget(self, action: "sendAction", forControlEvents: UIControlEvents.TouchUpInside)
            toolBar!.addSubview(sendButton)
            // Auto Layout allows `sendButton` to change width, e.g., for localization.
            textView.setTranslatesAutoresizingMaskIntoConstraints(false)
            sendButton.setTranslatesAutoresizingMaskIntoConstraints(false)
            toolBar!.addConstraint(NSLayoutConstraint(item: textView, attribute: .Left, relatedBy: .Equal, toItem: toolBar, attribute: .Left, multiplier: 1, constant: 8))
            toolBar!.addConstraint(NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: toolBar, attribute: .Top, multiplier: 1, constant: 7.5))
            toolBar!.addConstraint(NSLayoutConstraint(item: textView, attribute: .Right, relatedBy: .Equal, toItem: sendButton, attribute: .Left, multiplier: 1, constant: -2))
            toolBar!.addConstraint(NSLayoutConstraint(item: textView, attribute: .Bottom, relatedBy: .Equal, toItem: toolBar, attribute: .Bottom, multiplier: 1, constant: -8))
            toolBar!.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Right, relatedBy: .Equal, toItem: toolBar, attribute: .Right, multiplier: 1, constant: 0))
            toolBar!.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Bottom, relatedBy: .Equal, toItem: toolBar, attribute: .Bottom, multiplier: 1, constant: -4.5))
        }
        return toolBar!
    }
    }
    func sendAction(){
        var content=textView.text
        var message=["cmd":"msg","content":content]
        self.sendMessage(message)
        textView.text=nil
    }
    func processsocket(){
        self.clientsocket=TCPClient(addr: self.serverIp, port: 9003)
        self.doInBackground({
            var (success,msg)=self.clientsocket!.connect(timeout: 5)
            func readmsg()->NSDictionary?{
                //read 4 byte int as type
                if let data=self.clientsocket!.read(4){
                    if data.count==4{
                        var ndata=NSData(bytes: data, length: data.count)
                        var len:Int32=0
                        ndata.getBytes(&len, length: data.count)
                        if let buff=self.clientsocket!.read(Int(len)){
                            var msgd:NSData=NSData(bytes: buff, length: buff.count)
                            var msgi:NSDictionary=NSJSONSerialization.JSONObjectWithData(msgd, options: .MutableContainers, error: nil) as NSDictionary
                            return msgi
                        }
                    }
                }
                return nil
            }
            if success{
                dispatch_async(dispatch_get_main_queue(), {
                    self.alert("connect success", after: {
                        
                    })
                })
                //send username
                var msgtosend=["cmd":"nickname","nickname":self.nickname]
                self.sendMessage(msgtosend)
                //read message
                while true{
                    if let msg=readmsg(){
                        dispatch_async(dispatch_get_main_queue(), {
                            self.processMessage(msg)
                            })
                    }else{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.disconnect()
                            })
                        break
                    }
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), {
                    self.alert(msg,{
                        (self.navigationController.popViewControllerAnimated(true))
                        return
                        })
                    })
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton=true
        self.view.backgroundColor=UIColor.whiteColor()
        self.messageTableView=UITableView(frame: self.view.bounds)
        self.messageTableView!.dataSource=self
        self.messageTableView!.registerNib(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        self.messageTableView!.rowHeight = UITableViewAutomaticDimension;
        self.messageTableView!.estimatedRowHeight = 44.0;
        self.messageTableView!.keyboardDismissMode = .Interactive
        //self.messageTableView!.separatorStyle = .None
        self.view.addSubview(self.messageTableView)
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIMenuControllerWillHideMenuNotification, object: nil)
        self.processsocket()
        // Do any additional setup after loading the view.
    }
    func keyboardWillShow(n:NSNotification){
        let userInfo = n.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        let insetNewBottom = messageTableView!.convertRect(frameNew, fromView: nil).height
        let insetOld = messageTableView!.contentInset
        let insetChange = insetNewBottom - insetOld.bottom
        let overflow = messageTableView!.contentSize.height - (messageTableView!.frame.height-insetOld.top-insetOld.bottom)
        
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
        let animations: (() -> Void) = {
            if !(self.messageTableView!.tracking || self.messageTableView!.decelerating) {
                // Move content with keyboard
                if overflow > 0 {                   // scrollable before
                    self.messageTableView!.contentOffset.y += insetChange
                    if self.messageTableView!.contentOffset.y < -insetOld.top {
                        self.messageTableView!.contentOffset.y = -insetOld.top
                    }
                } else if insetChange > -overflow { // scrollable after
                    self.messageTableView!.contentOffset.y += insetChange + overflow
                }
            }
        }
        if duration > 0 {
            let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as NSNumber).integerValue << 16))
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: animations, completion: nil)
        } else {
            animations()
        }
    }
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo as NSDictionary!
        let frameNew = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        let insetNewBottom = messageTableView!.convertRect(frameNew, fromView: nil).height
        
        // Inset `tableView` with keyboard
        let contentOffsetY = messageTableView!.contentOffset.y
        messageTableView!.contentInset.bottom = insetNewBottom
        messageTableView!.scrollIndicatorInsets.bottom = insetNewBottom
        // Prevents jump after keyboard dismissal
        if self.messageTableView!.tracking || self.messageTableView!.decelerating {
            messageTableView!.contentOffset.y = contentOffsetY
        }
    }
    
    func keyboardWillHide(n:NSNotification){
        
    }
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{
        return messages.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!{
        var cell:MessageCell=tableView.dequeueReusableCellWithIdentifier("MessageCell") as MessageCell
        var msg=self.messages[indexPath.row]
        cell.configureWithMessage(msg)
        return cell
    }
}
