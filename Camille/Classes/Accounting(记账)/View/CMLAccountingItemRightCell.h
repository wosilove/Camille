//
//  CMLAccountingItemRightCell.h
//  Camille
//
//  Created by 杨淳引 on 16/2/23.
//  Copyright © 2016年 shayneyeorg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMLAccountingItemRightCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellText;

+ (instancetype)loadFromNib;

@end
