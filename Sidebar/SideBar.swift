//
//  SideBar.swift
//  Sidebar
//
//  Created by Admin on 08.07.16.
//  Copyright © 2016 Sviridov. All rights reserved.
//

import UIKit
@objc protocol SideBarDelegate{
    func SideBarControlDidSelectRow(indexPath: NSIndexPath)
    optional func sideBarWillClose()
    optional func sideBarWillOpen()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
    
    let barWidth:CGFloat = 150.0
    let sideBarTableViewTopInsert:CGFloat = 64.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
    
    var originView:UIView! = nil
    
    var animator:UIDynamicAnimator!
    var delegate:SideBarDelegate?
    var isSideBarOpen:Bool = false
    
    
    override init(){
        super.init()
    }
    
    init(sourseView:UIView, menuItems:Array<String>) {
        super.init()
        originView = sourseView
        sideBarTableViewController.tableData = menuItems
        setupSideBar()
        animator = UIDynamicAnimator(referenceView:originView)
        let showGestureRecogniser:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action:"handleSwipe:")
        showGestureRecogniser.direction = UISwipeGestureRecognizerDirection.Right
        originView.addGestureRecognizer(showGestureRecogniser)
        let hideGestureRecogniser:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action:"handleSwipe:")
        hideGestureRecogniser.direction = UISwipeGestureRecognizerDirection.Left
        originView.addGestureRecognizer(hideGestureRecogniser)
    }
    func setupSideBar(){
        sideBarContainerView.frame = CGRectMake(-barWidth - 1, originView.frame.origin.y, barWidth, originView.frame.size.height)
        sideBarContainerView.backgroundColor = UIColor.clearColor()
        sideBarContainerView.clipsToBounds = false
        
        originView.addSubview(sideBarContainerView)
        let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = sideBarContainerView.bounds
        sideBarContainerView.addSubview(blurView)
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
        sideBarTableViewController.tableView.scrollsToTop = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInsert, 0,0,0)
        
        sideBarTableViewController.tableView.reloadData()
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        
    }
    
    func handleSwipe(recogniser:UISwipeGestureRecognizer) {
        if recogniser.direction == UISwipeGestureRecognizerDirection.Left{
            showSideBar(false)
            delegate?.sideBarWillClose()
        }else{
            showSideBar(true)
            delegate?.sideBarWillOpen()
        }
    }
    func showSideBar(shouldOpen:Bool){
    animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        let gravityX:CGFloat = (shouldOpen) ? 0.5:-0.5
        let magnitude:CGFloat = (shouldOpen) ? 20:-20
        let boundaryX:CGFloat = (shouldOpen) ? barWidth:-barWidth-1
        
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items:[sideBarContainerView])
        gravityBehavior.gravityDirection = CGVectorMake(gravityX, 0)
        animator.addBehavior(gravityBehavior)
        let collisionBehaviour:UICollisionBehavior = UICollisionBehavior(items:[sideBarContainerView])
        collisionBehaviour.addBoundaryWithIdentifier("sideBarBoundary", fromPoint: CGPointMake(boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
        animator.addBehavior(collisionBehaviour)
        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sizeBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude =  magnitude
        animator.addBehavior(pushBehavior)
        
        let sidebarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sizeBarContainerView])
        sidebarBehavior.elasticity = 0.3
        animator.addBehavior(sidebarBehavior)
    }
    
    func SideBarControlDidSelectRow(indexPath: NSIndexPath) {
        delegate!.sideBarDidSelectButtonAtIndex(indexPath.row)
    }
    
}
