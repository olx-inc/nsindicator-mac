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
        NSString *configFile = [[NSBundle mainBundle] pathForResource:@"environments" ofType:@"plist"];
    */
    
    // Get remote plist config file and load into Dictionary
    NSString *configUrl = @"https://raw.githubusercontent.com/juan-sanzone-olx/nsindicator-mac/master/config/environments.plist";
    NSURL *configFile = [NSURL URLWithString: configUrl];
    NSDictionary *environments = [[NSDictionary alloc] initWithContentsOfURL:configFile];
    
    // Load status bar
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // Add default image icon
    NSString *itemImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/unknown.png"];
    NSImage *itemImage = [[NSImage alloc] initWithContentsOfFile:itemImagePath];
    
    // Customize default item
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"nsIndicator"];
    [self.statusItem setImage:itemImage];
    [self.statusItem setHighlightMode:YES];
    
    // Build menu from environments
    [environments enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop)
    {
        NSString *imageStr = [NSString stringWithFormat: @"%@%@%@", @"/", [key lowercaseString], @".png"];
        NSString *itemImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:imageStr];
        NSImage *itemImage = [[NSImage alloc] initWithContentsOfFile:itemImagePath];
        
        NSMenuItem *currentItem = [[NSMenuItem alloc] initWithTitle:key action:@selector(updateDns:) keyEquivalent:@""];
        [currentItem setToolTip:value];
        [currentItem setImage:itemImage];
        [currentItem setEnabled:YES];
        
        [self.statusMenu addItem: currentItem];
    }];
    
    // Build Exit item
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *exitItem = [[NSMenuItem alloc] initWithTitle:@"Exit" action:@selector(exitApp:) keyEquivalent:@""];
    [exitItem setToolTip:@"Click to Close this App"];
    [exitItem setEnabled:YES];
    [self.statusMenu addItem: exitItem];
}

- (IBAction)updateDns:(NSMenuItem *)menuItem
{
    // Create terminal command to change DNS
    NSString* terminalCmd = @"networksetup -setdnsservers Wi-Fi ";
    terminalCmd = [terminalCmd stringByAppendingString:menuItem.toolTip];
    
    // Exec bash command
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash/";
    NSArray* aditionalParameters = [NSArray arrayWithObjects:@"-c", terminalCmd, nil];
    task.arguments  = aditionalParameters;
    [task launch];
    [task waitUntilExit];
    
    // Update status menu bar
    [self updateStatusBar:menuItem];
}

- (void)updateStatusBar:(NSMenuItem *)menuItem
{
    NSString *imageStr = [NSString stringWithFormat: @"%@%@%@", @"/", [menuItem.title lowercaseString], @".png"];
    NSString *itemImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:imageStr];
    NSImage *itemImage = [[NSImage alloc] initWithContentsOfFile:itemImagePath];
    
    [self.statusItem setTitle:menuItem.title];
    [self.statusItem setImage:itemImage];
}

- (IBAction)exitApp:(NSMenuItem *)menuItem
{
    exit(0);
}

@end
