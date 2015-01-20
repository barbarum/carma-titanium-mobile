/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#ifdef USE_TI_UITAB

#import "TiUITabGroup.h"
#import "TiUITabProxy.h"
#import "TiUtils.h"
#import "TiColor.h"
#import "TiUITabGroupProxy.h"

@implementation TiUITabGroup

-(void)dealloc
{
	RELEASE_TO_NIL(controller);
	RELEASE_TO_NIL(focusedTabProxy);
	RELEASE_TO_NIL(barColor);
	RELEASE_TO_NIL(navTintColor);
	RELEASE_TO_NIL(theAttributes)
    RELEASE_TO_NIL(activeBarIndicator);
	[super dealloc];
}

-(UITabBarController*)tabController
{
    if (controller==nil) {
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           CarmaColorGray, UITextAttributeTextColor,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0], UITextAttributeFont,
                                                           nil]
                                                 forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           CarmaColorOrange, UITextAttributeTextColor,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0], UITextAttributeFont,
                                                           nil]
                                                 forState:UIControlStateSelected];
        
        controller = [[UITabBarController alloc] init];
        controller.delegate = self;
        controller.moreNavigationController.delegate = self;
        [TiUtils configureController:controller withObject:self.proxy];

        [TiUtils configureController:controller.moreNavigationController withObject:self.proxy];
        
        if ([TiUtils isIOS7OrGreater]) {
            controller.tabBar.translucent = NO;
        }
        
        CGRect frame = [self getFrameFromBarItem:controller.tabBar.selectedItem];
        activeBarIndicator = [[UIView alloc] initWithFrame:frame];
        activeBarIndicator.backgroundColor = CarmaColorOrange;
        [controller.tabBar addSubview:activeBarIndicator];

    }
    return controller;
}

-(CGRect)getFrameFromBarItem:(UITabBarItem*)barItem {
    UIView *view = [barItem valueForKey:@"view"];
    CGRect rect = CGRectNull;
    if (view) {
        CGRect newFrame = { CGPointMake(view.frame.origin.x, 0), CGSizeMake(view.frame.size.width, 2)};
        rect = newFrame;
    }
    
    return rect;
}

- (int)getIndexFromFrame:(CGRect)frame {
    return frame.origin.x/frame.size.width;
}

- (id)accessibilityElement
{
    return [self tabbar];
}

-(UITabBar*)tabbar
{
    return [self tabController].tabBar;
}

-(int)findIndexForTab:(TiProxy*)proxy
{
    if (proxy!=nil)
    {
        int index = 0;
        for (UINavigationController *tc in controller.viewControllers)
        {
            if (tc.delegate == (id)proxy)
            {
                return index;
            }
            index++;
        }
    }
    return -1;
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    if ([controller isViewLoaded]) {
        [[controller view] setFrame:bounds];
    }
    [super frameSizeChanged:frame bounds:bounds];
}

#pragma mark Dispatching focus change

- (void)handleWillShowTab:(TiUITabProxy *)newFocus
{
    if (focusedTabProxy != newFocus) {
        [focusedTabProxy handleWillBlur];
        [newFocus handleWillFocus];
    }
}

- (void)handleDidShowTab:(TiUITabProxy *)newFocus
{
    // Do nothing if no tabs are being focused or blurred (or the window is opening)
    if ((focusedTabProxy == nil && newFocus == nil) || (focusedTabProxy == newFocus)) {
        //TIMOB-10796. Ensure activeTab is set to focused on early return
        if (focusedTabProxy != nil) {
            [self.proxy replaceValue:focusedTabProxy forKey:@"activeTab" notification:NO];
        }
        return;
    }
    
s	NSMutableDictionary * event = [NSMutableDictionary dictionaryWithCapacity:4];

	NSArray * tabArray = [controller viewControllers];

	NSInteger previousIndex = -1;
	NSInteger index = -1;

	if (focusedTabProxy != nil)
	{
		[event setObject:focusedTabProxy forKey:@"previousTab"];
		previousIndex = [tabArray indexOfObject:[(TiUITabProxy *)focusedTabProxy controller]];
	}
	
	if (newFocus != nil)
	{
		[event setObject:newFocus forKey:@"tab"];
		index = [tabArray indexOfObject:[(TiUITabProxy *)newFocus controller]];
	}

	[event setObject:NUMINTEGER(previousIndex) forKey:@"previousIndex"];
	[event setObject:NUMINTEGER(index) forKey:@"index"];

	[self.proxy fireEvent:@"blur" withObject:event];
	[focusedTabProxy handleDidBlur:event];

    [focusedTabProxy replaceValue:[NSNumber numberWithBool:NO] forKey:@"active" notification:NO];
    
    RELEASE_TO_NIL(focusedTabProxy);
    focusedTabProxy = [newFocus retain];
    [self.proxy replaceValue:focusedTabProxy forKey:@"activeTab" notification:NO];
    [focusedTabProxy replaceValue:[NSNumber numberWithBool:YES] forKey:@"active" notification:NO];
    
    // If we're in the middle of opening, the focus happens once the tabgroup is opened
    if (![(TiWindowProxy*)[self proxy] opening]) {
        [self.proxy fireEvent:@"focus" withObject:event];
    }
    //TIMOB-15187. Dont fire focus of tabs if proxy does not have focus
    if ([(TiUITabGroupProxy*)[self proxy] canFocusTabs]) {
        [focusedTabProxy handleDidFocus:event];
    }
}


#pragma mark More tab delegate


-(void)updateMoreBar:(UINavigationController *)moreController
{
    UIColor * theColor = [TiUtils barColorForColor:barColor];
    UIBarStyle navBarStyle = [TiUtils barStyleForColor:barColor];
    UIColor * nTintColor = [navTintColor color];
    BOOL translucent = [TiUtils boolValue:[self.proxy valueForUndefinedKey:@"translucent"] def:[TiUtils isIOS7OrGreater]];
    
    //Update the UINavigationBar appearance.
    [[UINavigationBar appearanceWhenContainedIn:[UITabBarController class], nil] setBarStyle:navBarStyle];
    [[UINavigationBar appearanceWhenContainedIn:[UITabBarController class], nil] setTitleTextAttributes:theAttributes];
    if ([TiUtils isIOS7OrGreater]) {
        [[UINavigationBar appearanceWhenContainedIn:[UITabBarController class], nil] setBarTintColor:theColor];
        [[UINavigationBar appearanceWhenContainedIn:[UITabBarController class], nil] setTintColor:nTintColor];
    } else {
        [[UINavigationBar appearanceWhenContainedIn:[UITabBarController class], nil] setTintColor:theColor];
    }

    if ([[moreController viewControllers] count] != 1) {
        return;
    }
    //Update the actual nav bar here in case the windows changed the stuff.
    UINavigationBar * navBar = [moreController navigationBar];
    [navBar setBarStyle:navBarStyle];
    [navBar setTitleTextAttributes:theAttributes];
    [navBar setTranslucent:translucent];
    if([TiUtils isIOS7OrGreater]) {
        [navBar performSelector:@selector(setBarTintColor:) withObject:theColor];
        [navBar setTintColor:nTintColor];
    } else {
        [navBar setTintColor:theColor];
    }
}

-(void)setEditButton:(UINavigationController*)moreController
{
    if ([[moreController viewControllers] count] == 1) {
        UINavigationBar* navBar = [moreController navigationBar];
        UINavigationItem* navItem = [navBar topItem];
        UIBarButtonItem* editButton = [navItem rightBarButtonItem];
        if (editTitle != nil) {
            editButton.title = editTitle;
        }
        else {
            // TODO: Need to get the localized value here
            editButton.title = @"Edit";
        }
    }
}

-(void)removeEditButton:(UINavigationController*)moreController
{
    if ([[moreController viewControllers] count] == 1) {
        UINavigationBar* navBar = [moreController navigationBar];
        UINavigationItem* navItem = [navBar topItem];
        [navItem setRightBarButtonItem:nil];
    }
}

#ifdef USE_TI_UIIOSTRANSITIONANIMATION
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if([toVC isKindOfClass:[TiViewController class]]) {
        TiViewController* toViewController = (TiViewController*)toVC;
        if([[toViewController proxy] isKindOfClass:[TiWindowProxy class]]) {
            TiWindowProxy *windowProxy = (TiWindowProxy*)[toViewController proxy];
            return [windowProxy transitionAnimation];
        }
    }
    return nil;
}
#endif

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray * moreViewControllerStack = [navigationController viewControllers];
    NSUInteger stackHeight = [moreViewControllerStack count];
    if (stackHeight > 1) {
        UIViewController * rootController = [moreViewControllerStack objectAtIndex:1];
        if ([rootController respondsToSelector:@selector(proxy)]) {
            id theProxy = [(id)rootController proxy];
            if ([theProxy conformsToProtocol:@protocol(TiWindowProtocol)] ) {
                TiUITabProxy * tabProxy = (TiUITabProxy *)[(id)theProxy tab];
                [tabProxy handleWillShowViewController:viewController animated:animated];
            } else {
                DebugLog(@"[ERROR] The view controller is not hosting a window proxy. Can not find tab.");
            }
        } else {
            DebugLog(@"[ERROR] The view controller does not respond to selector proxy. Can not find window");
        }
    } else {
        [self handleWillShowTab:nil];
        [self updateMoreBar:navigationController];
        if (allowConfiguration) {
            [self setEditButton:navigationController];
        }
        // However, under iOS4, we have to manage the appearance/disappearance of the edit button ourselves.
        else {
            [self removeEditButton:navigationController];
        }
    }
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray * moreViewControllerStack = [navigationController viewControllers];
    NSUInteger stackHeight = [moreViewControllerStack count];
    if (stackHeight < 2) { //No more faux roots.
        if (focusedTabProxy != nil) {
            [self handleDidShowTab:nil];
        }
        //Ensure that the moreController has only top edge extended
        if ([TiUtils isIOS7OrGreater]) {
            [TiUtils configureController:viewController withObject:[NSDictionary dictionaryWithObject:NUMINT(1) forKey:@"extendEdges"]];
        }
        return;
    }
    
    UIViewController * rootController = [moreViewControllerStack objectAtIndex:1];
    TiUITabProxy * tabProxy = nil;
    if ([rootController respondsToSelector:@selector(proxy)]) {
        id theProxy = [(id)rootController proxy];
        if ([theProxy conformsToProtocol:@protocol(TiWindowProtocol)] ) {
            tabProxy = (TiUITabProxy *)[(id)theProxy tab];
        } else {
            DebugLog(@"[ERROR] The view controller is not hosting a window proxy. Can not find tab.");
            return;
        }
    } else {
        DebugLog(@"[ERROR] The view controller does not respond to selector proxy. Can not find window");
        return;
    }
    
    if (stackHeight == 2) {	//One for the picker, one for the faux root.
        if (tabProxy != focusedTabProxy) {
            [self handleDidShowTab:tabProxy];
        }
    }
    
    [tabProxy handleDidShowViewController:viewController animated:animated];
}

#pragma mark TabBarController Delegates

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    TiUITabProxy * target=nil;
    if ([tabBarController moreNavigationController] == viewController) {
        NSArray * moreViewControllerStack = [(UINavigationController *)viewController viewControllers];
        if ([moreViewControllerStack count]>1) {
            UIViewController * rootController = [moreViewControllerStack objectAtIndex:1];
            if ([rootController respondsToSelector:@selector(proxy)]) {
                id theProxy = [(id)rootController proxy];
                if ([theProxy conformsToProtocol:@protocol(TiWindowProtocol)] ) {
                    target = (TiUITabProxy *)[(id)theProxy tab];
                } else {
                    DebugLog(@"[ERROR] The view controller is not hosting a window proxy. Can not find tab.");
                }
            } else {
                DebugLog(@"[ERROR] The view controller does not respond to selector proxy. Can not find window");
            }
        }
    }
    else
    {
        target = (TiUITabProxy *)[(UINavigationController *)viewController delegate];
    }
    
    [self handleWillShowTab:target];
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	if ([tabBarController moreNavigationController] == viewController)
	{
		if (self != [(UINavigationController *)viewController delegate])
		{
			[(UINavigationController *)viewController setDelegate:self];
		}
		NSArray * moreViewControllerStack = [(UINavigationController *)viewController viewControllers];
		NSUInteger stackCount = [moreViewControllerStack count];
		if (stackCount>1)
		{
			viewController = [moreViewControllerStack objectAtIndex:1];
		}
		else
		{
			[self updateMoreBar:(UINavigationController *)viewController];
			viewController = nil;
		}

	}

    if (activeBarIndicator) {
        CGRect frame = [self getFrameFromBarItem:[self tabbar].selectedItem];
        
        [activeBarIndicator.layer removeAllAnimations];
        [activeBarIndicator setFrame:frame];
        
        CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        [keyFrameAnimation setValues:@[
                                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 1.0, 1.0)],
                                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.0, 1.0)],
                                       [NSValue valueWithCATransform3D:CATransform3DIdentity]
                                       ]];
        [keyFrameAnimation setTimingFunctions:@[
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                                [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                                                ]];
        [keyFrameAnimation setKeyTimes:@[
                                         [NSNumber numberWithFloat:0],
                                         [NSNumber numberWithFloat:0.3],
                                         [NSNumber numberWithFloat:0.3]
                                         ]];
        [keyFrameAnimation setDuration:0.6];
        keyFrameAnimation.fillMode = kCAFillModeForwards;
        [activeBarIndicator.layer addAnimation:keyFrameAnimation forKey:@"KeyAnimation.Scale"];
        
    }
    
	[self handleDidShowTab:(TiUITabProxy *)[(UINavigationController *)viewController delegate]];
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    if (changed) {
        NSMutableArray* tabProxies = [NSMutableArray arrayWithCapacity:[viewControllers count]];
        for (UINavigationController* controller_ in viewControllers) {
            id delegate = [controller_ delegate];
            if ([delegate isKindOfClass:[TiUITabProxy class]]) {
                TiUITabProxy* tabProxy = (TiUITabProxy*)delegate;
                [tabProxies addObject:tabProxy];
            }
        }
        
        // We do it this way to reset the 'tabs' array on the proxy without changing the active
        // controller.  The SDK documentation actually conflicts itself on whether or not the 'more' tab
        // can be manually reselected anyway.
        [(TiUITabGroupProxy*)[self proxy] _resetTabArray:tabProxies];
    }
}

-(void)setTabsBackgroundColor_:(id)value
{
    TiColor* color = [TiUtils colorValue:value];
    UITabBar* tabBar = [controller tabBar];
    //A nil tintColor is fine, too.
    if([TiUtils isIOS7OrGreater]) {
        [tabBar performSelector:@selector(setBarTintColor:) withObject:[color color]];
    } else {
        tabBar.tintColor = [color color];
    }
}

-(void)setTabsTintColor_:(id)value
{
    if ([TiUtils isIOS7OrGreater]) {
        TiColor* color = [TiUtils colorValue:value];
        UITabBar* tabBar = [controller tabBar];
        tabBar.tintColor = [color color];
    }
}

-(void)setTabsBackgroundImage_:(id)value
{
    controller.tabBar.backgroundImage = [self loadImage:value];
}

-(void)setActiveTabBackgroundImage_:(id)value
{
    controller.tabBar.selectionIndicatorImage = [self loadImage:value];
}

-(void)setShadowImage_:(id)value
{
    if (![TiUtils isIOS6OrGreater]) {
        NSLog(@"[WARN] activeTabBackgroundImage is only supported in iOS 6 or above.");
        return;
    }
    //Because we still support XCode 4.3, we cannot use the shadowImage property
    [controller.tabBar setShadowImage:[self loadImage:value]];
}

-(void) setActiveTabIconTint_:(id)value
{
    TiColor* color = [TiUtils colorValue:value];
    //A nil tintColor is fine, too.
    controller.tabBar.selectedImageTintColor = color.color;
}

#pragma mark Public APIs

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [controller willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [controller willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [controller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(void)setTranslucent_:(id)value
{
    [[self proxy] replaceValue:value forKey:@"translucent" notification:NO];
    [self updateMoreBar:[controller moreNavigationController]];
}

-(void)setBarColor_:(id)value
{
	[barColor release];
	barColor = [[TiUtils colorValue:value] retain];
	[self.proxy replaceValue:value forKey:@"barColor" notification:NO];
	[self updateMoreBar:[controller moreNavigationController]];
}

-(void)setTitleAttributes_:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    [self.proxy replaceValue:args forKey:@"titleAttributes" notification:NO];
    RELEASE_TO_NIL(theAttributes)
    if (args != nil) {
        theAttributes = [[NSMutableDictionary dictionary] retain];
        if ([args objectForKey:@"color"] != nil) {
            UIColor* theColor = [[TiUtils colorValue:@"color" properties:args] _color];
            if (theColor != nil) {
                [theAttributes setObject:theColor forKey: NSForegroundColorAttributeName];
            }
        }
        if ([args objectForKey:@"shadow"] != nil) {
            NSShadow* shadow = [TiUtils shadowValue:[args objectForKey:@"shadow"]];
            if (shadow != nil) {
                [theAttributes setObject:shadow forKey:NSShadowAttributeName];
            }
        }
        
        if ([args objectForKey:@"font"] != nil) {
            UIFont* theFont = [[TiUtils fontValue:[args objectForKey:@"font"] def:nil] font];
            if (theFont != nil) {
                [theAttributes setObject:theFont forKey: NSFontAttributeName];
            }
        }
        
        if ([theAttributes count] == 0) {
            RELEASE_TO_NIL(theAttributes)
        }
    }
    [self updateMoreBar:[controller moreNavigationController]];
}


-(void)setNavTintColor_:(id)value
{
    [navTintColor release];
    navTintColor = [[TiUtils colorValue:value] retain];
    [self.proxy replaceValue:value forKey:@"navTintColor" notification:NO];
    [self updateMoreBar:[controller moreNavigationController]];
}


-(void)setActiveTab_:(id)value
{
    UIViewController *active = nil;
    
    if (controller == nil)
    {
        return;
    }
    if ([value isKindOfClass:[TiUITabProxy class]])
    {
        
        TiUITabProxy *tab = (TiUITabProxy*)value;
        for (UIViewController *c in [self tabController].viewControllers)
        {
            if ([[tab controller] isEqual:c])
            {
                active = c;
                break;
            }
        }
    }
    else if (value != nil)
    {
        int index = [TiUtils intValue:value];
        if (index >= 0 && index < [[self tabController].viewControllers count])
        {
            active = [[self tabController].viewControllers objectAtIndex:index];
        }
    }
    if (active == nil && [self tabController].viewControllers.count > 0)  {
        active = [self tabController].selectedViewController;
    }
    if (active == nil)  {
        DebugLog(@"setActiveTab called but active view controller could not be determined");
    }
    else {
        [self tabController].selectedViewController = active;
    }
    [self tabBarController:[self tabController] didSelectViewController:active];
}

-(void)setAllowUserCustomization_:(id)value
{
    allowConfiguration = [TiUtils boolValue:value def:YES];
    if (allowConfiguration) {
        [self tabController].customizableViewControllers = [self tabController].viewControllers;
        [self setEditButton:[controller moreNavigationController]];
    }
    else {
        [self tabController].customizableViewControllers = nil;
        [self removeEditButton:[controller moreNavigationController]];
    }
}

-(void)setEditButtonTitle_:(id)value
{
    editTitle = [TiUtils stringValue:value];
    [self setEditButton:[controller moreNavigationController]];
}

-(void)setTabs_:(id)tabs
{
    ENSURE_TYPE_OR_NIL(tabs,NSArray);
    
    if (tabs!=nil && [tabs count] > 0) {
        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        id thisTab = [[self proxy] valueForKey:@"activeTab"];
        
        TiUITabProxy *theActiveTab = nil;
        
        if (thisTab != nil && thisTab != [NSNull null]) {
            if (![thisTab isKindOfClass:[TiUITabProxy class]]) {
                int index = [TiUtils intValue:thisTab];
                if (index < [tabs count]) {
                    theActiveTab = [tabs objectAtIndex:index];
                }
            }
            else {
                if ([tabs containsObject:thisTab]) {
                    theActiveTab = thisTab;
                }
            }
        }
        
        for (TiUITabProxy *tabProxy in tabs) {
            [controllers addObject:[tabProxy controller]];
            if ([TiUtils boolValue:[tabProxy valueForKey:@"active"]]) {
                RELEASE_TO_NIL(focusedTabProxy);
                focusedTabProxy = [tabProxy retain];
            }
        }
        
        if (theActiveTab != nil && focusedTabProxy != theActiveTab) {
            RELEASE_TO_NIL(focusedTabProxy);
            focusedTabProxy = [theActiveTab retain];
        }
        
        [self tabController].viewControllers = nil;
        [self tabController].viewControllers = controllers;
        if ( focusedTabProxy != nil && ![tabs containsObject:focusedTabProxy]) {
            if (theActiveTab != nil) {
                [self setActiveTab_:theActiveTab];
            }
            else {
                DebugLog(@"[WARN] ActiveTab property points to tab not in list. Ignoring");
                RELEASE_TO_NIL(focusedTabProxy);
            }
        }
        
        [controllers release];
    }
    else {
        RELEASE_TO_NIL(focusedTabProxy);
        [self tabController].viewControllers = nil;
    }
    
    [self.proxy	replaceValue:focusedTabProxy forKey:@"activeTab" notification:YES];
    [self setAllowUserCustomization_:[NSNumber numberWithBool:allowConfiguration]];
    
    NSArray * tabArray = [controller viewControllers];
    for (UIViewController *tabController in tabArray) {
        [(TiUITabProxy*)[(UINavigationController*)tabController delegate] rollingAnimatedOrStaticIfNeed];
    }
}

-(void)open:(id)args
{
    UIView *view = [self tabController].view;
    [view setFrame:[self bounds]];
    [self addSubview:view];
    
    // on an open, make sure we send the focus event to focused tab
    NSArray * tabArray = [controller viewControllers];
    NSInteger index = 0;
    if (focusedTabProxy != nil)
	{
		index = [tabArray indexOfObject:[(TiUITabProxy *)focusedTabProxy controller]];
	}
	NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:focusedTabProxy,@"tab",NUMINTEGER(index),@"index",NUMINT(-1),@"previousIndex",[NSNull null],@"previousTab",nil];
	[self.proxy fireEvent:@"focus" withObject:event];
    // Tab has already been focused by the tab controller delegate
    //[focused handleDidFocus:event];
}

-(void)close:(id)args
{
    if (controller!=nil)
    {
        controller.viewControllers = nil;
    }
    RELEASE_TO_NIL(controller);
}

@end

#endif