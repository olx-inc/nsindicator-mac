//
//  AppDelegate.m
//  nsIndicator
//
//  Created by Juan on 10/17/14.
//  Copyright (c) 2014 jsanzo. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /*
    NSString *configFile = [[NSBundle mainBundle] pathForResource:
                            @"environments" ofType:@"plist"];
    */
    
    // Fetch remote plist config file and load into Dictionary
    NSURL *externalFile = [NSURL URLWithString:@"https://raw.githubusercontent.com/juansanzone/ns_indicator_files/master/environments.plist"];
    NSDictionary *environments = [[NSDictionary alloc] initWithContentsOfURL:externalFile];
    
    // Build Menu from Dictionary
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"nsIndicator"];
    [self.statusItem setHighlightMode:YES];
    
    [environments enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop)
    {
        NSMenuItem *currentItem = [[NSMenuItem alloc] initWithTitle:key action:@selector(updateDns:) keyEquivalent:@""];
        [currentItem setToolTip:value];
        [currentItem setEnabled:YES];
        [self.statusMenu addItem: currentItem];
    }];
    
    NSMenuItem *exitItem = [[NSMenuItem alloc] initWithTitle:@"EXIT" action:@selector(exitApp:) keyEquivalent:@""];
    [exitItem setToolTip:@"Exit app"];
    [exitItem setEnabled:YES];
    [self.statusMenu addItem: exitItem];
}

- (IBAction)updateDns:(NSMenuItem *)menuItem
{
    // Build terminal command
    NSString* terminalCmd = @"networksetup -setdnsservers Wi-Fi ";
    terminalCmd = [terminalCmd stringByAppendingString:menuItem.toolTip];
    
    NSLog(@"Command: %@", terminalCmd);
    
    // Execute command
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash/";
    NSArray* aditionalParameters = [NSArray arrayWithObjects:@"-c", terminalCmd, nil];
    task.arguments  = aditionalParameters;
    [task launch];
    [task waitUntilExit];
    
    // Update status on bar
    [self.statusItem setTitle:menuItem.title];
}

- (IBAction)exitApp:(NSMenuItem *)menuItem
{
    exit(0);
}

@end
