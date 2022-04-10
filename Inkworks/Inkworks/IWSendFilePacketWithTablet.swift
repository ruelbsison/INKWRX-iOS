//
//  IWSendFilePacketWithTablet.swift
//  Inkworks
//
//  Created by Jamie Duggan on 02/03/2015.
//  Copyright (c) 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWSendFilePacketWithTablet: IWSecureObject {
    open var FileData : String = "";
    open var PacketIndex : Int = -1;
    
    public override init() {
        super.init();
        self.FunctionName = "sendfilepacketwithtablet";
    }
    
    public convenience init(userName: String, password: String, fileData: String, packetIndex: Int = -1) {
        self.init();
        self.Username = userName;
        self.PasswordHash = password;
        self.FileData = fileData;
        self.PacketIndex = packetIndex;
    }
    
    internal override func GetXmlFields() -> String {
        var ret : String = "";
        ret += "    <filedata>\(FileData)</filedata>\n";
        ret += "    <packetindex>\(PacketIndex)</packetindex>\n";
        return ret;
    }
}
