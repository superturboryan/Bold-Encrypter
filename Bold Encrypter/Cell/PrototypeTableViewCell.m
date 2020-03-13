//
//  PrototypeTableViewCell.m
//  Bold Encrypter
//
//  Created by Ryan David Forsyth on 2020-03-12.
//  Copyright © 2020 Ryan David Forsyth. All rights reserved.
//

#import "PrototypeTableViewCell.h"

@implementation PrototypeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.mainLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
