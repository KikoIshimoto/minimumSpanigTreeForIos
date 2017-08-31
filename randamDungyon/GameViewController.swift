//
//  GameViewController.swift
//  randamDungyon
//
//  Created by IshimotoKiko on 2016/06/15.
//  Copyright (c) 2016年 IshimotoKiko. All rights reserved.
//

import UIKit
import SpriteKit
struct globalSize
{
    let size = CGSizeMake(360, 640)
}
class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as? SKView
        skView?.showsFPS = true
        skView?.showsNodeCount = true
        let scean = test(size: CGSizeMake(720,1280))
        scean.scaleMode = SKSceneScaleMode.AspectFit
        skView?.presentScene(scean)
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
