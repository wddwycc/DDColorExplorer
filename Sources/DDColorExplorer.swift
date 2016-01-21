//
//  DDColorExplorer.swift
//  DDColorExplorer
//
//  Created by Carrl on 16/1/21.
//  Copyright © 2016年 monk-studio. All rights reserved.
//

import UIKit

protocol DDColorExplorerViewDelegate:class{
    func DDColorExplorerDidDetectColor(color:UIColor)
}
class DDColorExplorerView:UIImageView{
    
    private let picker = UIView(frame: CGRectMake(0, 0, 80, 80))
    private let pickerPresentationLayer = CAShapeLayer()
    var pickerColor:CGColorRef?{
        get{
            return self.pickerPresentationLayer.strokeColor
        }
        set(newValue){
            self.pickerPresentationLayer.strokeColor = newValue
        }
    }
    
    var context:CGContextRef?
    
    let pickerDisappearDuration = 0.6 as Double
    
    
    weak var delegate:DDColorExplorerViewDelegate?
    
    override init(image:UIImage?){
        super.init(image: image)
        self.contentMode = UIViewContentMode.ScaleAspectFit
        self.activateColorExploration()
        if(self.image != nil){
            self.context = self.createARGBBitmapContext(self.image!.CGImage!)
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func activateColorExploration(){
        self.userInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: "colorExplorerHandlePan:")
        let tapGesture = UITapGestureRecognizer(target: self, action: "colorExplorerHandleTap:")
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(tapGesture)
        
        pickerPresentationLayer.frame = self.picker.frame
        self.picker.layer.addSublayer(pickerPresentationLayer)
        let pickerPath = CGPathCreateMutable()
        CGPathAddEllipseInRect(pickerPath, nil, pickerPresentationLayer.frame)
        pickerPresentationLayer.path = pickerPath
        pickerPresentationLayer.fillColor = UIColor.clearColor().CGColor
        pickerPresentationLayer.strokeColor = UIColor.grayColor().CGColor
        pickerPresentationLayer.lineWidth = 10
        
        let centerPointLayer = CAShapeLayer()
        let centerPointLayerPath = CGPathCreateMutable()
        CGPathAddEllipseInRect(centerPointLayerPath, nil, CGRectMake(0, 0, 4, 4))
        centerPointLayer.path = centerPointLayerPath
        centerPointLayer.strokeColor = UIColor.clearColor().CGColor
        centerPointLayer.fillColor = UIColor(white: 172.0/255.0, alpha: 1).CGColor
        centerPointLayer.frame = CGRectMake(80/2 - 2, 80/2 - 2, 4, 4)
        self.picker.layer.addSublayer(centerPointLayer)
        
        self.picker.alpha = 0
        self.addSubview(self.picker)
    }
    func colorExplorerHandlePan(gesture:UIPanGestureRecognizer){
        let locationInImage = self.covertTouchPositionToImagePixelPosition(gesture.locationInView(self))
        let color = self.getPixelColorAtLocation(locationInImage)
        self.pickerColor = color!.CGColor
        if(color != nil){
            self.delegate?.DDColorExplorerDidDetectColor(color!)
        }
        
        switch gesture.state{
        case .Began:
            self.picker.alpha = 1
            self.picker.center = gesture.locationInView(self)
        case .Changed:
            self.picker.center = gesture.locationInView(self)
            
        case .Cancelled, .Ended:
            UIView.animateWithDuration(self.pickerDisappearDuration, animations: { () -> Void in
                self.picker.alpha = 0
            })
        default:
            break
        }
    }
    func colorExplorerHandleTap(gesture:UITapGestureRecognizer){
        if(gesture.state == .Ended){
            let locationInImage = self.covertTouchPositionToImagePixelPosition(gesture.locationInView(self))
            let color = self.getPixelColorAtLocation(locationInImage)
            self.pickerColor = color!.CGColor
            if(color != nil){
                self.delegate?.DDColorExplorerDidDetectColor(color!)
            }

            
            
            self.picker.center = gesture.locationInView(self)
            self.picker.alpha = 1
            UIView.animateWithDuration(self.pickerDisappearDuration, animations: { () -> Void in
                self.picker.alpha = 0
            })
        }
    }
    
    func covertTouchPositionToImagePixelPosition(touchPosition:CGPoint)->CGPoint?{
        let imageSize = CGSizeMake(CGFloat(CGImageGetWidth(self.image!.CGImage)), CGFloat(CGImageGetHeight(self.image!.CGImage)))
        
        let explorerViewSize = self.bounds.size
        let presentationRatio = (imageSize.width / explorerViewSize.width > imageSize.height / explorerViewSize.width) ? (imageSize.width / explorerViewSize.width) : (imageSize.height / explorerViewSize.height)
        let presentationSize = CGSizeMake(imageSize.width / presentationRatio, imageSize.height / presentationRatio)
        

        if(touchPosition.x < (explorerViewSize.width - presentationSize.width)/2 || touchPosition.x > (explorerViewSize.width + presentationSize.width)/2){
            return nil
        }
        if(touchPosition.y < (explorerViewSize.height - presentationSize.height)/2 || touchPosition.y > (explorerViewSize.height + presentationSize.height)/2){
            return nil
        }
        let leftInset = (explorerViewSize.width - presentationSize.width)/2
        let topInset = (explorerViewSize.height - presentationSize.height)/2
        let targetPositionInExplorerView = CGPointMake(touchPosition.x - leftInset, touchPosition.y - topInset)
        
        let positionInImage = CGPointMake(targetPositionInExplorerView.x * presentationRatio, targetPositionInExplorerView.y * presentationRatio)
        
        return positionInImage
    }
    
    
    private func createARGBBitmapContext(inImage: CGImageRef) -> CGContext {
        
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        
        let bitmapBytesPerRow = Int(pixelsWide) * 4

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapData = UnsafeMutablePointer<UInt8>()
        let bitmapInfo = CGImageAlphaInfo.PremultipliedFirst.rawValue
        
        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, bitmapInfo)!
        
        return context
    }
    
    private func getPixelColorAtLocation(point:CGPoint?)->UIColor? {
        if(point == nil){
            return self.backgroundColor
        }
        let inImage:CGImageRef = self.image!.CGImage!
        
        let pixelsWide = CGImageGetWidth(inImage)
        let pixelsHigh = CGImageGetHeight(inImage)
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        CGContextClearRect(context, rect)
        
        CGContextDrawImage(context, rect, inImage)
        
        let data = CGBitmapContextGetData(context)
        let dataType = UnsafePointer<UInt8>(data)
        
        let offset = 4*((Int(pixelsWide) * Int(point!.y)) + Int(point!.x))
        let alphaValue = dataType[offset]
        let redColor = dataType[offset+1]
        let greenColor = dataType[offset+2]
        let blueColor = dataType[offset+3]
        
        let redFloat = CGFloat(redColor)/255.0
        let greenFloat = CGFloat(greenColor)/255.0
        let blueFloat = CGFloat(blueColor)/255.0
        let alphaFloat = CGFloat(alphaValue)/255.0
        
        return UIColor(red: redFloat, green: greenFloat, blue: blueFloat, alpha: alphaFloat)
        
        // When finished, release the context
        // Free image data memory for the context
    }

    
    
}


