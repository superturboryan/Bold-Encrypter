//
//  ViewController.m
//  Bold Encrypter
//
//  Created by Ryan David Forsyth on 2020-03-12.
//  Copyright © 2020 Ryan David Forsyth. All rights reserved.
//

#import "DemoViewController.h"
#import "PrototypeTableViewCell.h"
#import "NSString+Extension.h"

/*Private */@interface DemoViewController ()
<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
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
    self.inputTextField.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.inputTextField.returnKeyType = UIReturnKeyDone;
    self.inputTextField.layer.cornerRadius = 10.0;
    self.inputTextField.layer.borderColor = UIColor.systemIndigoColor.CGColor;
    self.inputTextField.layer.borderWidth = 2.0;
    
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
    [self.inputTextField resignFirstResponder];
    [self stylizeTapped:nil];
    return YES;
}

//MARK: Actions
- (IBAction)stylizeTapped:(id)_ {
    [self interpretMessageInTextField];
    [self.tableView reloadData];
}

//MARK: Business logic
-(void)interpretMessageInTextField {
    
    NSString *input = [NSString stringWithFormat:@"%@",self.inputTextField.text];
    
    if (input.length == 0) return;
    
    [self clearTextField];
    
    NSAttributedString *formattedString = [input getStyledStringFromEncryptedString];
    
    [self.stringsToDisplay addObject:formattedString];
}

//MARK: Helpers
-(void)clearTextField {
    self.inputTextField.text = @"";
}


@end
