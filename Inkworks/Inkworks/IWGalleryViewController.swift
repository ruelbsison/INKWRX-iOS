//
//  IWGalleryViewController.swift
//  Inkworks
//
//  Created by Jamie Duggan on 10/11/2015.
//  Copyright © 2015 Destiny Wireless. All rights reserved.
//

import UIKit
import Photos

open class IWGalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver {

    @IBOutlet open var galleryView : UICollectionView!;
    @IBOutlet open var backButton : UIButton!;
    @IBOutlet open var headerLabel : UILabel!;
    
    
    open var galleryImages : [PHAsset] = [PHAsset]();
    open var formPhotos : NSMutableArray = NSMutableArray();
    open var attachedGalleryImages : NSMutableArray = NSMutableArray();
    open var attachedFormPhotos : NSMutableArray = NSMutableArray();
    //public var updateTimer : NSTimer;
    open var formId : Int = -1;
    open var photoImageManager : PHCachingImageManager? = nil;
    
    fileprivate let imageTypeImages : [[UIImage]] = [[UIImage(named: "bar_icon_camera.png")!, UIImage(named: "bar_icon_attach_active.png")!], [UIImage(named: "bar_icon_gallery.png")!, UIImage(named: "bar_icon_attach_active.png")!]];
    
    fileprivate var imageCache : [NSValue: UIImage] = [NSValue: UIImage]();
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction open func backButtonPressed () {
        IWInkworksService.getInstance().embeddingView = nil;
        self.dismiss(animated: true, completion: nil);
    }

    open override func viewWillAppear(_ animated: Bool) {
        self.formId = IWInkworksService.getInstance().currentViewedForm.FormId;
        //self.formPhotos = IWInkworksService.getInstance().getProcessor().formPhotos;
        super.viewWillAppear(animated);
    }
    
    open func updateHeader() {
        headerLabel.text = "Attach Images(\(self.attachedFormPhotos.count + self.attachedGalleryImages.count) item\((self.attachedFormPhotos.count + attachedGalleryImages.count) == 1 ? "" : "s") attached)";
    }
    
    open func refreshGallery() {
        Async.main {
            self.galleryView.reloadData();
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        
        let options : PHFetchOptions = PHFetchOptions();
        options.includeAssetSourceTypes = [.typeCloudShared, .typeUserLibrary];
        
        let assets = PHAsset.fetchAssets(with: .image, options: options);
        self.galleryImages = [PHAsset]();
        let status = PHPhotoLibrary.authorizationStatus();
        if (status != PHAuthorizationStatus.authorized || assets.count == 0) {
            
            self.galleryView!.reloadData();
            
            self.updateHeader();
            
            return;
        }
        for i in 0...assets.count - 1 {
            self.galleryImages.append(assets[i] as! PHAsset);
        }
        
        self.photoImageManager = PHCachingImageManager();
        
        let phOptions : PHImageRequestOptions = PHImageRequestOptions();
        phOptions.isNetworkAccessAllowed = true;
        phOptions.resizeMode = .exact;
        phOptions.deliveryMode = .highQualityFormat;
        
        self.photoImageManager!.startCachingImages(for: self.galleryImages, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: phOptions);
        self.formPhotos = IWInkworksService.getInstance().currentProcessor!.formPhotos!;
        self.attachedGalleryImages = IWInkworksService.getInstance().currentProcessor!.attachedGalleryImages;
        self.attachedFormPhotos = IWInkworksService.getInstance().currentProcessor!.attachedFormPhotos;
        PHPhotoLibrary.shared().register(self);
        self.galleryView!.reloadData();
        
        self.updateHeader();
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        IWInkworksService.getInstance().embeddingView = nil;
        PHPhotoLibrary.shared().unregisterChangeObserver(self);
        super.viewDidDisappear(true);
    }
    
    open func photoLibraryDidChange(_ changeInstance: PHChange) {
        let options : PHFetchOptions = PHFetchOptions();
        options.includeAssetSourceTypes = [.typeCloudShared, .typeUserLibrary];
        
        let assets = PHAsset.fetchAssets(with: .image, options: options);
        self.galleryImages = [PHAsset]();
        for i in 0...assets.count - 1 {
            self.galleryImages.append(assets[i] as! PHAsset);
        }
        self.galleryView!.reloadData();
    }
    
    open func photoLibraryChanged (_ changeInfo: PHChange!) {
        self.galleryView!.reloadData();
    }
    
    //MARK: - Collection View
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2;
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 1) {
            let item = galleryImages[indexPath.row];
            let isSelected = attachedGalleryImages.contains(item);
            if (isSelected) {
                if (IWInkworksService.getInstance().embeddingView != nil) {
                    IWInkworksService.getInstance().embeddingView!.setImageFromAsset(item);
                    self.dismiss(animated: true, completion: nil);
                } else {
                    attachedGalleryImages.remove(item);
                    if (IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.count > 0) {
                        for i in (0...IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.count - 1).reversed() {
                            let tabImg : IWTabletImageView = IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.object(at: i) as! IWTabletImageView;
                            if (tabImg.attachedAsset == nil) {
                                continue;
                            }
                            if (tabImg.attachedAsset!.localIdentifier != item.localIdentifier) {
                                continue;
                            }
                            tabImg.removeClicked(false);
                        }
                    }
                }
                
            } else {
                attachedGalleryImages.add(item);
                if (IWInkworksService.getInstance().embeddingView != nil) {
                    IWInkworksService.getInstance().embeddingView!.setImageFromAsset(item);
                    self.dismiss(animated: true, completion: nil);
                }
            }
            self.galleryView.reloadItems(at: [indexPath]);
            self.updateHeader();
        } else {
            let uuid = formPhotos[indexPath.row] as! UUID;
            let isSelected = attachedFormPhotos.contains(uuid);
            if (isSelected) {
                if (IWInkworksService.getInstance().embeddingView != nil) {
                    IWInkworksService.getInstance().embeddingView!.setImageFromUUID(uuid);
                    self.dismiss(animated: true, completion: nil);
                } else {
                    attachedFormPhotos.remove(uuid);
                    if (IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.count > 0) {
                        for i in (0...IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.count - 1).reversed() {
                            let tabImg = IWInkworksService.getInstance().currentProcessor!.embeddedPhotos.object(at: i) as! IWTabletImageView;
                            if (tabImg.attachedUUID == nil) {
                                continue;
                            }
                            if (tabImg.attachedUUID!.uuidString != uuid.uuidString) {
                                continue;
                            }
                            tabImg.removeClicked(false);
                        }
                    }
                }
            } else {
                attachedFormPhotos.add(uuid);
                if (IWInkworksService.getInstance().embeddingView != nil) {
                    IWInkworksService.getInstance().embeddingView!.setImageFromUUID(uuid);
                    self.dismiss(animated: true, completion: nil);
                }
            }
            
            self.galleryView.reloadItems(at: [indexPath]);
            self.updateHeader();
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return formPhotos.count;
        default:
            return galleryImages.count;
        }
    }


    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var pathToImage : String? = nil;
        var image : UIImage? = nil;
        
        if (indexPath.section == 1) {
            //gallery
            let item = galleryImages[indexPath.row];
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! IWImageViewCell;
            let isSelected = attachedGalleryImages.contains(item);
            cell.imageTypeIcon!.image = imageTypeImages[1][(isSelected ? 1 : 0)];
            cell.imageTypeIcon!.alpha = isSelected ? 1.0 : 0.5;
            let phOptions : PHImageRequestOptions = PHImageRequestOptions();
            phOptions.isNetworkAccessAllowed = true;
            phOptions.resizeMode = .exact;
            phOptions.deliveryMode = .highQualityFormat;
            self.photoImageManager!.requestImage(for: item, targetSize: CGSize(width: 500,height: 500), contentMode: .aspectFit, options: phOptions, resultHandler: {image, options in
                cell.imageView!.image = image;
            });
            
            let phFastOptions : PHImageRequestOptions = PHImageRequestOptions();
            phOptions.isNetworkAccessAllowed = true;
            phOptions.resizeMode = .fast;
            phOptions.deliveryMode = .fastFormat;
            self.photoImageManager!.requestImage(for: item, targetSize: CGSize(width: 500,height: 500), contentMode: .aspectFit, options: phFastOptions, resultHandler: {image, options in
                cell.imageView!.image = image;
            });
            return cell;
        } else {
            //camera
            pathToImage = IWFileSystem.getFormPhotoPath(withId: formId, andUUID: formPhotos.object(at: indexPath.row) as! UUID);
            let isSelected = attachedFormPhotos.contains(formPhotos[indexPath.row]);
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! IWImageViewCell;
            cell.imageTypeIcon!.image = imageTypeImages[0][(isSelected ? 1 : 0)];
            if (imageCache[NSValue(nonretainedObject: pathToImage)] != nil) {
                cell.imageView!.image = imageCache[NSValue(nonretainedObject: pathToImage!)];
                cell.loadedImage = formPhotos.object(at: indexPath.row) as! UUID;
                cell.loadedURL = nil;
            } else {
                image = UIImage(contentsOfFile: pathToImage!);
                cell.imageView!.image = image;
                cell.loadedImage = formPhotos.object(at: indexPath.row) as! UUID;
                cell.loadedURL = nil;
                imageCache[NSValue(nonretainedObject: pathToImage!)] = image;
            }
            cell.imageTypeIcon!.alpha = isSelected ? 1.0 : 0.5;
            return cell;
        }
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionHeader) {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "galleryImagesHeader", for: indexPath) as! IWGalleryHeader;
            switch indexPath.section {
            case 0:
                header.headerLabel!.text = "Form Photos";
                break;
            default:
                header.headerLabel!.text = "Gallery Images";
                break;
            }
            return header;
        }
        return UICollectionReusableView();
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
