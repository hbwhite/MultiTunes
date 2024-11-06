//
//  MultiTunesAppDelegate.m
//  MultiTunes
//
//  Created by Harrison White on 2/14/12.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "MultiTunesAppDelegate.h"
#import "RootViewController.h"

static NSString *kWelcomeMessageShownKey    = @"Welcome Message Shown";

@implementation MultiTunesAppDelegate

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:[self applicationDocumentsDirectory]]) {
		NSError *error = nil;
		if (![[NSFileManager defaultManager]createDirectoryAtPath:[self applicationDocumentsDirectory] withIntermediateDirectories:NO attributes:nil error:&error]) {
			[self abortWithError:error];
		}
    }
    
    RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:kWelcomeMessageShownKey]) {
        UIAlertView *welcomeAlert = [[UIAlertView alloc]
                                     initWithTitle:@"Welcome to MultiTunes!"
                                     message:@"IMPORTANT: This app does NOT sync apps with multiple libraries, so be sure to only sync apps with your default library. Before downloading content from the iTunes app, make sure your default library is selected in this app. Otherwise, your content may not download properly.\n\nMultiTunes allows you to sync with as many iTunes libraries as you want! To get started, press the add button in the upper right hand corner of the screen to add a new library. Tap the library in the list to switch to it, then sync with another iTunes library to add content to your new library. You can add as many libraries as you want as long as there is enough space on your device. Then, use this app to switch between your libraries whenever you want."
                                     delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
        [welcomeAlert show];
        [welcomeAlert release];
    }
    
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kWelcomeMessageShownKey];
    [defaults synchronize];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if (([managedObjectContext hasChanges]) && (![managedObjectContext save:&error])) {
            [self abortWithError:error];
        } 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc]init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory]stringByAppendingPathComponent:@"Data.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        [self abortWithError:error];
    }    
    
    return persistentStoreCoordinator;
}

- (void)abortWithError:(NSError *)error {
    /*
     Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
     
     Typical reasons for an error here include:
     * The persistent store is not accessible
     * The schema for the persistent store is incompatible with current managed object model
     Check the error message to determine what the actual problem was.
     */
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return @"/private/var/mobile/Library/MultiTunes/";
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [navigationController release];
    [window release];
    [super dealloc];
}


@end

