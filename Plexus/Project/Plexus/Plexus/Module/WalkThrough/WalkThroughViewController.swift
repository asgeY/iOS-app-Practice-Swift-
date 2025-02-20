//
//  WalkThroughViewController.swift
//  Plexus
//
//  Created Anik on 16/8/19.
//  Copyright © 2019 A7Studio. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import UIKit
import TweenController

class WalkThroughViewController: UIViewController, WalkThroughViewProtocol, TutorialViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var buttonsContainerView: UIView!
    @IBOutlet var pageControl: UIPageControl!
    
    private var hasAppeared = false
    private var tweenController: TweenController!
    private var scrollView: UIScrollView!
    
	var presenter: WalkThroughPresenterProtocol?

	override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAppeared {
            hasAppeared = true
            
            let (tc, scrollView) = TutorialBuilder.buildWithContainerViewController(self)
            self.tweenController = tc
            self.scrollView = scrollView
            self.scrollView.delegate = self
        }
    }

    private func updatePageControl() {
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / containerView.frame.width))
    }
}

extension WalkThroughViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tweenController.update(progress: Double(scrollView.twc_horizontalPageProgress))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControl()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updatePageControl()
        }
    }
}
