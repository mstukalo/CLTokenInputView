//
//  CLTokenView.m
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLTokenView.h"

#import <QuartzCore/QuartzCore.h>

static CGFloat const PADDING_X = 3.0;
static CGFloat const PADDING_Y = 2.0;


@interface CLTokenView ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIView *selectedBackgroundView;
@property (strong, nonatomic) UILabel *selectedLabel;

@end

@implementation CLTokenView

- (id)initWithToken:(CLToken *)token
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_X, PADDING_Y, 0, 0)];
        self.label.font = [UIFont systemFontOfSize:17.0];
        self.label.textColor = self.tintColor; // TODO(Riz): use the application tint color here
        [self addSubview:self.label];

        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView.backgroundColor = [self tintColor];
        self.selectedBackgroundView.layer.cornerRadius = 3.0;
        [self addSubview:self.selectedBackgroundView];
        self.selectedBackgroundView.hidden = YES;

        self.selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_X, PADDING_Y, 0, 0)];
        self.selectedLabel.font = self.label.font;
        self.selectedLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.selectedLabel];
        self.selectedLabel.hidden = YES;

        // Configure for the token
        self.label.text = self.selectedLabel.text = token.displayText;

        // Listen for taps
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tapRecognizer];

        [self setNeedsLayout];

    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    CGSize labelIntrinsicSize = self.label.intrinsicContentSize;
    return CGSizeMake(labelIntrinsicSize.width+(2.0*PADDING_X), labelIntrinsicSize.height+(2.0*PADDING_Y));
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize fittingSize = CGSizeMake(size.width-(2.0*PADDING_X), size.height-(2.0*PADDING_Y));
    CGSize labelSize = [self.label sizeThatFits:fittingSize];
    return CGSizeMake(labelSize.width+(2.0*PADDING_X), labelSize.height+(2.0*PADDING_Y));
}


#pragma mark - Taps

-(void)handleTapGestureRecognizer:(id)sender
{
    [self.delegate tokenViewDidRequestSelection:self];
}


#pragma mark - Selection

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    _selected = selected;

    if (selected) {
        [self becomeFirstResponder];
    }
    CGFloat selectedAlpha = (_selected ? 1.0 : 0.0);
    if (animated) {
        if (_selected) {
            self.selectedBackgroundView.alpha = 0.0;
            self.selectedBackgroundView.hidden = NO;
            self.selectedLabel.alpha = 0.0;
            self.selectedLabel.hidden = NO;
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.selectedBackgroundView.alpha = selectedAlpha;
            self.selectedLabel.alpha = selectedAlpha;
        } completion:^(BOOL finished) {
            if (!_selected) {
                self.selectedBackgroundView.hidden = YES;
                self.selectedLabel.hidden = YES;
            }
        }];
    } else {
        self.selectedBackgroundView.hidden = !_selected;
        self.selectedLabel.hidden = !_selected;
    }
}


#pragma mark - Laying out

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = self.bounds;

    self.backgroundView.frame = bounds;
    self.selectedBackgroundView.frame = bounds;

    CGRect labelFrame = CGRectInset(bounds, PADDING_X, PADDING_Y);
    self.label.frame = labelFrame;
    self.selectedLabel.frame = labelFrame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark - UIKeyInput protocol

- (BOOL)hasText
{
    return YES;
}

- (void)insertText:(NSString *)text
{
    [self.delegate tokenViewDidRequestDelete:self replaceWithText:text];
}

- (void)deleteBackward
{
    [self.delegate tokenViewDidRequestDelete:self replaceWithText:nil];
}


#pragma mark - First Responder (needed to capture keyboard)

-(BOOL)canBecomeFirstResponder
{
    return YES;
}


@end
