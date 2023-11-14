//
//  PCSAutherView.m
//  LenzSDK
//
//  Created by lr on 2023/4/11.
//

#import "PCSAutherView.h"
#import "UIImage+name.h"
#import <Masonry/Masonry.h>


@interface PCSAutherView()

@property (nonatomic) UIView *centerView;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subLabel;
@property (nonatomic) UILabel *autherLabel;

@end

@implementation PCSAutherView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.closeButton];
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(64);
            make.right.mas_offset(-10);
            make.width.height.mas_offset(44);
        }];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
        [self addSubview:self.subLabel];
        [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self).mas_offset(-30);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(8);
        }];
        [self addSubview:self.autherLabel];
        [self.autherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.subLabel.mas_right);
            make.centerY.mas_equalTo(self.subLabel);
            make.width.mas_offset(70);
            make.height.mas_offset(44);
        }];
    }
    return self;
}

- (void)closeAction {
    if (self.closeBlock) {
        self.closeBlock();
    }
    self.hidden = YES;
}
- (void)authButtonAction {
    NSURL* url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if(url != nil){
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        }];
    }
}
- (void)showAutherWith:(PCSAuthType)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *title = @"需要访问相机和麦克风权限,";
        if (type == PCSAuthPhone) {
            title = @"需要访问相机权限,";
        } else if (type == PCSAuthMir) {
            title = @"需要访问麦克风权限,";
        }
        self.hidden = NO;
        self.subLabel.text = title;
    });
}
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]init];
        [_closeButton setImage:[UIImage loadNamed:@"icon_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"未获得授权";
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}
- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc]init];
        _subLabel.textColor = [UIColor blackColor];
        _subLabel.font = [UIFont systemFontOfSize:14];
    }
    return _subLabel;
}
- (UILabel *)autherLabel {
    if (!_autherLabel) {
        _autherLabel = [[UILabel alloc]init];
        _autherLabel.textColor = [UIColor blackColor];
        _autherLabel.font = [UIFont systemFontOfSize:14];
        _autherLabel.text = @"去开启 >";
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(authButtonAction)];
        [_autherLabel addGestureRecognizer:tap];
        _autherLabel.textAlignment = NSTextAlignmentLeft;
        _autherLabel.textColor = [UIColor colorWithRed:231/255.0 green:108/255.0 blue:30/255.0 alpha:1];
        _autherLabel.userInteractionEnabled = YES;
    }
    return _autherLabel;
}


@end
