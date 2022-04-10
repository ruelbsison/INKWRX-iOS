//
//  IWFinishSendFilePacketWithTablet.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWFinishSendFilePacketWithTablet: IWSecureObject {
    open var FileName : String = "";
    open var MaxPackets : Int = -1;
    
    public override init() {
        super.init();
        self.FunctionName = "finishsendfilepacketwithtablet";
    }
    
    public convenience init(userName: String, password: String, fileName: String, maxPackets: Int = -1) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
        self.FileName = fileName;
        self.MaxPackets = maxPackets;
    }
    
    internal override func GetXmlFields() -> String {
        var ret : String = "";
        ret += "    <filename>\(FileName)</filename>\n";
        ret += "    <maxpackets>\(MaxPackets)</maxpackets>\n";
        return ret;
    }
}
