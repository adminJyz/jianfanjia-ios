//
//  ProductInfoCell.m
//  jianfanjia
//
//  Created by JYZ on 15/10/30.
//  Copyright © 2015年 JYZ. All rights reserved.
//

#import "ProductInfoCell.h"

@interface ProductInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblCell;
@property (weak, nonatomic) IBOutlet UILabel *lblDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIImageView *designerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vImageView;

@property (weak, nonatomic) Product *product;

@end

@implementation ProductInfoCell

- (void)awakeFromNib {
    // Initialization code
    [self.designerImageView setCornerRadius:30];
    [self.designerImageView setBorder:1 andColor:[[UIColor whiteColor] CGColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithProduct:(Product *)product {
    self.product = product;
    
    self.lblCell.text = product.cell;
    self.lblDetail.text = [NSString stringWithFormat:@"%@m², %@, %@风格",
                           self.product.house_area,
                           [NameDict nameForHouseType:self.product.house_type],
                           [NameDict nameForDecStyle:self.product.dec_style]];
    [self.designerImageView setUserImageWithId:self.product.designer.imageid];
    self.lblDescription.text = self.product.description;
}

@end
