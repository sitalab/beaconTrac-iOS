//
//  OptionsViewController.h
//  eBorder
//
//  Created by Bilal Itani on 3/31/14.
//  Copyright (c) 2014 SITA. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PaxModalViewController.h"

@protocol OptionsViewControllerDelegate;

@interface OptionsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
	CGPoint lastPoint;
	UIImageView *drawImage;
	BOOL mouseSwiped;
	int mouseMoved;
}

@property (strong, nonatomic) IBOutlet UIView *myView;
@property (strong, nonatomic) PaxModalViewController *delegate;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationItem *headNavigationBar;
@property (retain, nonatomic) IBOutlet UINavigationBar *NavigationBar;
@property (strong, nonatomic) NSMutableArray* filteredTableData;
@property (strong, nonatomic) NSMutableArray *listOfOptions;
@property (strong, nonatomic) NSMutableArray *selectedOptions;
@property (strong, nonatomic) NSString *optionViewTitle;
@property (strong, nonatomic) NSString *isSSR;
@property (strong, nonatomic) NSString *Filter;
@property (nonatomic, assign) int tag;
@property (assign, nonatomic) BOOL isFiltered;
-(IBAction)cancelOptionClicked:(id)sender;

@end

@protocol OptionsViewControllerDelegate <NSObject>

-(void)fill_OptionInTextField:(NSDictionary *)optionDictionary withTag:(int)tagValue;
-(void)close_OptionInTextField;

@end
