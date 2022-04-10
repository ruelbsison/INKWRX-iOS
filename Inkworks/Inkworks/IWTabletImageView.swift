//
//  IWTabletImageView.swift
//  Inkworks
//
//  Created by Jamie Duggan on 10/11/2015.
//  Copyright © 2015 Destiny Wireless. All rights reserved.
//

import UIKit
import Photos;
import QuartzCore;

open class IWTabletImageView: UIView {

    open var strokeColor : UIColor = UIColor.black;
    open var fillColor : UIColor = UIColor.clear;
    open var strokeWidth : Float = 0;
    open var cornerRadius : Float = 0;
    
    
    fileprivate let galleryImage : UIImage = UIImage(named: "bar_icon_gallery.png")!;
    fileprivate let photoImage : UIImage = UIImage(named: "bar_icon_camera.png")!;
    fileprivate var removeButton : UIButton? = nil;
    fileprivate var gallImageView : UIImageView? = nil;
    fileprivate var photoImageView : UIImageView? = nil;
    fileprivate var attachedImageView : UIView? = nil;
    fileprivate var attachedImage : UIImage? = nil;
    fileprivate var sourceView : UIView? = nil;
    
    open var attachedUUID : UUID? = nil;
    open var attachedAsset : PHAsset? = nil;
    
    public override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    public convenience init(frame: CGRect, strokeColor: UIColor, fillColor: UIColor, strokeWidth: Float, cornerRadius: Float) {
        self.init(frame: frame);
        self.strokeColor = strokeColor;
        self.fillColor = fillColor;
        self.strokeWidth = strokeWidth;
        self.cornerRadius = cornerRadius;
        self.backgroundColor = UIColor.clear;
        
        self.layer.cornerRadius = CGFloat(cornerRadius);
        self.layer.backgroundColor = fillColor.cgColor;
        self.layer.borderColor = strokeColor.cgColor;
        self.layer.borderWidth = CGFloat(strokeWidth);
        
        self.sourceView = UIView(frame:CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
        self.sourceView!.layer.cornerRadius = CGFloat(cornerRadius);
        self.sourceView!.layer.masksToBounds = true;
        
        //[UIColor colorWithRed:245.0f/255.0f green:189.0f/255.0f blue:71.0f/255.0f alpha:1.0f]
        self.sourceView!.layer.backgroundColor = UIColor(red: 245.0/255.0, green: 189.0/255.0, blue: 71.0/255.0, alpha: 1.0).cgColor;
        //self.sourceView!.layer.backgroundColor = UIColor.yellowColor().CGColor;
        self.sourceView!.layer.borderColor = self.strokeColor.cgColor;
        self.sourceView!.layer.borderWidth = CGFloat(self.strokeWidth);
        //self.sourceView!.backgroundColor = UIColor.yellowColor();
        
        self.gallImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width / 2.0, height: frame.size.height));
        self.gallImageView!.image = galleryImage;
        self.gallImageView!.contentMode = .scaleAspectFit;
        self.gallImageView!.backgroundColor = UIColor.clear;
        self.gallImageView!.isUserInteractionEnabled = true;
        self.gallImageView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(IWTabletImageView.galleryClicked)));
        self.sourceView!.addSubview(self.gallImageView!);
        
        self.photoImageView = UIImageView(frame: CGRect(x: frame.size.width / 2.0, y: 0, width: frame.size.width / 2.0, height: frame.size.height));
        self.photoImageView!.image = photoImage;
        self.photoImageView!.backgroundColor = UIColor.clear;
        self.photoImageView!.contentMode = .scaleAspectFit;
        self.photoImageView!.isUserInteractionEnabled = true;
        self.photoImageView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(IWTabletImageView.cameraClicked)));
        self.sourceView!.addSubview(self.photoImageView!);
        
        self.removeButton = UIButton(frame: CGRect(x: frame.size.width - 20, y: 0, width: 20, height: 20));
        let x = "X";
        self.removeButton!.setTitle(x, for: UIControlState());
        self.removeButton!.setTitle(x, for: .selected);
        self.removeButton!.setTitle(x, for: .highlighted);
        self.removeButton!.setTitle(x, for: .focused);
        self.removeButton!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(IWTabletImageView.removeClicked1)));
        self.removeButton!.backgroundColor = UIColor.white;
        self.removeButton!.setTitleColor(UIColor.red, for: UIControlState());
        self.removeButton!.setTitleColor(UIColor.red, for: .selected);
        self.removeButton!.setTitleColor(UIColor.red, for: .highlighted);
        self.removeButton!.setTitleColor(UIColor.red, for: .focused);
        
        self.removeButton!.isHidden = true;
        
        self.addSubview(self.sourceView!);
        
        self.attachedImageView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
        self.attachedImageView!.backgroundColor = UIColor.clear;
        self.attachedImageView!.layer.cornerRadius = CGFloat(cornerRadius);
        self.attachedImageView!.layer.backgroundColor = UIColor.clear.cgColor;
        self.attachedImageView!.layer.masksToBounds = true;
        self.attachedImageView!.layer.contentsGravity = kCAGravityResizeAspect;
        self.attachedImageView!.isHidden = true;
        
        
        self.addSubview(self.attachedImageView!);
        
        self.addSubview(self.removeButton!);
    }
    
    open func removeClicked1() {
        self.removeClicked(true)
    }
    
    open func removeClicked(_ removeOthers: Bool) {
        if (self.attachedAsset != nil) {
            var remove = true;
            for epo  in IWInkworksService.getInstance().currentProcessor!.embeddedPhotos!.objectEnumerator() {
                let ep : IWTabletImageView = epo as! IWTabletImageView;
                if ep != self {
                    if (ep.attachedAsset == self.attachedAsset) {
                        remove = false;
                        break;
                    }
                }
            }
            if (remove && removeOthers) {
                IWInkworksService.getInstance().currentProcessor!.removeAttachedGalleryImage(self.attachedAsset!);
            }
            IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.remove(self);
        } else if (self.attachedUUID != nil) {
            var remove = true;
            for epo in IWInkworksService.getInstance().currentProcessor!.embeddedPhotos!.objectEnumerator() {
                let ep = epo as! IWTabletImageView;
                if (ep != self) {
                    if (ep.attachedUUID == self.attachedUUID) {
                        remove = false;
                        break;
                    }
                }
            }
            if (remove && removeOthers) {
                IWInkworksService.getInstance().currentProcessor!.removeAttachedFormPhoto(self.attachedUUID!);
            }
            IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.remove(self);
        }
        Async.main{
            self.attachedAsset = nil;
            self.attachedUUID = nil;
            self.attachedImage = nil;
            self.attachedImageView!.layer.contents = nil;
            self.attachedImageView!.isHidden = true;
            self.removeButton!.isHidden = true;
            self.sourceView!.isHidden = false;
        }
    }
    
    open func cameraClicked() {
        IWInkworksService.getInstance().embeddingView = self;
        IWInkworksService.getInstance().mainInstance.performSegue(withIdentifier: "takePhotoSegue", sender: self);
    }
    
    open func galleryClicked() {
        IWInkworksService.getInstance().embeddingView = self;

        let attachImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AttachImageViewController");
        attachImageVC.modalPresentationStyle = .popover;
        attachImageVC.popoverPresentationController!.backgroundColor = UIColor(red: 245.0/255.0, green: 189.0/255.0, blue: 71.0/255.0, alpha: 1.0);
        attachImageVC.popoverPresentationController!.sourceView = IWInkworksService.getInstance().mainInstance.view;
        attachImageVC.popoverPresentationController!.sourceRect = CGRect(x: 0, y: 0, width: 50, height: 50);
        var frame = IWInkworksService.getInstance().mainInstance.view.frame;
        frame.origin.x += 20;
        frame.origin.y += 20;
        frame.size.width -= 40;
        frame.size.height -= 40;
        attachImageVC.view.frame = frame;
        IWInkworksService.getInstance().mainInstance.present(attachImageVC, animated: true, completion: nil);
        
    }
    
    fileprivate func setImage(_ image: UIImage) {
        Async.main{
            self.attachedImage = image;
            self.attachedImageView!.layer.contents = self.attachedImage!.cgImage;
            self.sourceView!.isHidden = true;
            self.attachedImageView!.isHidden = false;
            self.removeButton!.isHidden = false;
        }
    }
    
    open func setImageFromUUID(_ uuid : UUID) {
        self.attachedUUID = uuid;
        let pathToImage = IWFileSystem.getFormPhotoPath(withId: IWInkworksService.getInstance().currentViewedForm.FormId, andUUID: uuid);
        let image = UIImage(contentsOfFile: pathToImage!);
        if (image != nil) {
            self.setImage(image!);
            IWInkworksService.getInstance().currentProcessor!.attachFormPhoto(uuid);
            if (!IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.contains(self)) {
                IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.add(self);
            }
        }
    }
    
    open func setImageFromAsset(_ asset: PHAsset) {
        self.attachedAsset = asset;
        let size = self.frame.size;
        let phOptions : PHImageRequestOptions = PHImageRequestOptions();
        phOptions.isNetworkAccessAllowed = true;
        phOptions.resizeMode = .exact;
        phOptions.deliveryMode = .highQualityFormat;
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFit, options: phOptions, resultHandler: {image, options in
            if (image != nil) {
                self.setImage(image!);
                IWInkworksService.getInstance().currentProcessor!.attachGalleryImage(asset);
                if (!IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.contains(self)) {
                    IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.add(self);
                }
            }
        })
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
