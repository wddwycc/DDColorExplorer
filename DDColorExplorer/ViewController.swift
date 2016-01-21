//
//  ViewController.swift
//  DDColorExplorer
//
//  Created by Carrl on 16/1/21.
//  Copyright © 2016年 monk-studio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let presentationView = UIView(frame: CGRectMake(0, 20, 50, 50))
    
    let labelRed = UILabel(frame: CGRectMake(0, 70, 100, 20))
    let labelGreen = UILabel(frame: CGRectMake(0, 90, 100, 20))
    let labelBlue = UILabel(frame: CGRectMake(0, 110, 100, 20))
    override func viewDidLoad() {
        super.viewDidLoad()
        let explorerView = DDColorExplorerView(image: UIImage(named: "test.png"))
        explorerView.backgroundColor = UIColor.whiteColor()
        explorerView.frame = self.view.frame
        explorerView.delegate = self
        self.view.addSubview(explorerView)
        
        self.presentationView.layer.zPosition = 100
        presentationView.center.x = self.view.center.x
        self.view.addSubview(presentationView)
        
        for member in [labelRed,labelBlue,labelGreen]{
            member.textColor = UIColor.grayColor()
            member.center.x = self.view.center.x
            member.textAlignment = NSTextAlignment.Center
            self.view.addSubview(member)
        }
    }

}
extension ViewController: DDColorExplorerViewDelegate{
    func DDColorExplorerDidDetectColor(color: UIColor) {
        self.presentationView.backgroundColor = color
        self.labelRed.text = "red:\(color.red)"
        self.labelGreen.text = "green:\(color.green)"
        self.labelBlue.text = "blue:\(color.blue)"
    }
}

extension UIColor{
    
    var red: Int{
        return Int(CGColorGetComponents(self.CGColor)[0] * 255.0)
    }
    
    var green: Int{
        return Int(CGColorGetComponents(self.CGColor)[1] * 255.0)
    }
    
    var blue: Int{
        return Int(CGColorGetComponents(self.CGColor)[2] * 255.0)
    }
    
}
