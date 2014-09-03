//
//  Message.swift
//  AppleChat
//
//  Created by pengyunchou on 14-9-1.
//  Copyright (c) 2014年 swift. All rights reserved.
//

import Foundation
class Message {
    let from:String
    let incoming: Bool
    let text: String
    let sentDate: NSDate
    
    init(from :String,incoming: Bool, text: String, sentDate: NSDate) {
        self.from=from
        self.incoming = incoming
        self.text = text
        self.sentDate = sentDate
    }
}