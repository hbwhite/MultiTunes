//
//  RootViewController.h
//  MultiTunes
//
//  Created by Harrison White on 2/14/12.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TextInputViewController.h"

#import "GADBannerView.h"

@class TextFieldAlert;
@class GADBannerView;

enum {
    kTextInputTypeCreateLibrary = 0,
    kTextInputTypeRenameLibrary
};
typedef NSUInteger kTextInputType;

@interface RootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, TextInputViewControllerDelegate, GADBannerViewDelegate> {
    IBOutlet UIBarButtonItem *editButton;
    UIBarButtonItem *doneButton;
    IBOutlet UIBarButtonItem *addButton;
    IBOutlet UITableView *theTableView;
    NSInteger renameRow;
    kTextInputType textInputType;
    GADBannerView *bannerView;
    NSInteger selectedRow;
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, assign) UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic) NSInteger renameRow;
@property (nonatomic) kTextInputType textInputType;
@property (nonatomic, assign) GADBannerView *bannerView;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)editButtonPressed;
- (void)doneButtonPressed;
- (IBAction)addButtonPressed;
- (void)addLibraryWithTitle:(NSString *)title;
- (NSString *)pathForLibraryWithFolderIndex:(NSInteger)folderIndex;
- (NSString *)temporaryLibraryPath;
- (void)saveContext;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (BOOL)_switchWithLibraryWithFolderIndex:(NSInteger)folderIndex;
- (void)switchToLibraryAtIndexPath:(NSIndexPath *)indexPath;

@end
