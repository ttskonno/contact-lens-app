//
//  ViewController.swift
//  ContactLensApp
//
//  Created by KonnoTatsuki on 6/30/15.
//  Copyright (c) 2015 KonnoTatsuki. All rights reserved.
//

import UIKit
import BubbleTransition

class ViewController: UIViewController,
    UIViewControllerTransitioningDelegate {

    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var remainingDays: UILabel!
    @IBOutlet weak var transitionButton: UIButton!
    
    let transition = BubbleTransition()
    var barHeight: CGFloat = 0.0
    var displayWidth: CGFloat = 0.0
    var displayHeight: CGFloat = 0.0
    var imageNameList: Array <NSString> = []
    var imageList: Array <UIImage!> = []
    var imageView: UIImageView!
    var timer: NSTimer!
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        barHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        displayWidth = self.view.frame.width
        displayHeight = self.view.frame.height
        
        var i = 0
        while (i < 14) {
            let imageName = NSString(format: "images/%d.jpg", i)
            imageNameList.append(imageName)
            imageList.append(setCIColorMonochrome(UIImage(named: imageName as String)!))
            i++
        }
        
        nextPage()
        timerInitialized()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? UIViewController {
            controller.transitioningDelegate = self
            controller.modalPresentationStyle = .Custom
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = transitionButton.center
        transition.bubbleColor = transitionButton.backgroundColor!
        return transition
    }
    
    func nextPage() {
        
        var image: UIImage? = imageList[index]
        var imageWidth: CGFloat = image!.size.width
        var imageHeight: CGFloat = image!.size.height
        var aspect: CGFloat = imageHeight / imageWidth
        let cropRect: CGRect
        let cropRef: CGImageRef
        let cropImage: UIImage?
        let transition: CATransition = CATransition()
        transition.duration = 1.0
        transition.type = kCATransitionFade
        self.view.layer.addAnimation(transition, forKey: kCATransition)
        
        println("index:\(index), width:\(displayWidth), height:\(displayHeight), aspect:\(aspect)")
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: displayHeight, height: displayHeight))
        imageView.layer.position = CGPoint(x: displayWidth/2, y: displayHeight/2)
        imageView.image = cropThumnailImage(image!, w: 500, h: 500)
        
        self.view.addSubview(imageView)
        self.view.bringSubviewToFront(transitionButton)
        self.view.bringSubviewToFront(remainingDays)
        self.view.bringSubviewToFront(remainingLabel)
        
        UIImageView.animateWithDuration(
            10,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: {() ->Void in
                self.imageView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                self.imageView.center = CGPoint(x: self.displayWidth/2+20.0, y: self.displayHeight/2+20.0)
            },
            completion: nil)

        if index < 13 {
            index++
        } else {
            index = 0
        }
    }
    
    func timerInitialized() {
        timer = NSTimer.scheduledTimerWithTimeInterval(5,target: self, selector: Selector("nextPage"), userInfo: nil, repeats: true)
    }
    
    // Cropping an image to thumnail
    func cropThumnailImage(image:UIImage, w: CGFloat, h: CGFloat) ->UIImage {
        
        let origRef = image.CGImage
        let origWidth = CGFloat(CGImageGetWidth(origRef))
        let origHeight = CGFloat(CGImageGetHeight(origRef))
        var resizeWidth: CGFloat = 0.0, resizeHeight: CGFloat = 0
        
        if origWidth < origHeight {
            resizeWidth = w
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = h
            resizeWidth = origWidth * resizeHeight / origHeight
        }
        
        let resizeSize = CGSizeMake(resizeWidth, resizeHeight)
        UIGraphicsBeginImageContext(resizeSize)
        image.drawInRect(CGRectMake(0, 0, resizeWidth, resizeHeight))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cropRect = CGRectMake(CGFloat((resizeWidth-w)/2), CGFloat((resizeHeight-h)/2), CGFloat(w), CGFloat(h))
        let cropRef = CGImageCreateWithImageInRect(resizeImage.CGImage, cropRect)
        let cropImage = UIImage(CGImage: cropRef)
        
        return cropImage!
    }
    
    // Monochrome filter
    func setCIColorMonochrome(image: UIImage) ->UIImage {
        
        let ciImage: CIImage = CIImage(image: image)
        let ciFilter: CIFilter = CIFilter(name: "CIColorMonochrome")
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: "inputColor")
        ciFilter.setValue(0.8, forKey: "inputIntensity")
        let ciContext: CIContext = CIContext(options: nil)
        let cgimg: CGImageRef = ciContext.createCGImage(ciFilter.outputImage, fromRect: ciFilter.outputImage.extent())
        
        return UIImage(CGImage: cgimg, scale: 1.0, orientation: UIImageOrientation.Up)!
    }
    
    // Gaussian blur filter
    func setCIGaussianBlur(image: UIImage) ->UIImage {
    
        let ciImage: CIImage = CIImage(image: image)
        let ciFilter: CIFilter = CIFilter(name: "CIGaussianBlur")
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        ciFilter.setValue(3, forKey: kCIInputRadiusKey)
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter.setValue(ciFilter.outputImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(CGRect: ciImage.extent()), forKey: "inputRectangle")
        
        return UIImage(CIImage: cropFilter.outputImage)!
    }
}

