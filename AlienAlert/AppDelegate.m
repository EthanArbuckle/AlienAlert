//
//  AppDelegate.m
//  AlienAlert
//
//  Created by Ethan Arbuckle on 7/19/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import "AppDelegate.h"
#import "RedditBotKit.h"
#import "LaunchAtLoginController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    bot = [[RedditBotKit alloc] init];
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"statusicon.png"]];
    menu = [[NSMenu alloc] init];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@"q"];
    [menu addItem:quit];
    [menu setMinimumWidth:170];
    [statusItem setMenu:menu];
    [statusItem setHighlightMode:NO];
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:YES];
    [self startChecks];
    [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(startChecks) userInfo:nil repeats:YES];
}

- (void)startChecks {
    NSURL *url = [NSURL URLWithString:@"http://reddit.com/r/AlienBlue/new/.json?limit=100"];
    NSString *json = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    if (json) {
        NSDictionary *posts = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasRunBefore"]) {
            for (NSDictionary *post in [[posts objectForKey:@"data"] objectForKey : @"children"]) {
                if (![bot postAlreadyWorked:[[post objectForKey:@"data"] objectForKey:@"id"]]) {
                    [bot markPostAsDone:[[post objectForKey:@"data"] objectForKey:@"id"]];
                    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
                    NSUserNotification *notif = [[NSUserNotification alloc] init];
                    [notif setTitle:@"New Post in /r/AlienBlue"];
                    [notif setSubtitle:[[post objectForKey:@"data"] objectForKey:@"title"]];
                    [notif setSoundName:NSUserNotificationDefaultSoundName];
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notif];
                }
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasRunBefore"];
            for (NSDictionary *mark in [[posts objectForKey:@"data"] objectForKey : @"children"]) {
                [bot markPostAsDone:[[mark objectForKey:@"data"] objectForKey:@"id"]];
            }
        }
    }
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    [center removeDeliveredNotification:notification];
}

- (void)quit {
    [[NSApplication sharedApplication] terminate:nil];
}

@end