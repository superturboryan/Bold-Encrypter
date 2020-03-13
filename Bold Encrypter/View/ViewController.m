//
//  ViewController.m
//  Bold Encrypter
//
//  Created by Ryan David Forsyth on 2020-03-12.
//  Copyright © 2020 Ryan David Forsyth. All rights reserved.
//

#import "ViewController.h"
#import "PrototypeTableViewCell.h"

//MARK: Private
@interface ViewController ()
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
- (IBAction)boldifyTapped:(id)sender {
    [self boldifyMessageInTextField];
    [self.tableView reloadData];
}

//MARK: Business logic
-(void)boldifyMessageInTextField {
    
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
    
    decryptedString = [self checkForKey:@"**" inEncryptedString: decryptedString];
    
    return decryptedString;
}

-(NSMutableAttributedString*)checkForKey:(NSString*)key inEncryptedString:(NSMutableAttributedString*)input {
    
    NSMutableArray<NSString*>* pieces = [[[input string] componentsSeparatedByString:key]mutableCopy];
    
    if (pieces.count == 1)
        return input; // No bold markers found
    
    NSMutableAttributedString *stringBuilder = [[NSMutableAttributedString alloc]initWithString:@""];
    
    BOOL applyEffect = NO;
    for (NSString *string in pieces) {
        
        if (applyEffect) {
            NSMutableAttributedString *decryptedPiece = [[NSMutableAttributedString alloc] initWithString:string];
            UIFont *bold = [UIFont fontWithName:@"Avenir-Heavy" size:18.0];
            [decryptedPiece addAttribute:NSFontAttributeName value:bold range:NSMakeRange(0, decryptedPiece.length)];
            [stringBuilder appendAttributedString:decryptedPiece];
        }
        else
            [stringBuilder appendAttributedString: [[NSAttributedString alloc]initWithString:string]];
        
        applyEffect = !applyEffect; // Switch toggle
    }
    
    return stringBuilder;
}


@end
