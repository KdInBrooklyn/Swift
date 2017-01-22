//
//  RWTableViewController.m
//  UDo
//
//  Created by Soheil Azarpour on 12/21/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//https://www.raywenderlich.com/63089/cookbook-moving-table-view-cells-with-a-long-press-gesture

#import "RWTableViewController.h"
#import "RWBasicTableViewCell.h"
#import "UIAlertView+RWBlock.h"

@interface RWTableViewController ()

/** @brief An array of NSString objects, data source of the table view. */
@property (strong, nonatomic) NSMutableArray *objects;

@end

@implementation RWTableViewController

#pragma mark - Custom accessors

- (NSMutableArray *)objects {
  if (!_objects) {
    _objects = [@[@"Get Milk!", @"Go to gym", @"Breakfast with Rita!", @"Call Bob", @"Pick up newspaper", @"Send an email to Joe", @"Read this tutorial!", @"Pick up flowers"] mutableCopy];
  }
  return _objects;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
  self.title = @"To Do!";
  [super viewDidLoad];
  
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
  [self.tableView addGestureRecognizer:longPress];
}

#pragma mark - Event response

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gesture {
  UIGestureRecognizerState state = gesture.state;
  
  CGPoint location = [gesture locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
  
  static UIView *snapShot = nil;
  static NSIndexPath *sourceIndexPath = nil;
  
  switch (state) {
    case UIGestureRecognizerStateBegan: {
      if (indexPath) {
        sourceIndexPath = indexPath;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        snapShot = [self customSnapShotFromView:cell];
        
        __block CGPoint center = cell.center;
        snapShot.center = center;
        snapShot.alpha = 0.0;
        [self.tableView addSubview:snapShot];
        [UIView animateWithDuration:0.25 animations:^{
          center.y = location.y;
          snapShot.center = center;
          snapShot.transform = CGAffineTransformMakeScale(1.05, 1.05);
          snapShot.alpha = 0.98;
        } completion:^(BOOL finished) {
          cell.hidden = YES;
        }];
        
      }
      break;
    }
    case UIGestureRecognizerStateChanged: {
      CGPoint center = snapShot.center;
      center.y = location.y;
      snapShot.center = center;
      
      if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
        [self.objects exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
        [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
        sourceIndexPath = indexPath;
      }
      
      break;
    }
    default: {
      UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
      cell.hidden = NO;
      cell.alpha = 0.0;
      
      [UIView animateWithDuration:0.25 animations:^{
        snapShot.center = cell.center;
        snapShot.transform = CGAffineTransformIdentity;
        snapShot.alpha = 0.0;
        
        cell.alpha = 1.0;
      } completion:^(BOOL finished) {
        sourceIndexPath = nil;
        [snapShot removeFromSuperview];
        snapShot = nil;
      }];
      
      break;
    }
  }
}

#pragma mark private method
//生成截图
- (UIView *)customSnapShotFromView: (UIView *)inputView {
  UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0.0);
  [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  UIView *snapshot = [[UIImageView alloc] initWithImage:image];
  snapshot.layer.masksToBounds = NO;
  snapshot.layer.cornerRadius = 0.0;
  snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
  snapshot.layer.shadowRadius = 5.0;
  snapshot.layer.shadowOpacity = 0.4;
  
  return snapshot;
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kIdentifier = @"Cell Identifier";
  
  RWBasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier forIndexPath:indexPath];
  
  // Update cell content from data source.
  NSString *object = self.objects[indexPath.row];
  cell.titleLabel.text = object;
  
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.objects removeObjectAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - IBActions

- (IBAction)addButtonPressed:(id)sender {
  
  // Display an alert view with a text input.
  UIAlertView *inputAlertView = [[UIAlertView alloc] initWithTitle:@"Add a new to-do item:" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Add", nil];
  
  inputAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  
  __weak RWTableViewController *weakself = self;
  
  // Add a completion block (using our category to UIAlertView).
  [inputAlertView setCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
    
    // If user pressed 'Add'...
    if (buttonIndex == 1) {
      
      UITextField *textField = [alertView textFieldAtIndex:0];
      NSString *string = [textField.text capitalizedString];
      [weakself.objects addObject:string];
      
      NSUInteger row = [weakself.objects count] - 1;
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
      [weakself.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
  }];
  
  [inputAlertView show];
}

@end
