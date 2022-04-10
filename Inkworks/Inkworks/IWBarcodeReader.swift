//
//  BarcodeReader.swift
//  Inkworks
//
//  Created by Jamie Duggan on 26/10/2015.
//  Copyright © 2015 Destiny Wireless. All rights reserved.
//

import UIKit;
import AVFoundation;

public protocol IWBarcodeReaderDelegate {
    func receiveBarcode(_ code: String);
}

open class IWBarcodeReader: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    fileprivate var _delegate : IWBarcodeReaderDelegate? = nil;
    
    fileprivate var _session : AVCaptureSession? = nil;
    fileprivate var _device : AVCaptureDevice? = nil;
    
    fileprivate var _input : AVCaptureDeviceInput? = nil;
    fileprivate var _output : AVCaptureMetadataOutput? = nil;
    
    open var PrevLayer : AVCaptureVideoPreviewLayer? = nil;
    
    fileprivate var _view : UIView? = nil;
    fileprivate var _hilightView : UIView? = nil;
    
    open func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var hilightViewRect : CGRect = CGRect.zero;
        var barcodeObject : AVMetadataMachineReadableCodeObject? = nil;
        var detectionString : String? = nil;
        let barcodeTypes : Array = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeDataMatrixCode, AVMetadataObjectTypeITF14Code, AVMetadataObjectTypeInterleaved2of5Code];
        
        for metadataobj in metadataObjects {
            let metadata = metadataobj as! AVMetadataObject;
            for type : String in barcodeTypes {
                if metadata.type != type {
                    continue;
                }
                barcodeObject = self.PrevLayer!.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject) as? AVMetadataMachineReadableCodeObject;
                hilightViewRect = barcodeObject!.bounds;
                detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue;
            }
            
            if (detectionString != nil) {
                self._session!.stopRunning();
                if self._delegate != nil {
                    self._delegate!.receiveBarcode(detectionString!);
                }
                if (self._hilightView != nil) {
                    Async.main{
                        self._hilightView!.frame = hilightViewRect;
                        self._hilightView!.isHidden = false;
                    }
                }
            }
        }
    }
    
    open func captureCode(_ view: UIView!, delegate: IWBarcodeReaderDelegate) {
        self.captureCode(view, delegate: delegate, hilightView: nil);
    }
    
    open func captureCode(_ view : UIView!, delegate: IWBarcodeReaderDelegate, hilightView: UIView?) {
        self._session = AVCaptureSession();
        self._delegate = delegate;
        self._device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo);
        if (self._device == nil) {
            return;
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(focusCamera));
        if (view.gestureRecognizers != nil && view.gestureRecognizers!.count > 0) {
            for i in (view.gestureRecognizers!.count-1)...0 {
                view.removeGestureRecognizer(view.gestureRecognizers![i]);
            }
        }
        view.addGestureRecognizer(tap);
        
        self._hilightView = hilightView;
        do {
            if self._device != nil {
                try self._input = AVCaptureDeviceInput(device: self._device);
                self._session!.addInput(self._input);
            }
        } catch {
            self._input = nil;
            NSLog("Error initiating input device");
        }
        
        self._output = AVCaptureMetadataOutput();
        self._output?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main);
        self._session?.addOutput(self._output);
        self._output?.metadataObjectTypes = self._output?.availableMetadataObjectTypes;
        
        self._view = view;
        self.PrevLayer = AVCaptureVideoPreviewLayer(session: self._session!);
        self.PrevLayer?.frame = self._view!.bounds;
        self.PrevLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        self._view?.layer.addSublayer(self.PrevLayer!);
        
        self._session!.startRunning();
    }
    
    open func focusCamera(_ sender : UITapGestureRecognizer) {
        if (self._device == nil || self._view == nil) {
            return;
        }
        do {
            try self._device!.lockForConfiguration();
        } catch _ {
            return;
        }
        if (self._device!.isFocusModeSupported(.autoFocus)) {
            self._device!.focusMode = .autoFocus;
        } else {
            if (self._device!.isFocusPointOfInterestSupported) {
                self._device!.focusPointOfInterest = sender.location(in: self._view);
                if (self._device!.isFocusModeSupported(.locked)) {
                    self._device!.focusMode = .locked;
                }
            }
        }
        
        self._device!.unlockForConfiguration();
    }
    
    open func resetOrientation () {
        if (self.PrevLayer == nil) {
            return;
        }
        if (self.PrevLayer!.connection == nil) {
            return;
        }
        let conn : AVCaptureConnection = self.PrevLayer!.connection;
        //let ori = UIDevice.currentDevice().orientation;
        let ori = UIApplication.shared.statusBarOrientation;
        switch ori {
        case .portrait:
            conn.videoOrientation = .portrait;
            break;
        case .landscapeLeft:
            conn.videoOrientation = .landscapeLeft;
            break;
        case .landscapeRight:
            conn.videoOrientation = .landscapeRight;
            break;
        case .portraitUpsideDown:
            conn.videoOrientation = .portraitUpsideDown;
            break;
        default:
            conn.videoOrientation = .portrait;
            break;
        }
        self.PrevLayer!.frame = self._view!.bounds;
        self._view?.layer.bounds = self._view!.bounds;
        self.PrevLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
}
