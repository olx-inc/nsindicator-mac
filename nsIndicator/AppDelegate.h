//
//  AppDelegate.h
//  nsIndicator
//
//  Created by Juan on 10/17/14.
//  Copyright (c) 2014 jsanzo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusItem;

@end
