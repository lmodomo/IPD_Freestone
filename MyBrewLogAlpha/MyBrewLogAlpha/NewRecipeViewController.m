// Elijah Freestone
// IPY 1504
// Week 1 - Alpha
// March 30th, 2015

//
//  NewRecipeViewController.m
//  MyBrewLogAlpha
//
//  Created by Elijah Freestone on 3/30/15.
//  Copyright (c) 2015 Elijah Freestone. All rights reserved.
//

#import "NewRecipeViewController.h"
#import "ActionSheetStringPicker.h"
#import "ActionSheetDatePicker.h"
#import "ActionSheetCustomPickerDelegate.h"
#import "ActionSheetCustomPicker.h"
#import "ActionSheetDistancePicker.h"
#import "DistancePickerView.h"
#import "CustomPickerDelegate.h"
#import "CustomTimerPickerDelegate.h"
#import <Parse/Parse.h>

@interface NewRecipeViewController () <UIActionSheetDelegate> {
    NSArray *recipeTypes;
    NSArray *ingredientArray;
    NSDate *selectedDate;
    NSDate *selectedTime;
    AbstractActionSheetPicker *actionSheetPicker;
    
    NSInteger selectedBigUnit;
    NSInteger selectedSmallUnit;
    
    NSString *ingredientTVString;
    NSString *instructionsTVString;
    NSString *recipeIngredients;
    NSString *recipeInstructions;
    NSString *recipeType;
    NSString *recipeName;
    NSString *recipeNotes;
    NSString *parseClassName;
    
    id buttonSender;
}

@end

@implementation NewRecipeViewController

//Synthesize for getters/setters
@synthesize recipeNameTF, notesTF, ingredientsTV, instructionsTV;

- (void)viewDidLoad {
    [super viewDidLoad];
    //Init NSDates
    selectedDate = [NSDate date];
    selectedTime = [NSDate date];
    
    parseClassName = @"newRecipe";
    
    //Create arrays for pickers
    recipeTypes = [NSArray arrayWithObjects:@"Beer", @"Wine", @"Other", nil];
    ingredientArray = [NSArray arrayWithObjects:@"Ingedient 1", @"Ingedient 2", @"Ingedient 3", @"Ingedient 4", @"Ingedient 5", @"Ingedient 6", nil];
    
    //Set default recipe type to Other
    recipeType = @"Other";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Dismiss new recipe view on cancel
-(IBAction)onCancel:(id)sender {
    //Dismiss view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Pickers and Action Sheets
//Using ActionSheetPicker, an open source lib. Found at https://github.com/skywinder/ActionSheetPicker-3.0

//Show Recipe Type Picker
-(IBAction)showRecipeTypePicker:(id)sender {
    //Create ActionSheet for recipe types
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select a Recipe Type"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
//    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:0] setImage:[UIImage imageNamed:@"beer-bottle.png"] forState:UIControlStateNormal];
//    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:1] setImage:[UIImage imageNamed:@"wine-glass.png"] forState:UIControlStateNormal];
//    [[[actionSheet valueForKey:@"_buttons"] objectAtIndex:2] setImage:[UIImage imageNamed:@"other-icon.png"] forState:UIControlStateNormal];
//    
//    for (UIView *subview in actionSheet.subviews) {
//        if ([subview isKindOfClass:[UIButton class]]) {
//            UIButton *button = (UIButton *)subview;
//            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        }
//    }
    
    //Fast enum recipe types and apply to "other" button
    for (NSString *title in recipeTypes) {
        [actionSheet addButtonWithTitle:title];
    }
    
    actionSheet.tag = 100;
    
    [actionSheet showInView:self.view];
}

//Show Ingredients Picker
-(IBAction)showIngredientPicker:(id)sender {
    //Create picker and fill with Ingredients Array
    [ActionSheetStringPicker showPickerWithTitle:@"Add Ingredient"
                                            rows:ingredientArray
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSLog(@"Selected Value: %@", selectedValue);
                                           [self showQuantityPicker:sender];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];

}

//Show custom quantity picker. Triggered after selecting ingredient
-(void)showQuantityPicker:(id)sender {
    //Init custom picker delegate
    CustomPickerDelegate *delegate = [[CustomPickerDelegate alloc] init];
    //Set initial selections
    NSNumber *yass1 = @0;
    NSNumber *yass2 = @0;
    NSArray *initialSelections = @[yass1, yass2];
    [ActionSheetCustomPicker showPickerWithTitle:@"Select Quantity"
                                        delegate:delegate
                                showCancelButton:YES
                                          origin:sender
                               initialSelections:initialSelections];
    
}

//Show Timer Picker
-(IBAction)showTimerPicker:(id)sender {
    //Pass (id)sender to be used for launching ActionSheetPicker from reg action sheet
    buttonSender = sender;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Is timer over 24 hours?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Yes", @"No", nil];
    //Set tag and show action sheet
    actionSheet.tag = 200;
    [actionSheet showInView:self.view];
}

//Show Temp Picker
-(IBAction)showTempPicker:(id)sender {
    //Create picker using Distance. Will likely need custom for real picker or use a stepper instead.
    [ActionSheetDistancePicker showPickerWithTitle:@"Select Temperature"
                                     bigUnitString:@"."
                                        bigUnitMax:999
                                   selectedBigUnit:selectedBigUnit
                                   smallUnitString:@"°"
                                      smallUnitMax:9
                                 selectedSmallUnit:selectedSmallUnit
                                            target:self
                                            action:@selector(tempSelected:smallUnit:)
                                            origin:sender];
}

//- (void)measurementWasSelectedWithBigUnit:(NSNumber *)bigUnit smallUnit:(NSNumber *)smallUnit element:(id)element

//Grab temp selection
-(void)tempSelected:(NSNumber *)wholeNumber smallUnit:(NSNumber *)pointNumber {
    NSString *currentInst = instructionsTV.text;
//    NSString *lastChar = @"";
//    //Get last 2 char
//    if (currentInst.length >= 2) {
//        NSLog(@"Last char");
//        lastChar = [currentInst substringFromIndex: [currentInst length] - 2];
//        //[state substringFromIndex: MAX([state length] - 2, 0)];
//    }
    
    //Check if last line of string ends in new line, add before temp if it doesn't exist
    NSString *addNewLine = @"";
    if (![currentInst hasSuffix:@"\n"]) {
        NSLog(@"new line");
        addNewLine = @"\n";
    }
    
    //Remove new line if textview was empty. Behaviour isn't always as expected when including this check above
    if (currentInst.length == 0) {
        NSLog(@"Textview was empty");
        addNewLine = @"";
    }
    
    //Grab input numbers. Whole numbers are left of decimal
    selectedBigUnit = [wholeNumber intValue];
    selectedSmallUnit = [pointNumber intValue];
    NSString *formattedTemp = [NSString stringWithFormat:@"%@Temp: %ld.%ld °F \n", addNewLine, (long)selectedBigUnit, (long)selectedSmallUnit];
    //NSLog(@"Formatted %@", formattedTemp);
    
    instructionsTVString = [NSString stringWithFormat:@"%@%@", currentInst, formattedTemp];
    
    //NSLog(@"%@", instructionsTVString);
    
    instructionsTV.text = instructionsTVString;
}

#pragma mark - action sheet delegate

//Grab action sheet actions via delegate method
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    //Tag 100 is Recipe Type
    if (actionSheet.tag == 100) {
        recipeType = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSLog(@"Recipe Type = %@", recipeType);
    //Tag 200 is first timer (is 24 hours)
    } else if (actionSheet.tag == 200) {
        NSLog(@"Timer length");
        //Yes or No selected in first timer action sheet
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"No"]) {
            //Under 24 selected, show countdown picker
            NSLog(@"Under 24 hours");
            [self showCountdownPicker:buttonSender];
        } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
            //Over 24 selected, show custom M/W/D picker
            NSLog(@"Over 24 hours");
            [self showCustomTimePicker:buttonSender];
        } else {
            NSLog(@"Button title is NOT yes or no");
        }
        
    } else {
        NSLog(@"Something else selected");
    }
    
    NSLog(@"Index = %ld - Title = %@", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
}

//Show countdown picker. Triggered from selecting No to over 24 hour ActionSheet
-(void)showCountdownPicker:(id)sender {
    //Create picker and set to temer mode
    actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Under 24 hours"
                                                      datePickerMode:UIDatePickerModeCountDownTimer
                                                        selectedDate:nil
                                                           doneBlock:^(ActionSheetDatePicker *picker, id dateSelected, id origin) {
                                                               NSLog(@"dateSelected: %@", dateSelected);
                                                               NSLog(@"picker.countDownDuration, %f", picker.countDownDuration);
                                                           } cancelBlock:^(ActionSheetDatePicker *picker) {
                                                               NSLog(@"Cancel clicked");
                                                           } origin:sender];
    [(ActionSheetDatePicker *) actionSheetPicker setCountDownDuration:120];
    [actionSheetPicker showActionSheetPicker];
}

//Show custom picker. Triggered from selecting Yes to over 24 hour ActionSheet
-(void)showCustomTimePicker:(id)sender {
    //Init custom delegate
    CustomTimerPickerDelegate *timerDelegate = [[CustomTimerPickerDelegate alloc] init];
    NSNumber *comp0 = @0;
    NSNumber *comp1 = @0;
    NSNumber *comp2 = @0;
    NSNumber *comp3 = @0;
    NSNumber *comp4 = @0;
    NSNumber *comp5 = @0;
    //Set initial selections
    NSArray *initialSelections = @[comp0, comp1, comp2, comp3, comp4, comp5];

    ActionSheetCustomPicker *customPicker = [[ActionSheetCustomPicker alloc] initWithTitle:@"Select Time" delegate:timerDelegate showCancelButton:YES origin:sender initialSelections:initialSelections];
    
    [customPicker showActionSheetPicker];
}

#pragma mark - Save

//Save entered recipe to Parse
-(IBAction)onSave:(id)sender {
    //Grab text field for recipe name
    recipeName = recipeNameTF.text;
    recipeNotes = notesTF.text;
    recipeIngredients = ingredientsTV.text;
    recipeInstructions = instructionsTV.text;
    
    if (recipeName.length > 0 && instructionsTVString.length > 0) {
        //Name was entered, continue saving
        PFObject *newRecipeObject = [PFObject objectWithClassName:parseClassName];
        newRecipeObject[@"Type"] = recipeType;
        newRecipeObject[@"Name"] = recipeName;
        newRecipeObject[@"Notes"] = recipeNotes;
        newRecipeObject[@"Ingredients"] = recipeIngredients;
        newRecipeObject[@"Instructions"] = recipeInstructions;
        
        [newRecipeObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"New item saved.");
                //Dismiss add item view
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"%@", error);
                //Error alert
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured trying to save. Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            }
        }];
        
    } else {
        NSLog(@"Name required");
        NSString *alertString = @"A Recipe Name and some Instructions are required to save. Please add them and try again.";
        [self showRequiredAlert:alertString];
    }
}

#pragma mark - Alerts

//Method to create and show alert view if required items are missing
-(void)showRequiredAlert:(NSString *)alertMessage {
    UIAlertView *copyAlert = [[UIAlertView alloc] initWithTitle:@"Alert: Required" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [copyAlert show];
}

@end