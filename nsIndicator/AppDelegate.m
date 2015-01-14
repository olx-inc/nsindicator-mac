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
    // Read config file and populate into Dictionary
    NSString *configFile = [[NSBundle mainBundle] pathForResource:@"environments" ofType:@"plist"];
    NSDictionary *environments = [[NSDictionary alloc] initWithContentsOfFile:configFile];
    self.wifiAdapterItem = [[NSMenuItem alloc] initWithTitle:@"Wi-Fi" action:@selector(doNetAdapters:) keyEquivalent:@""];
    self.ethernetAdapterItem = [[NSMenuItem alloc] initWithTitle:@"Ethernet" action:@selector(doNetAdapters:) keyEquivalent:@""];
    
    // Load status bar
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    /*
        // Old implementation | Load remote config file
        NSString *configUrl = @"https://raw.githubusercontent.com/juan-sanzone-olx/nsindicator-mac/master/config/environments.plist";
        NSURL *configFile = [NSURL URLWithString: configUrl];
        NSDictionary *environments = [[NSDictionary alloc] initWithContentsOfURL:configFile];
    */
    
    // Add default image icon
    NSString *itemImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/unknown.png"];
    NSImage *itemImage = [[NSImage alloc] initWithContentsOfFile:itemImagePath];
    
    // Customize default status bar item
    [self.statusItem setMenu:self.statusMenu];
    // [self.statusItem setTitle:@"nsIndicator"]; // En yosemite rompe
    [self.statusItem setImage:itemImage];
    [self.statusItem setHighlightMode:YES];
    
    // Build google DNS item
    [self buildGoogleItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    
    // Build menu with environments
    [environments enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop)
    {
        NSString *imageStr = [NSString stringWithFormat: @"%@%@%@", @"/", [key lowercaseString], @".png"];
        NSString *itemImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:imageStr];
        NSImage *itemImage = [[NSImage alloc] initWithContentsOfFile:itemImagePath];
        
        NSMenuItem *currentItem = [[NSMenuItem alloc] initWithTitle:key action:@selector(updateDns:) keyEquivalent:@""];
        [currentItem setToolTip:value];
        [currentItem setImage:itemImage];
        [self.statusMenu addItem: currentItem];
    }];
    
    
    // Networks adapters
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.wifiAdapterItem setToolTip:@"Enabled/Disabled DNS change to Wi-Fi Network Adapter"];
    [self.wifiAdapterItem setEnabled:YES];
    [self.wifiAdapterItem setState:YES];
    [self.statusMenu addItem: self.wifiAdapterItem];
    
    [self.ethernetAdapterItem setToolTip:@"Enabled/Disabled DNS change to Ethernet Adapter"];
    [self.ethernetAdapterItem setEnabled:YES];
    [self.ethernetAdapterItem setState:YES];
    [self.statusMenu addItem: self.ethernetAdapterItem];
    
    
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
    if ( [_wifiAdapterItem state] == YES) {
        [self doUpdateDns:menuItem:@"Wi-Fi "];
    }
    
    if ( [_ethernetAdapterItem state] == YES) {
        [self doUpdateDns:menuItem: @"'Thunderbolt Ethernet' "];
    }
    
    
    // Update status menu bar
    [self updateStatusBar:menuItem];
}

- (IBAction) doUpdateDns:(NSMenuItem *) menuItem :(NSString *) device {
    NSString* terminalCmd = [@"networksetup -setdnsservers " stringByAppendingString:device];
    terminalCmd = [terminalCmd stringByAppendingString:menuItem.toolTip];
    
    // Exec bash command
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash/";
    NSArray* aditionalParameters = [NSArray arrayWithObjects:@"-c", terminalCmd, nil];
    task.arguments  = aditionalParameters;
    [task launch];
    [task waitUntilExit];
}

- (IBAction)doNetAdapters:(NSMenuItem *)menuItem
{
    [menuItem setState: ![menuItem state]];
}

- (void)updateStatusBar:(NSMenuItem *)menuItem
{
    NSString *imageStr = [NSString stringWithFormat: @"%@%@%@", @"/", [menuItem.title lowercaseString], @".png"];
    NSString *itemImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:imageStr];
    NSImage *itemImage = [[NSImage alloc] initWithContentsOfFile:itemImagePath];
    
    [self.statusItem setTitle:menuItem.title];
    [self.statusItem setImage:itemImage];
}

- (void)buildGoogleItem
{
    NSString *googleImagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/google.png"];
    NSImage *googleImage = [[NSImage alloc] initWithContentsOfFile:googleImagePath];
    NSMenuItem *googleItem = [[NSMenuItem alloc] initWithTitle:@"Google" action:@selector(updateDns:) keyEquivalent:@""];
    [googleItem setToolTip:@"8.8.8.8"];
    [googleItem setImage:googleImage];
    [googleItem setEnabled:YES];
    [self.statusMenu addItem: googleItem];
}

- (IBAction)exitApp:(NSMenuItem *)menuItem
{
    exit(0);
}

@end
