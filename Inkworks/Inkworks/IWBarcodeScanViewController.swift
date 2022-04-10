//
//  IWBarcodeScanViewController.swift
//  Inkworks
//
//  Created by Jamie Duggan on 26/10/2015.
//  Copyright © 2015 Destiny Wireless. All rights reserved.
//

import UIKit

open class IWBarcodeScanViewController: UIViewController, IWBarcodeReaderDelegate {

    fileprivate var _codeString : String? = nil;
    
    fileprivate var _delegate : IWNotesView? = nil;
    
    @IBOutlet open var backButton : UIButton?;
    @IBOutlet open var rescanButton : UIButton?;
    @IBOutlet open var acceptButton : UIButton?;
    @IBOutlet open var barcodeLabel : UILabel?;
    @IBOutlet open var hilightView : UIView?;
    @IBOutlet open var cameraView : UIView?;
    
    fileprivate var _barcodeScanner : IWBarcodeReader? = nil;
    
    public convenience init(nibName:String?, bundle nibBundleOrNil: Bundle?, delegate: IWNotesView) {
        self.init(nibName: nibName, bundle:nibBundleOrNil);
        self._delegate = delegate;
    }
    
    open func setDelegate(_ del: IWNotesView) {
        self._delegate = del;
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }

    public convenience init?(coder aDecoder: NSCoder, delegate: IWNotesView) {
        self.init(coder:aDecoder);
        self._delegate = delegate;
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad();
        self.cameraView!.layer.masksToBounds = true;
        self.hilightView?.isHidden = true;
        self.hilightView?.layer.backgroundColor = UIColor.clear.cgColor;
        self.hilightView?.layer.borderWidth = 2;
        self.hilightView?.layer.borderColor = UIColor.red.cgColor;
        self.hilightView?.backgroundColor = UIColor.clear;
        
        self._barcodeScanner = IWBarcodeReader();
        self._barcodeScanner!.captureCode(cameraView!, delegate: self, hilightView: self.hilightView!);
        //Async.main(after:0.1) {
            self._barcodeScanner!.resetOrientation();
        //}
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil);
        self._barcodeScanner!.resetOrientation();
    }
    
    open func orientationChanged () {
        self._barcodeScanner!.resetOrientation();
        self._barcodeScanner!.PrevLayer!.frame = self.cameraView!.bounds;
        let frame = self.cameraView!.layer.bounds;
        self.cameraView!.frame = frame;
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self._barcodeScanner!.resetOrientation();
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        //self._barcodeScanner!.resetOrientation();
    }
    
    open func receiveBarcode(_ code: String) {
        self._codeString = code;
        self.barcodeLabel!.text = "Barcode Found: \(code)";
        self.barcodeLabel!.isHidden = false;
        self.rescanButton!.isHidden = false;
        self.acceptButton!.isHidden = false;
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        self._barcodeScanner!.resetOrientation();
        self._barcodeScanner!.PrevLayer!.frame = self.cameraView!.bounds;
        let frame = self.cameraView!.layer.bounds;
        self.cameraView!.frame = frame;
    }

    @IBAction open func backButtonPressed (_ button: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction open func rescanButtonPressed (_ button: UIButton) {
        self.hilightView!.isHidden = true;
        self.hilightView!.frame = CGRect.zero;
        self.barcodeLabel!.isHidden = true;
        self.rescanButton!.isHidden = true;
        self.acceptButton!.isHidden = true;
        self.cameraView!.layer.sublayers?.first?.removeFromSuperlayer();
        
        self._barcodeScanner!.captureCode(self.cameraView!, delegate: self, hilightView: self.hilightView!);
        self._barcodeScanner!.resetOrientation();
    }
    
    @IBAction open func acceptButtonPressed (_ button: UIButton) {
        if (self._delegate != nil) {
            self._delegate!.text = self._codeString!;
            self._delegate!.textColor = UIColor.red;
            self._delegate!.scanned = true;
        }
        self.dismiss(animated: true, completion: nil);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
