//
//  OptionsViewController.m
//  eBorder
//
//  Created by Bilal Itani on 3/31/14.
//  Copyright (c) 2014 SITA. All rights reserved.
//

#import "OptionsViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "PaxModalViewController.h"
#import "Language.h"
#import <CoreText/CoreText.h>

@interface OptionsViewController ()
{
    NSMutableArray *displayedCountries;
    UIButton *clearBtn;
}
@end

@implementation OptionsViewController

@synthesize tableView = _tableView;
@synthesize delegate = _delegate;
@synthesize listOfOptions = _listOfOptions;
@synthesize selectedOptions = _selectedOptions;
@synthesize tag = _tag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if([self.Filter isEqual:@"True"])
        {
            self.tableView.frame = CGRectMake(0, 88, 500, 300);
        }
    }else{
        if([self.Filter isEqual:@"True"])
        {
            self.tableView.frame = CGRectMake(0, 88, 320, 477);
        }
    }

    _searchBar.placeholder = [Language getLocalizedStringByKey:@"Search Airlines"];
    
    //add navigation buttons
    _myView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 65, 42)];
    UILabel *Back = [[UILabel alloc] initWithFrame:CGRectMake(12, -1, 60, 30)];
    Back.text = [Language getLocalizedStringByKey:@"Cancel"];
    Back.font = [UIFont fontWithName:@"Helvetica" size:15];
    Back.backgroundColor = [UIColor clearColor];
    Back.textColor = [UIColor blueColor];
    
    CGSize textSize = [Back.text  sizeWithAttributes:@{NSFontAttributeName: Back.font}];
    Back.frame = CGRectMake(15, -1, textSize.width, 30);
    _myView.frame = CGRectMake(0, 0, textSize.width+30, 42);
    
    if([[[UIDevice currentDevice] systemVersion] integerValue ] == 7) {
        _myView.frame = CGRectMake(-10, 0, textSize.width+30, 42);
    }
    
    [_myView addSubview:Back];
    
    UITapGestureRecognizer *BackGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelOptionClicked:)];
    BackGestureRecognizer.numberOfTapsRequired = 1;
    _myView.userInteractionEnabled = YES;
    
    UIButton *BackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    BackButton.frame = CGRectMake(0, 5, textSize.width+15, 30);
    [BackButton addGestureRecognizer:BackGestureRecognizer];
    [BackButton addSubview:_myView];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:BackButton];
    self.NavigationBar.topItem.leftBarButtonItem = barItem;

    #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

    self.NavigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:15]};
    self.headNavigationBar.title = self.optionViewTitle;
    
    displayedCountries = [[NSMutableArray alloc] init];
    displayedCountries = _listOfOptions;
    for(int i = 0; i < [_searchBar.subviews count]; i++) {
        if([[_searchBar.subviews objectAtIndex:i]
            isKindOfClass:[UITextField class]])
        {[(UITextField*)[_searchBar.subviews objectAtIndex:i]
          setFont:[UIFont
                   fontWithName:@"Helvetica" size:15]];
        }
    }
    
    if(self.tag == 6){
        [_tableView setAllowsMultipleSelection:YES];
    }
    
    [self.tableView reloadData];
}

-(void) viewWillAppear: (BOOL) animated {
    [super viewWillAppear: animated];
}

- (void)viewWillLayoutSubviews
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [super viewWillLayoutSubviews];
        self.view.superview.bounds = CGRectMake(0, 0, 500, 400);
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int rowCount;

        if(self.isFiltered)
            rowCount = _filteredTableData.count;
        else
            rowCount = [displayedCountries count] / 2;
    return rowCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        if([self.isSSR isEqualToString:@"Yes"])
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        else
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [cell setBackgroundColor:[UIColor whiteColor]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.imageView.image = nil;
    cell.textLabel.text = nil;
    for (UIView *subview in [[cell contentView] subviews]){
        [subview removeFromSuperview];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    
    NSMutableDictionary *cellData = [[NSMutableDictionary alloc] init];
    NSString *cellDataFromArray = @"";
    
    if(self.tag == 1 || self.tag == 2 || self.tag == 4 || self.tag == 5 || self.tag == 6)
    {
        if([self.Filter isEqual:@"True"])
        {
            if(self.isFiltered){
                if(self.tag != 6){
                    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"code" ascending:YES];
                    [_filteredTableData sortUsingDescriptors:[NSMutableArray arrayWithObject:sorter]];
                    cellData = [_filteredTableData objectAtIndex:indexPath.row];
                }else{
                    cellDataFromArray =  [_filteredTableData objectAtIndex:indexPath.row];
                }
            }else{
                if(self.tag != 6)
                    cellData = [displayedCountries objectAtIndex:indexPath.row];
                else{
                    NSString *currIndex = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
                    cellDataFromArray =  [displayedCountries objectAtIndex:indexPath.row];
                    if([_selectedOptions containsObject:currIndex]){
                        [tableView selectRowAtIndexPath:indexPath animated:TRUE scrollPosition:UITableViewScrollPositionNone];
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                }
            }
        }
    
    }else{
        if(self.isFiltered)
        {
            [_filteredTableData sortedArrayUsingSelector:@selector(compare:)];
            [cellData setValue:[_filteredTableData objectAtIndex:indexPath.row] forKey:@"Airline"];
        }else{
            [cellData setValue:[displayedCountries objectAtIndex:indexPath.row * 2 + 1] forKey:@"Airline"];
        }
    }
    
    
    if(self.tag == 3)
    {
            UILabel *code=[[UILabel alloc] initWithFrame:CGRectMake(10, 2 , 310, 20)];
            UILabel *Description=[[UILabel alloc] initWithFrame:CGRectMake(10, 22 , 310, 20)];
            
            Description.text=[cellData objectForKey:@"Airline"];
            //code.text = [cellData objectForKey:@"Airline"];
            Description.textColor=[UIColor blackColor];
            Description.font=[ UIFont fontWithName: @"Helvetica-Bold" size: 18 ];
            code.textColor=[UIColor grayColor];
            code.font=[ UIFont fontWithName: @"Helvetica" size: 14 ];
            [cell.contentView addSubview:Description];
            //[cell.contentView addSubview:code];
    }
    else
    {
        if(self.tag != 6){
            if ([cellData objectForKey:@"Name"]) {
                cell.textLabel.text = [cellData objectForKey:@"Name"];
            }
            
            if ([cellData objectForKey:@"Abbreviation"]) {
                
                 UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[cellData objectForKey:@"Abbreviation"] lowercaseString]]];
                
                cell.imageView.image = [self imageWithImage:image scaledToSize:CGSizeMake(48, 40)];
                
                [cell.imageView setFrame:CGRectMake(10, (44-30)/2, 30, 30)];
            }
        }else{
            cell.textLabel.text = cellDataFromArray;
        }
        
    }
    
    return cell;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *airLineData = @"";
        if(self.isFiltered)
            airLineData = [_filteredTableData objectAtIndex:indexPath.row];
        else
            airLineData = [displayedCountries objectAtIndex:indexPath.row*2+1];
        
        NSMutableDictionary *fill_OptionInTextField = [[NSMutableDictionary alloc] init];
        
        [displayedCountries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if( [obj isEqualToString:airLineData] ){
                    [fill_OptionInTextField setValue:[displayedCountries objectAtIndex:idx] forKey:@"Name"];
                    [fill_OptionInTextField setValue:[displayedCountries objectAtIndex:idx-1] forKey:@"Abbreviation"];
                    *stop = YES;
                }
            }];
    self.delegate.airlineValue.text = [fill_OptionInTextField objectForKey:@"Abbreviation"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tag == 6){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(IBAction)cancelOptionClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    _filteredTableData = nil;
    _isFiltered = NO;
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    _filteredTableData = nil;
    _isFiltered = NO;
    [textField resignFirstResponder];
    self.tableView.hidden=TRUE;
    return YES;
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    NSString * searchStr = text;
    
    if ([searchStr isEqualToString:@""]){
        _isFiltered = NO;
    }else{
        _isFiltered = YES;
        _filteredTableData = [[NSMutableArray alloc] init];
        
        if(self.tag == 1 || self.tag == 2 || self.tag == 4 || self.tag == 5 || self.tag == 6){
            if(self.tag != 6){
                for (NSDictionary *CountriesData in displayedCountries)
                {
                    NSRange Abbreviation = [ [CountriesData objectForKey:@"Abbreviation"] rangeOfString:searchStr options:NSCaseInsensitiveSearch];
                    NSRange name = [ [CountriesData objectForKey:@"Name"] rangeOfString:searchStr options:NSCaseInsensitiveSearch];
                    
                    
                    if(Abbreviation.location != NSNotFound || name.location != NSNotFound )
                    {
                        [_filteredTableData addObject:CountriesData];
                    }
                }
            }else{
                for (NSString *ArrayData in displayedCountries)
                {
                    NSRange name = [ ArrayData rangeOfString:searchStr options:NSCaseInsensitiveSearch];
                    if(name.location != NSNotFound)
                    {
                        [_filteredTableData addObject:ArrayData];
                    }
                }
            }
            
        }else{
            
            _isFiltered = YES;
            _filteredTableData = [[NSMutableArray alloc] init];
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            NSMutableArray *tempArray2 = [[NSMutableArray alloc] init];
            
            for(int i = 1; i < [displayedCountries count]; i += 2){
                NSString *airLineData = [displayedCountries objectAtIndex:i];
                NSString *airLineCode = [displayedCountries objectAtIndex:i-1];
                
                if( [[airLineCode lowercaseString]hasPrefix:[searchStr lowercaseString]] ){
                    [tempArray addObject:airLineData];
                }
            }
            
            for(int i = 1; i < [displayedCountries count]; i += 2){
                NSString *airLineData = [displayedCountries objectAtIndex:i];
                if( [[airLineData lowercaseString] hasPrefix:[searchStr lowercaseString]] ){
                    if( ![tempArray containsObject: airLineData] )
                        [tempArray addObject:airLineData];
                }
            }
            
            for(int i = 1; i < [displayedCountries count]; i += 2){
                NSString *airLineData = [displayedCountries objectAtIndex:i];
                NSRange name = [airLineData rangeOfString:searchStr options:NSCaseInsensitiveSearch];
                if(name.location != NSNotFound)
                {
                    if( ![tempArray containsObject: airLineData] )
                        [tempArray2 addObject:airLineData];
                }
            }
            
            _filteredTableData = [[tempArray arrayByAddingObjectsFromArray:tempArray2] mutableCopy];
        }
    }
    [self.tableView reloadData];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

