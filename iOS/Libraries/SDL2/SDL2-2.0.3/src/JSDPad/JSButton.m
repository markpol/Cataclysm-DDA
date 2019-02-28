//
//  JSButton.m
//  Controller
//
//  Created by James Addyman on 29/03/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

#import "JSButton.h"
#import "SDL_uikitviewcontroller.h"

@interface JSButton () {
	
	UIImageView *_backgroundImageView;
	
}

@end

@implementation JSButton

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self commonInit];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super initWithCoder:decoder]))
	{
		[self commonInit];
	}
	
	return self;
}

- (void)commonInit
{
	_backgroundImageView = [[UIImageView alloc] initWithImage:self.backgroundImage];
	[_backgroundImageView setFrame:[self bounds]];
	[_backgroundImageView setContentMode:UIViewContentModeCenter];
	[_backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self addSubview:_backgroundImageView];
	
	_titleLabel = [[UILabel alloc] init];
	[_titleLabel setBackgroundColor:[UIColor clearColor]];
	[_titleLabel setTextColor:[UIColor darkGrayColor]];
	[_titleLabel setShadowColor:[UIColor whiteColor]];
	[_titleLabel setShadowOffset:CGSizeMake(0, 1)];
	[_titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
	[_titleLabel setFrame:[self bounds]];
	[_titleLabel setTextAlignment:NSTextAlignmentCenter];
	[_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self addSubview: _titleLabel];
	
	[self addObserver:self
		   forKeyPath:@"pressed"
			  options:NSKeyValueObservingOptionNew
			  context:NULL];
	
	[self addObserver:self
		   forKeyPath:@"backgroundImage"
			  options:NSKeyValueObservingOptionNew
			  context:NULL];
	
	[self addObserver:self
		   forKeyPath:@"backgroundImagePressed"
			  options:NSKeyValueObservingOptionNew
			  context:NULL];
	
	self.pressed = NO;
    
    // Create a gesture recognizer for detecting drag gesture.
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handlePan:)];
    self.panGestureRecognizer.delegate = self;
    // Add gesture recognizer to the contentView.
    [self addGestureRecognizer:self.panGestureRecognizer];
    self.panGestureRecognizer.enabled = NO;
    self.isModifying = NO;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"pressed"];
	[self removeObserver:self forKeyPath:@"backgroundImage"];
	[self removeObserver:self forKeyPath:@"backgroundImagePressed"];
	self.delegate = nil;
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
{
	_titleEdgeInsets = titleEdgeInsets;
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[_backgroundImageView setFrame:[self bounds]];
	[_titleLabel setFrame:[self bounds]];
	
	CGRect frame = [_titleLabel frame];
	frame.origin.x += _titleEdgeInsets.left;
	frame.origin.y += _titleEdgeInsets.top;
	frame.size.width -= _titleEdgeInsets.right;
	frame.size.height -= _titleEdgeInsets.bottom;
	[_titleLabel setFrame:frame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"pressed"] ||
		[keyPath isEqualToString:@"backgroundImage"] ||
		[keyPath isEqualToString:@"backgroundImagePressed"])
	{
		if (self.pressed)
		{
			[_backgroundImageView setImage:self.backgroundImagePressed];
		}
		else
		{
			[_backgroundImageView setImage:self.backgroundImage];
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( self.isModifying )
    {
        if( [self.controller getCurrentSelectedUI] != self )
            [self.controller setCurrentSelectedUI:self];
        return;
    }
    
	self.pressed = YES;
	if ([self.delegate respondsToSelector:@selector(buttonPressed:)])
	{
		[self.delegate buttonPressed:self];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( self.isModifying )
        return;
    
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGFloat width = [self frame].size.width;
	CGFloat height = [self frame].size.height;
	
	if (!self.pressed)
	{
		self.pressed = YES;
		if ([self.delegate respondsToSelector:@selector(buttonPressed:)])
		{
			[self.delegate buttonPressed:self];
		}
	}
	
	if (((point.x < 0) || (point.x > width)) || ((point.y < 0) || (point.y > height)))
	{
		if (self.pressed)
		{
			self.pressed = NO;
			if ([self.delegate respondsToSelector:@selector(buttonReleased:)])
			{
				[self.delegate buttonReleased:self];
			}
		}
	}
	else
	{
		self.pressed = YES;
		if ([self.delegate respondsToSelector:@selector(buttonPressed:)])
		{
			[self.delegate buttonPressed:self];
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( self.isModifying )
        return;
    
	self.pressed = NO;
	if ([self.delegate respondsToSelector:@selector(buttonReleased:)])
	{
		[self.delegate buttonReleased:self];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( self.isModifying )
        return;
    
	self.pressed = NO;
	if ([self.delegate respondsToSelector:@selector(buttonReleased:)])
	{
		[self.delegate buttonReleased:self];
	}
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    //NSLog( @"handlePan" );
    
    
    if( !self.isModifying )
        return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        // Start of the gesture.
        // You could remove any layout constraints that interfere
        // with changing of the position of the content view.
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        // Calculate new center of the view based on the gesture recognizer's
        // translation.
        CGPoint newCenter = self.center;
        newCenter.x += [gestureRecognizer translationInView:self.superview].x;
        newCenter.y += [gestureRecognizer translationInView:self.superview].y;
        
        // Set the new center of the view.
        self.center = newCenter;
        
        // Reset the translation of the recognizer.
        [gestureRecognizer setTranslation:CGPointZero inView:self.superview];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        // Dragging has ended.
        // You could add layout constraints back to the content view here.
    }
}

@end
