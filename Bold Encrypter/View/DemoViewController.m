//
//  ViewController.m
//  Bold Encrypter
//
//  Created by Ryan David Forsyth on 2020-03-12.
//  Copyright © 2020 Ryan David Forsyth. All rights reserved.
//

#import "DemoViewController.h"
#import "PrototypeTableViewCell.h"

/*Private */@interface DemoViewController ()
<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *stylizeButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSMutableArray <NSAttributedString*>* stringsToDisplay;

@end

@implementation DemoViewController

static NSString *kBold = @"!!";
static NSString *kItalic = @"//";
static NSString *kBig = @"??";

//MARK: Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    
    self.stringsToDisplay = [NSMutableArray array];
}

-(void)setupView {
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeyDone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.textField.layer.cornerRadius = 10.0;
    self.textField.layer.borderColor = UIColor.systemIndigoColor.CGColor;
    self.textField.layer.borderWidth = 2.0;
    
    self.stylizeButton.layer.cornerRadius = 5.0;
}

//MARK: Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PrototypeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"boldCell"];
    cell.mainLabel.attributedText = self.stringsToDisplay[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return; // No cell selection action
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stringsToDisplay.count;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    [self boldifyTapped:nil];
    return YES;
}

//MARK: Actions
- (IBAction)boldifyTapped:(id)_ {
    [self interpretMessageInTextField];
    [self.tableView reloadData];
}

//MARK: Business logic
-(void)interpretMessageInTextField {
    
    NSString *input = [NSString stringWithFormat:@"%@",self.textField.text];
    
    if (input.length == 0)
        return;
    
    [self clearTextField];
    
    NSAttributedString *formattedString = [self getFormattedStringFromEncryptedString:input];
    
    [self.stringsToDisplay addObject:formattedString];
}

//MARK: Helpers
-(void)clearTextField {
    self.textField.text = @"";
}

-(NSAttributedString*)getFormattedStringFromEncryptedString:(NSString*)input {
    
    NSAttributedString *decryptedString = [self checkForKeys:[self styleKeys] inEncryptedString: input];
    
    return decryptedString;
}

-(NSMutableAttributedString*)checkForKeys:(NSArray<NSString*>*)keys inEncryptedString:(NSString*)input {
    
    NSMutableArray<NSArray*>* rangesToStyle = [NSMutableArray array];
    
    for (NSString *key in keys) {
    
        while ([input containsString:key]) {
            
            NSRange firstRange = [input rangeOfString:key]; // Find first key
            
            NSMutableArray *otherKeys = [keys mutableCopy]; // Get all other keys by removing current one
            [otherKeys removeObject:key];

            NSUInteger otherKeysFoundBefore = 0, length = firstRange.location; // Count other keys found before current key

            for (NSString *otherKey in otherKeys) {
                NSRange range = NSMakeRange(0, length);
                while (range.location != NSNotFound) {
                    range = [input rangeOfString:otherKey options:0 range:range];
                    if (range.location != NSNotFound) {
                        range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                        otherKeysFoundBefore++;
                    }
                }
            }
            
            input = [input stringByReplacingCharactersInRange:firstRange withString:@""]; // Remove substring with first key
            
            NSRange secondRange = [input rangeOfString:key]; // Find second key
            input = [input stringByReplacingCharactersInRange:secondRange withString:@""]; // Remove substring with second key
            
            NSRange styleRange = NSMakeRange(firstRange.location + 2,  secondRange.location - firstRange.location); // Create style range from two key ranges
            
            NSUInteger locationWithOtherKeysSubtracted = styleRange.location - 2 - (2*otherKeysFoundBefore); // Find true location to style by ignoring other keys
            
            [rangesToStyle addObject: @[@(locationWithOtherKeysSubtracted), @(styleRange.length), key]]; // Add custom range object with key to styling array
        }
    }
    
    NSMutableAttributedString *stringBuilder = [[NSMutableAttributedString alloc]initWithString:input];
    for (NSArray *range in rangesToStyle) {
        NSUInteger location = [range[0] unsignedIntegerValue];
        NSUInteger length = [range[1] unsignedIntegerValue];
        NSString *key = [NSString stringWithFormat:@"%@",range[2]];
        [stringBuilder addAttributes: @{NSFontAttributeName : [self getFontForKey:key]} range: NSMakeRange(location, length)];
    }
    
    return stringBuilder;
}

-(NSArray<NSString*>*)styleKeys {
    return @[kBold,kItalic,kBig];
}

-(UIFont*)getFontForKey:(NSString*)key {
    
    UIFont *style = [UIFont fontWithName:@"Avenir-Heavy" size:18.0]; // Default?
     
    if ([key isEqualToString:kBold]) style = [UIFont fontWithName:@"Avenir-Heavy" size:18.0];
    
    if ([key isEqualToString:kItalic]) style = [UIFont italicSystemFontOfSize:18.0];
    
    if ([key isEqualToString:kBig]) style = [UIFont boldSystemFontOfSize:30.0];
    
    return style;
}

@end
