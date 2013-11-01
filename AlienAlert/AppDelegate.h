//
//  AppDelegate.h
//  AlienAlert
//
//  Created by Ethan Arbuckle on 7/19/13.
//  Copyright (c) 2013 Ethan Arbuckle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RedditBotKit.h"

@interface NSUserNotificationCenter (Private)
- (void)_removeAllDisplayedNotifications;
- (void)_removeDisplayedNotification:(NSUserNotification *)notification;
@end


@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    RedditBotKit *bot;
    NSMenu *menu;
    NSStatusItem *statusItem;
}

@property (assign) IBOutlet NSWindow *window;

@end

