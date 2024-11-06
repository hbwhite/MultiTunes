//
//  TextInputViewController.h
//  MultiTunes
//
//  Created by Harrison White on 2/17/12.
//  Copyright (c) 2012 Harrison Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextInputViewControllerDelegate;

@interface TextInputViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    id <TextInputViewControllerDelegate> delegate;
    
    IBOutlet UINavigationBar *theNavigationBar;
    IBOutlet UIBarButtonItem *cancelButton;
    IBOutlet UIBarButtonItem *doneButton;
    IBOutlet UITableView *theTableView;
    NSString *navigationBarTitle;
    NSString *header;
    NSString *placeholder;
}

@property (nonatomic, assign) id <TextInputViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UINavigationBar *theNavigationBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, assign) IBOutlet UITableView *theTableView;
@property (nonatomic, assign) NSString *navigationBarTitle;
@property (nonatomic, assign) NSString *header;
@property (nonatomic, assign) NSString *placeholder;

@end

@protocol TextInputViewControllerDelegate <NSObject>

@optional

- (void)textInputViewControllerDidReceiveTextInput:(NSString *)text;

@end
