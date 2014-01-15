//
//  AnimatorShowDetailForDismissMHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 08.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "AnimatorShowDetailForDismissMHGallery.h"
#import "MHGalleryOverViewController.h"

@interface AnimatorShowDetailForDismissMHGallery()
@property (nonatomic) CGRect startFrame;
@property (nonatomic,strong)UIView *viewWhite;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic, strong) MHUIImageViewContentViewAnimation *cellImageSnapshot;
@end

@implementation AnimatorShowDetailForDismissMHGallery

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    self.context = transitionContext;
    
    id toViewControllerNC = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UINavigationController *fromViewController = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    MHGalleryImageViewerViewController *imageViewer  = (MHGalleryImageViewerViewController*)fromViewController.visibleViewController;
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UIImage *image;
    UIView *snapShot;
    __block NSNumber *pageIndex;
    for (ImageViewController *imageViewerIndex in imageViewer.pvc.viewControllers) {
        if (imageViewerIndex.pageIndex == imageViewer.pageIndex) {
            pageIndex = @(imageViewerIndex.pageIndex);
            image = imageViewerIndex.imageView.image;
            snapShot = [imageViewerIndex.imageView snapshotViewAfterScreenUpdates:NO];
        }
    }
    
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:fromViewController.view.bounds];
    cellImageSnapshot.image = image;
    [cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(cellImageSnapshot.image.size,fromViewController.view.bounds)];
    
    [imageViewer.pvc.view setHidden:YES];
    
    [toViewControllerNC view].frame = [transitionContext finalFrameForViewController:toViewControllerNC];
    [toViewControllerNC view].alpha = 0;
    
    [containerView insertSubview:[toViewControllerNC view] belowSubview:fromViewController.view];
    [containerView addSubview:cellImageSnapshot];
    [containerView addSubview:snapShot];
    
    UINavigationBar *navigationBar = fromViewController.navigationBar;
    [containerView addSubview:navigationBar];
    
    UIToolbar *descriptionViewBackground = imageViewer.descriptionViewBackground;
    [containerView addSubview:descriptionViewBackground];
    
    UITextView *descriptionView = imageViewer.descriptionView;
    [containerView addSubview:descriptionView];
    
    
    UIToolbar *toolBar = imageViewer.tb;
    [containerView addSubview:toolBar];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.iv.hidden = YES;
        [snapShot removeFromSuperview];
        
        [UIView animateWithDuration:duration animations:^{
            navigationBar.alpha =0;
            descriptionView.alpha =0;
            descriptionViewBackground.alpha =0;
            toolBar.alpha =0;
            
            [toViewControllerNC view].alpha = 1;
            [fromViewController view].alpha =0;
            cellImageSnapshot.frame =[containerView convertRect:self.iv.frame fromView:self.iv.superview];
            cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
        } completion:^(BOOL finished) {
            self.iv.hidden = NO;
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
           
            [[UIApplication sharedApplication] setStatusBarStyle:[MHGallerySharedManager sharedManager].oldStatusBarStyle];
        }];
        
    });
    
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    self.context = transitionContext;
    
    id toViewControllerNC = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UINavigationController *fromViewController = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    MHGalleryImageViewerViewController *imageViewer  = (MHGalleryImageViewerViewController*)fromViewController.visibleViewController;
    
    self.containerView = [transitionContext containerView];
    
    UIImage *image;
    UIView *snapShot;
    __block NSNumber *pageIndex;
    for (ImageViewController *imageViewerIndex in imageViewer.pvc.viewControllers) {
        if (imageViewerIndex.pageIndex == imageViewer.pageIndex) {
            pageIndex = @(imageViewerIndex.pageIndex);
            image = imageViewerIndex.imageView.image;
            snapShot = [imageViewerIndex.imageView snapshotViewAfterScreenUpdates:NO];
        }
    }
    
    self.cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:fromViewController.view.bounds];
    self.cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
    self.cellImageSnapshot.image = image;
    [self.cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(self.cellImageSnapshot.image.size,fromViewController.view.bounds)];
    self.startFrame = self.cellImageSnapshot.frame;

    [imageViewer.pvc.view setHidden:YES];
    
    [toViewControllerNC view].frame = [transitionContext finalFrameForViewController:toViewControllerNC];
    [fromViewController view].alpha =0;
    
    self.viewWhite = [[UIView alloc]initWithFrame:[toViewControllerNC view].frame];
    self.viewWhite.backgroundColor = [UIColor whiteColor];
    if (imageViewer.isHiddingToolBarAndNavigationBar) {
        self.viewWhite.backgroundColor = [UIColor blackColor];
    }
    
    
    [self.containerView addSubview:[toViewControllerNC view]];
    [self.containerView addSubview:self.viewWhite];
    [self.containerView addSubview:self.cellImageSnapshot];
    [self.containerView addSubview:snapShot];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.iv.hidden = YES;
        [snapShot removeFromSuperview];
    });
}


-(void)updateInteractiveTransition:(CGFloat)percentComplete{
    self.viewWhite.alpha = 1.1-percentComplete;
    self.cellImageSnapshot.frame = CGRectMake(self.startFrame.origin.x, self.cellImageSnapshot.frame.origin.y-self.changedPoint, self.cellImageSnapshot.frame.size.width, self.cellImageSnapshot.frame.size.height);
}

-(void)finishInteractiveTransition{
    [self.cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFill forFrame:[self.containerView convertRect:self.iv.frame fromView:self.iv.superview] withDuration:0.3 afterDelay:0 finished:^(BOOL finished) {
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.viewWhite.alpha = 0;
    } completion:^(BOOL finished) {
        self.iv.hidden = NO;
        [self.cellImageSnapshot removeFromSuperview];
        [self.viewWhite removeFromSuperview];
        [self.context completeTransition:!self.context.transitionWasCancelled];
        self.context = nil;
        [[UIApplication sharedApplication] setStatusBarStyle:[MHGallerySharedManager sharedManager].oldStatusBarStyle];
    }];
    
}


-(void)cancelInteractiveTransition{
    [UIView animateWithDuration:0.3 animations:^{
        self.cellImageSnapshot.frame = self.startFrame;
        self.viewWhite.alpha = 1;
    } completion:^(BOOL finished) {
        self.iv.hidden = NO;
        [self.cellImageSnapshot removeFromSuperview];
        [self.viewWhite removeFromSuperview];
        UINavigationController *fromViewController = (UINavigationController*)[self.context viewControllerForKey:UITransitionContextFromViewControllerKey];
        [fromViewController view].alpha =1;
        MHGalleryImageViewerViewController *imageViewer  = (MHGalleryImageViewerViewController*)fromViewController.visibleViewController;
        [imageViewer.pvc.view setHidden:NO];

        [self.context completeTransition:NO];
    }];
    
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}


@end
