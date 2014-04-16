/*
 *  UIInputToolbar.m
 *
 *  Created by Vlad Kovtash on 2013/03/26.
 *  Copyright 2013 Vlad Kovtash.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

/*
 *  This class is based on UIInputToolbar by Brandon Hamilton
 *  https://github.com/brandonhamilton/inputtoolbar
 */

#import "UIInputToolbar.h"

static CGFloat kDefaultButtonHeight = 26;
static CGFloat kInputFieltMargin = 8;

@interface UIInputToolbar()
@property (nonatomic) CGFloat touchBeginY;
@end

@implementation UIInputToolbar

@synthesize textView;
@synthesize inputButton;
@synthesize inputDelegate = _inputDelegate;

-(void)inputButtonPressed
{
    if ([_inputDelegate respondsToSelector:@selector(inputButtonPressed:)])
    {
        [_inputDelegate inputButtonPressed:self];
    }
}

-(void)setupToolbar:(NSString *)buttonLabel
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:buttonLabel forState:UIControlStateNormal];
    [button addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    CGFloat toolbarEdgeSeparatorWidth = 0;
    
    UIColor *buttonNormalColor = [UIColor colorWithRed:0 green:0.48 blue:1 alpha:1];
    UIColor *buttonHighlightedColor = [UIColor colorWithRed:0.6 green:0.8 blue:1 alpha:1];
    UIColor *buttonDisabledColor = [UIColor lightGrayColor];
    
    /* Create custom send button*/
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [button setTitleColor:buttonNormalColor forState:UIControlStateNormal];
    [button setTitleColor:buttonHighlightedColor forState:UIControlStateHighlighted];
    [button setTitleColor:buttonDisabledColor forState:UIControlStateDisabled];
    [button sizeToFit];
    
    CGRect bounds = button.bounds;
    bounds.size.height = kDefaultButtonHeight;
    button.bounds = bounds;
    
    toolbarEdgeSeparatorWidth = -12;
    
    self.inputButton = button;
    self.inputButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

    /* Disable button initially */
    self.inputButton.enabled = NO;
    
    /* Create UIExpandingTextView input */
    self.textView = [[UIExpandingTextView alloc] initWithFrame:self.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    CGRect textViewRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(5, 5, 5, 60));
    self.textView.frame = textViewRect;


    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.inputButton.frame = CGRectMake(self.bounds.size.width - 60, textViewRect.origin.y, 55, textViewRect.size.height);
    } else {
        self.inputButton.frame = CGRectMake(self.bounds.size.width - 60, textViewRect.origin.y, 55, textViewRect.size.height - 5);
    }
    
    
    self.textCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 60, 5, 60, 15)];
    self.textCountLabel.textAlignment = NSTextAlignmentCenter;
    self.textCountLabel.font = [UIFont systemFontOfSize:13];
    self.textCountLabel.textColor = [UIColor darkGrayColor];
    self.textCountLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self adjustVisibleItems];
    
    self.textView.delegate = self;
    self.animateHeightChanges = YES;
    
}

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self _initialize];
    }
    return self;
}


- (void)_initialize {
    self.backgroundColor = [UIColor whiteColor];
    [self setupToolbar:@"Send"];
}

- (void) adjustVisibleItems {
    
    [self addSubview:self.textView];
    [self addSubview:self.textCountLabel];
    [self addSubview:self.inputButton];

    [self layoutExpandingTextView];
}

- (void) layoutExpandingTextView {
    BOOL calculatePosition = YES;

    CGRect frame = self.textView.frame;
    frame.size.width = self.bounds.size.width;
    frame.origin.x = 0;
    for(UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIExpandingTextView class]]) {
            calculatePosition = NO;
        } else if (view) {
            if (calculatePosition) {
            }

        }
    }
}

- (void) layoutSubviews{
    [super layoutSubviews];
    
    CGRect i = self.inputButton.frame;
    i.origin.y = self.frame.size.height - i.size.height - 7;
    self.inputButton.frame = i;
    
    self.textView.animateHeightChange = self.animateHeightChanges;
    
    CGRect intersectionRect = CGRectIntersection(self.inputButton.frame, self.textCountLabel.frame);
    if (intersectionRect.size.height > 0) {
        self.textCountLabel.hidden = YES;
    } else {
        self.textCountLabel.hidden = NO;
    }
    
}


#pragma mark - UIExpandingTextView delegate

-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(CGFloat)height
{
    /* Adjust the height of the toolbar when the input component expands */
    float diff = (textView.frame.size.height - height);
    CGRect r = self.frame;
    r.origin.y += diff;
    r.size.height -= diff;
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:WillChangeHeight:)]) {
        [self.inputDelegate inputToolbar:self WillChangeHeight:r.size.height];
    }
    
    self.frame = r;
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:DidChangeHeight:)]) {
        [self.inputDelegate inputToolbar:self DidChangeHeight:self.frame.size.height];
    }
}

-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
    /* Enable/Disable the button */
    if ([expandingTextView.text length] > 0)
        self.inputButton.enabled = YES;
    else
        self.inputButton.enabled = NO;
    
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarViewDidChange:)]) {
        [self.inputDelegate inputToolbarViewDidChange:self];
    }
}

- (BOOL)expandingTextViewShouldBeginEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarShouldBeginEditing:)]) {
        return [self.inputDelegate inputToolbarShouldBeginEditing:self];
    }
    return YES;
}

- (BOOL)expandingTextViewShouldEndEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarShouldEndEditing:)]) {
        return [self.inputDelegate inputToolbarShouldEndEditing:self];
    }
    return YES;
}

- (void)expandingTextViewDidBeginEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarDidBeginEditing:)]) {
        [self.inputDelegate inputToolbarDidBeginEditing:self];
    }
}

- (void)expandingTextViewDidEndEditing:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarDidEndEditing:)]) {
        [self.inputDelegate inputToolbarDidEndEditing:self];
    }
}

- (BOOL)expandingTextView:(UIExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbar:shouldChangeTextInRange:replacementText:)]) {
        return [self.inputDelegate inputToolbar:self shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)expandingTextViewDidChangeSelection:(UIExpandingTextView *)expandingTextView{
    if ([self.inputDelegate respondsToSelector:@selector(inputToolbarViewDidChangeSelection:)]) {
        [self.inputDelegate inputToolbarViewDidChangeSelection:self];
    }
}

@end
