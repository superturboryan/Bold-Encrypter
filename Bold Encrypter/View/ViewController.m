//
//  ViewController.m
//  Bold Encrypter
//
//  Created by Ryan David Forsyth on 2020-03-12.
//  Copyright © 2020 Ryan David Forsyth. All rights reserved.
//

#import "ViewController.h"
#import "PrototypeTableViewCell.h"

/*Private */@interface ViewController ()
<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *boldifyButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSMutableArray <NSAttributedString*>* stringsToDisplay;

@end

@implementation ViewController

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
    
    NSMutableAttributedString *decryptedString = [[NSMutableAttributedString alloc]initWithString:input];
    
    decryptedString = [self checkForKeys:@[@"!!",@"//",@"??"] inEncryptedString: decryptedString];
    
    return decryptedString;
}

-(NSMutableAttributedString*)checkForKeys:(NSArray<NSString*>*)keys inEncryptedString:(NSMutableAttributedString*)input {
    
    NSString *modified = [input string];
    NSMutableArray<NSArray*>* rangesToStyle = [NSMutableArray array];
    
    for (NSString *key in keys) {
    
        while ([modified containsString:key]) {
            
            NSRange firstRange = [modified rangeOfString:key]; // Find first key
            
            NSMutableArray *otherKeys = [keys mutableCopy]; // LOGIC ONLY WORKS FOR 2 KEY COMBINATIONS
            [otherKeys removeObject:key];

            NSUInteger otherKeysFoundBefore = 0, length = firstRange.location; // Count other keys found before

            for (NSString *otherKey in otherKeys) {
                NSRange range = NSMakeRange(0, length);
                while(range.location != NSNotFound) {
                    range = [modified rangeOfString:otherKey options:0 range:range];
                    if(range.location != NSNotFound) {
                        range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                        otherKeysFoundBefore++;
                    }
                }
            }
            
            modified = [modified stringByReplacingCharactersInRange:firstRange withString:@""]; // Remove
            
            NSRange secondRange = [modified rangeOfString:key]; // Find second key
            modified = [modified stringByReplacingCharactersInRange:secondRange withString:@""]; // Remove
            
            NSRange styleRange = NSMakeRange(firstRange.location + 2,  secondRange.location - firstRange.location); // Create style range
            
            NSUInteger locationWithOtherKeysSubtracted = styleRange.location-2-(2*otherKeysFoundBefore);
            
            [rangesToStyle addObject: @[@(locationWithOtherKeysSubtracted), @(styleRange.length), key]]; // Add to ranges to style
        }
    }
    
    NSMutableAttributedString *stringBuilder = [[NSMutableAttributedString alloc]initWithString:modified];
    for (NSArray *range in rangesToStyle) {
        NSUInteger location = [range[0] unsignedIntegerValue];
        NSUInteger length = [range[1] unsignedIntegerValue];
        NSString *key = [NSString stringWithFormat:@"%@",range[2]];
        [stringBuilder addAttributes: @{NSFontAttributeName : [self getFontForKey:key]} range: NSMakeRange(location, length)];
    }
    
    return stringBuilder;
}

-(UIFont*)getFontForKey:(NSString*)key {
    
    if ([key isEqualToString:@"!!"])
        return [UIFont fontWithName:@"Avenir-Heavy" size:18.0];
    
    if ([key isEqualToString:@"//"])
        return [UIFont italicSystemFontOfSize:18.0];
    
    if ([key isEqualToString:@"??"])
        return [UIFont boldSystemFontOfSize:30.0];
    
    return [UIFont fontWithName:@"Avenir-Heavy" size:18.0]; // Default?
}

@end
