//
//  RootViewController.m
//  MultiTunes
//
//  Created by Harrison White on 2/14/12.
//  Copyright 2012 Harrison Apps, LLC. All rights reserved.
//

#import "RootViewController.h"

static NSString *kAdUnitID              = @"a14f3afdb0ee567";

static NSString *kTitleKey              = @"title";
static NSString *kFolderIndexKey        = @"folderIndex";
static NSString *kSelectedKey           = @"selected";

static NSString *kLibraryPathPrefixStr  = @"/private/var/mobile/Media/iTunes_Control";

@implementation RootViewController

@synthesize editButton;
@synthesize doneButton;
@synthesize addButton;
@synthesize theTableView;
@synthesize renameRow;
@synthesize textInputType;
@synthesize bannerView;
@synthesize selectedRow;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

- (IBAction)editButtonPressed {
    self.navigationItem.leftBarButtonItem = doneButton;
    [theTableView setEditing:YES animated:YES];
}

- (void)doneButtonPressed {
    self.navigationItem.leftBarButtonItem = editButton;
    [theTableView setEditing:NO animated:YES];
}

- (IBAction)addButtonPressed {
    textInputType = kTextInputTypeCreateLibrary;
    
    TextInputViewController *textInputViewController = [[TextInputViewController alloc]initWithNibName:@"TextInputViewController" bundle:nil];
    textInputViewController.delegate = self;
    textInputViewController.navigationBarTitle = @"Add New Library";
    textInputViewController.header = @"Please enter a name for the new library:";
    textInputViewController.placeholder = @"Library Name";
    [self presentModalViewController:textInputViewController animated:YES];
    [textInputViewController release];
}

- (void)addLibraryWithTitle:(NSString *)title {
    NSInteger folderIndex = 2;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    while ([fileManager fileExistsAtPath:[self pathForLibraryWithFolderIndex:folderIndex]]) {
        folderIndex += 1;
    }
    NSError *error = nil;
    [fileManager createDirectoryAtPath:[self pathForLibraryWithFolderIndex:folderIndex] withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error Creating Library"
                                   message:@"The app encountered an error while trying to create a new library. Please make sure the app has read and write access to the directory at /var/mobile/Media and try again."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert release];
    }
    else {
        // Create a new instance of the entity managed by the fetched results controller.
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[fetchedResultsController fetchRequest]entity];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
        // If appropriate, configure the new managed object.
        [newManagedObject setValue:title forKey:kTitleKey];
        [newManagedObject setValue:[NSNumber numberWithInteger:folderIndex] forKey:kFolderIndexKey];
        [newManagedObject setValue:[NSNumber numberWithBool:NO] forKey:kSelectedKey];
        
        [self saveContext];
        
        if (!self.navigationItem.leftBarButtonItem) {
            self.navigationItem.leftBarButtonItem = editButton;
        }
    }
}
     
- (NSString *)pathForLibraryWithFolderIndex:(NSInteger)folderIndex {
    return [kLibraryPathPrefixStr stringByAppendingFormat:@"_%i", folderIndex];
}

- (NSString *)temporaryLibraryPath {
    return [kLibraryPathPrefixStr stringByAppendingFormat:@"_Temp"];
}

- (void)saveContext {
    // Save the context.
    NSError *error = nil;
    if (![[fetchedResultsController managedObjectContext]save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)textInputViewControllerDidReceiveTextInput:(NSString *)text {
    if (textInputType == kTextInputTypeCreateLibrary) {
        [self addLibraryWithTitle:text];
    }
    else {
        NSManagedObject *library = [[[self fetchedResultsController]fetchedObjects]objectAtIndex:renameRow];
        [library setValue:text forKey:kTitleKey];
        [self saveContext];
        renameRow = 0;
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *error = nil;
    if (![[self fetchedResultsController]performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    selectedRow = -1;
    NSArray *fetchedObjectsArray = [[self fetchedResultsController]fetchedObjects];
    for (int i = 0; i < [fetchedObjectsArray count]; i++) {
        if ([[[fetchedObjectsArray objectAtIndex:i]valueForKey:kSelectedKey]isEqual:[NSNumber numberWithBool:YES]]) {
            selectedRow = i;
            break;
        }
    }
    [theTableView reloadData];
    
    if ([fetchedObjectsArray count] <= 0) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    
    bannerView = [[GADBannerView alloc]initWithFrame:CGRectMake(0, 366, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
	bannerView.adUnitID = kAdUnitID;
	bannerView.delegate = self;
	bannerView.rootViewController = self;
	
	GADRequest *request = [GADRequest request];
	request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, @"7cea9eca140af13f42de31d594022cc85864ce6a", nil];
	
	[bannerView loadRequest:request];
    
    [self.view addSubview:bannerView];
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
	theTableView.frame = CGRectMake(0, 0, 320, 366);
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
	theTableView.frame = CGRectMake(0, 0, 320, 416);
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Default Library";
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:0.35 blue:0 alpha:1];
        if (selectedRow == -1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
    }
    else {
        NSManagedObject *managedObject = [[fetchedResultsController fetchedObjects]objectAtIndex:indexPath.row];
        cell.textLabel.text = [[managedObject valueForKey:kTitleKey]description];
        if ([[managedObject valueForKey:kSelectedKey]isEqual:[NSNumber numberWithBool:YES]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections]objectAtIndex:(section - 1)];
        return [sectionInfo numberOfObjects];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Default Library";
    }
    else {
        return @"Additional Libraries";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = nil;
    if (indexPath.section == 0) {
        CellIdentifier = @"Cell 1";
    }
    else {
        CellIdentifier = @"Cell 2";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return (indexPath.section != 0);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *library = [[fetchedResultsController fetchedObjects]objectAtIndex:indexPath.row];
        if ([[library valueForKey:kSelectedKey]isEqual:[NSNumber numberWithBool:YES]]) {
            [self switchToLibraryAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
        
        NSError *error = nil;
        [[NSFileManager defaultManager]removeItemAtPath:[self pathForLibraryWithFolderIndex:[[library valueForKey:kFolderIndexKey]integerValue]] error:&error];
        if (error) {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"Error Deleting Library"
                                       message:@"The app encountered an error while trying to delete this library. Please make sure the app has read and write access to the directory at /var/mobile/Media."
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
            [errorAlert show];
            [errorAlert release];
        }
        
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        [context deleteObject:library];
        
        [self saveContext];
        
        if ([[[self fetchedResultsController]fetchedObjects]count] <= 0) {
            self.navigationItem.leftBarButtonItem = nil;
            [theTableView setEditing:NO animated:NO];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.leftBarButtonItem = doneButton;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.leftBarButtonItem = editButton;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    renameRow = indexPath.row;
    textInputType = kTextInputTypeRenameLibrary;
    
    TextInputViewController *textInputViewController = [[TextInputViewController alloc]initWithNibName:@"TextInputViewController" bundle:nil];
    textInputViewController.delegate = self;
    textInputViewController.navigationBarTitle = @"Rename Library";
    textInputViewController.header = @"Please enter a new name for this library:";
    textInputViewController.placeholder = @"New Library Name";
    [self presentModalViewController:textInputViewController animated:YES];
    [textInputViewController release];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc]initWithNibName:@"<#Nib name#>" bundle:nil];
     NSManagedObject *selectedObject = [[self fetchedResultsController]objectAtIndexPath:indexPath];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    [self switchToLibraryAtIndexPath:indexPath];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)_switchWithLibraryWithFolderIndex:(NSInteger)folderIndex {
    NSString *selectedLibraryPath = [self pathForLibraryWithFolderIndex:folderIndex];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    // Move the contents of the selected library directory (which are the default library's contents if switching back to the default library) to the temporary directory.
    [fileManager moveItemAtPath:selectedLibraryPath toPath:[self temporaryLibraryPath] error:&error];
    
    // Move the contents of the default library directory (which are the selected library's contents if switching back to the default library) to the selected library directory.
    [fileManager moveItemAtPath:kLibraryPathPrefixStr toPath:selectedLibraryPath error:&error];
    
    // Move the contents of the temporary directory (which are the default library's contents if switching back to the default library) to the default library directory.
    [fileManager moveItemAtPath:[self temporaryLibraryPath] toPath:kLibraryPathPrefixStr error:&error];
    
    if (error) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error Switching Libraries"
                                   message:@"The app encountered an error while trying to switch libraries. Please make sure the app has read and write access to the directory at /var/mobile/Media and try again."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert release];
        
        return NO;
    }
    else {
        return YES;
    }
}

- (void)switchToLibraryAtIndexPath:(NSIndexPath *)indexPath {
    if (((indexPath.section == 0) && (selectedRow != -1)) || ((indexPath.section != 0) && (indexPath.row != selectedRow))) {
        NSArray *fetchedObjectsArray = [[self fetchedResultsController]fetchedObjects];
        
        if (indexPath.section == 0) {
            NSManagedObject *previousLibrary = [fetchedObjectsArray objectAtIndex:selectedRow];
            NSInteger previousLibraryFolderIndex = [[previousLibrary valueForKey:kFolderIndexKey]integerValue];
            
            [self _switchWithLibraryWithFolderIndex:previousLibraryFolderIndex];
        }
        else {
            // Switching to another library.
            
            NSManagedObject *newLibrary = [fetchedObjectsArray objectAtIndex:indexPath.row];
            NSInteger newLibraryFolderIndex = [[newLibrary valueForKey:kFolderIndexKey]integerValue];
            
            if (selectedRow != -1) {
                NSManagedObject *previousLibrary = [fetchedObjectsArray objectAtIndex:selectedRow];
                NSInteger previousLibraryFolderIndex = [[previousLibrary valueForKey:kFolderIndexKey]integerValue];
                
                if (![self _switchWithLibraryWithFolderIndex:previousLibraryFolderIndex]) {
                    return;
                }
            }
            
            if (![self _switchWithLibraryWithFolderIndex:newLibraryFolderIndex]) {
                return;
            }
        }
        
        if (indexPath.section != 0) {
            [[fetchedObjectsArray objectAtIndex:indexPath.row]setValue:[NSNumber numberWithBool:YES] forKey:kSelectedKey];
        }
        if (selectedRow != -1) {
            [[fetchedObjectsArray objectAtIndex:selectedRow]setValue:[NSNumber numberWithBool:NO] forKey:kSelectedKey];
        }
        [self saveContext];
        
        NSInteger previouslySelectedRow = selectedRow;
        if (indexPath.section == 0) {
            selectedRow = -1;
            [self configureCell:[theTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:previouslySelectedRow inSection:1];
            [self configureCell:[theTableView cellForRowAtIndexPath:indexPath2] atIndexPath:indexPath2];
        }
        else {
            selectedRow = indexPath.row;
            [self configureCell:[theTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            if (previouslySelectedRow == -1) {
                NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:0];
                [self configureCell:[theTableView cellForRowAtIndexPath:indexPath2] atIndexPath:indexPath2];
            }
            else {
                NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:previouslySelectedRow inSection:1];
                [self configureCell:[theTableView cellForRowAtIndexPath:indexPath2] atIndexPath:indexPath2];
            }
        }
        
        [theTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        // Kill the Music app.
        system("killall MobileMusicPlayer");
        system("killall Music~iphone");
        system("killall Music~ipad");
        
        // Kill the Videos app.
        system("killall Videos");
        
        // Kill the iTunes Store app.
        system("killall MobileStore");
        
        // Kill the App Store app.
        system("killall AppStore");
        
        // Kill the Camera app.
        system("killall Camera");
        
        // Kill the Photos app.
        system("killall MobileSlideShow");
    }
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Library" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:kTitleKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    return fetchedResultsController;
}    


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [theTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [theTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [theTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = theTableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:newIndexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            NSIndexPath *revisedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:1];
            [self configureCell:[tableView cellForRowAtIndexPath:revisedIndexPath] atIndexPath:revisedIndexPath];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:newIndexPath.row inSection:1]]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [theTableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [theTableView reloadData];
}
*/

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    
    self.editButton = nil;
    self.doneButton = nil;
    self.addButton = nil;
    self.theTableView = nil;
    self.bannerView = nil;
    self.fetchedResultsController = nil;
    self.managedObjectContext = nil;
}


- (void)dealloc {
    [editButton release];
    [doneButton release];
    [addButton release];
    [theTableView release];
    [bannerView release];
    [fetchedResultsController release];
    [managedObjectContext release];
    [super dealloc];
}


@end

