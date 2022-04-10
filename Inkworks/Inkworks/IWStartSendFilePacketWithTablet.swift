//
//  IWStartSendFilePacketWithTablet.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWStartSendFilePacketWithTablet: IWSecureObject {
    open var FileName : String = "";
    open var MaxPackets : Int = 0;
    open var BlockSize : Int = 0;
    open var FileSize : Int = 0;
    
    public override init() {
        super.init();
        self.FunctionName = "startsendfilepacketwithtablet";
    }
    
    public convenience init(userName: String, password: String, fileName : String, maxPackets : Int = 0, blockSize : Int = 0, fileSize : Int = 0) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
        self.FileName = fileName;
        self.MaxPackets = maxPackets;
        self.BlockSize = blockSize;
        self.FileSize = fileSize;
    }
    
    internal override func GetXmlFields() -> String {
        var ret : String = "";
        ret += "    <filename>\(FileName)</filename>\n";
        ret += "    <maxpackets>\(MaxPackets)</maxpackets>\n";
        ret += "    <blocksize>\(BlockSize)</blocksize>\n";
        ret += "    <filesize>\(FileSize)</filesize>\n";
        return ret;
    }
}
