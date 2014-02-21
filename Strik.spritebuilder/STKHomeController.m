//
//  STKHomeController.m
//  Strik
//
//  Created by Matthijn Dijkstra on 21/02/14.
//  Copyright (c) 2014 Strik. All rights reserved.
//

#import "STKHomeController.h"

#import "STKScene.h"
#import "STKAchievementsController.h"
#import "STKSessionController.h"

#import "STKAlertView.h"
#import "STKPLayer.h"
#import "STKOutgoingMessage.h"

#import "STKDirector.h"

@implementation STKHomeController

- (void)sceneCreated
{
	// Listen for name changes
	[self routeNetMessagesOf:NAME_CHANGED to:@selector(handleNameChanged:)];
	[self routeNetMessagesOf:NAME_REJECTED to:@selector(handleNameRejected:)];
	
	// Let the view observe the userdata models
	STKSessionController *sessionController = self.core[@"session"];
	[self.scene observeModel:(STKModel *)sessionController.user];
}

#pragma mark buttons
- (void)onAchievementsButton:(CCButton *)button
{
	STKDirector *director = self.core[@"director"];
	[director pushScene:[STKAchievementsController new] withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.25]];
}

#pragma mark Username changes
- (void)onUsernameButton:(CCButton *)button
{
	STKSessionController *sessionController = self.core[@"session"];
	
	STKAlertView *alertView = [STKAlertView promptWithTitle:NSLocalizedString(@"Change Your Name", @"Change your name title") message:NSLocalizedString(@"You can change the name people see in Strik. Think of a good one!", @"Change your name prompt text") defaultValue:sessionController.user.name target:self okSelector:@selector(confirmedUsernameChange:) andCancelSelector:nil];
	[alertView show];
}

- (void)confirmedUsernameChange:(NSString *)newUsername
{
	// Empty string might just be the placeholder. So ignore that
	if(newUsername == nil || ![newUsername isEqualToString:@""])
	{
		[self requestNameChangeTo:newUsername];
	}
}

#pragma mark Networking
- (void)requestNameChangeTo:(NSString*)newName
{
	NSLog(@"Home: asking server for name change to \"%@\"", newName);
	
	// Ask server for a rename
	STKOutgoingMessage* msg = [STKOutgoingMessage withOp:CHANGE_NAME];
	[msg appendStr:newName];
	[self sendNetMessage:msg];
}

- (void)handleNameChanged:(STKIncomingMessage*)msg
{
	// Read new name
	NSString* newName = [msg readStr];
	NSLog(@"Home: name changed to \"%@\"", newName);
	
	// Store new name in session
	STKSessionController* session = self.core[@"session"];
	session.user.name = newName;
}

- (void)handleNameRejected:(STKIncomingMessage*)msg
{
	// Read reason
	// TODO: Do something with the actual message (first change it to enums)
	//	NSString* name = [msg readStr];
	//	NSString* message = [msg readStr];
	
	// Notify user
	STKAlertView *alertview = [STKAlertView alertWithTitle:NSLocalizedString(@"Name Not Allowed", @"Name not allowed title.") andMessage:NSLocalizedString(@"You like naughty names don't you? Well, we don't!", @"Name not allowed message")];
	[alertview show];
}

@end