//
//  CustomModalViewTransition.m
//  LenzCameraNativeModuleForRN
//
//  Created by 王昭威 on 2023/1/23.
//
#import "PCSBaseViewController.h"
#import "CustomModalViewTransition.h"
#import "PhotoListViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoListCellModel.h"
#import "LenzHeader.h"

@implementation CustomModalViewTransitionPresent

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    PCSBaseViewController* fromVC = (PCSBaseViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PhotoListViewController* toVC = (PhotoListViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* container = transitionContext.containerView;
    
    id<OperationNodeProtocol> curr = fromVC.currentOperationNode;
//    UIView* snapshotView = [fromVC.albumButton.imageView snapshotViewAfterScreenUpdates:NO];
    UIImage* img = nil;
    if([curr respondsToSelector:@selector(firstCoverImage)]){
        img = curr.firstCoverImage;
    }
    UIImageView* snapshotView = [[UIImageView alloc] initWithImage:img];
    snapshotView.contentMode = UIViewContentModeScaleAspectFit;
    snapshotView.frame = [fromVC.albumButton convertRect:fromVC.albumButton.imageView.frame toView:container];
    fromVC.albumButton.imageView.hidden = YES;
    
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    
    [container addSubview:toVC.view];
    [container addSubview:snapshotView];
    container.backgroundColor = toVC.view.backgroundColor;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{

        fromVC.view.alpha = 0;
        snapshotView.frame = CGRectMake(15, 15, CGRectGetWidth(toVC.photoCollectionView.frame) - 30, CGRectGetHeight(toVC.photoCollectionView.frame) - 30);
    } completion:^(BOOL finished) {
        fromVC.albumButton.imageView.hidden = NO;
        [snapshotView removeFromSuperview];
        toVC.view.alpha = 1;
        [transitionContext completeTransition:YES];
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

@end

@implementation CustomModalViewTransitionDismiss

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    PhotoListViewController* fromVC = (PhotoListViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    PCSBaseViewController* toVC = (PCSBaseViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* container = transitionContext.containerView;
    
    NSArray<__kindof UICollectionViewCell *> *visibleCells = fromVC.photoCollectionView.visibleCells;
    __block PhotoCollectionViewCell* currCell = nil;
    [visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(CGRectContainsRect(fromVC.photoCollectionView.bounds, obj.frame)){
            *stop = YES;
            currCell = obj;
        }
    }];
    
    UIView* snapshotView = [currCell.coverView snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = [fromVC.photoCollectionView convertRect:currCell.frame toView:container];
    currCell.imageView.hidden = YES;
    toVC.albumButton.imageView.hidden = YES;
    
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    
    [container addSubview:toVC.view];
    [container addSubview:snapshotView];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{

        snapshotView.frame = toVC.albumButton.frame;
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        toVC.albumButton.imageView.hidden = NO;
        [snapshotView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

@end
