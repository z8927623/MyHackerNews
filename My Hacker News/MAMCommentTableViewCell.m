//
//  MAMCommentTableViewCell.m
//  My Hacker News
//
//  Created by Wild Yaoyao on 14-4-22.
//  Copyright (c) 2014年 Yang Yao. All rights reserved.
//

#import "MAMCommentTableViewCell.h"
#import "TTTAttributedLabel.h"

@implementation MAMCommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    
    for (NSLayoutConstraint *cellConstraint in self.constraints) {
        
        [self removeConstraint:cellConstraint];
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        NSLayoutConstraint* contentViewConstraint =
        [NSLayoutConstraint constraintWithItem:firstItem
                                     attribute:cellConstraint.firstAttribute
                                     relatedBy:cellConstraint.relation
                                        toItem:seccondItem
                                     attribute:cellConstraint.secondAttribute
                                    multiplier:cellConstraint.multiplier
                                      constant:cellConstraint.constant];
        [self.contentView addConstraint:contentViewConstraint];
         
    }
    
    if ([MAMHNController isPad]) {
        [self.comment setFont:[UIFont systemFontOfSize:18]];
    }
    
    [self.comment setDataDetectorTypes:NSTextCheckingTypeLink];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // indentationLevel缩进层级
    // indentationWidth每次缩进宽
    float indentPoints = self.indentationLevel * self.indentationWidth;
    // 设置contentView的frame
    self.contentView.frame = CGRectMake(indentPoints, self.contentView.frame.origin.y, self.contentView.frame.size.width - indentPoints, self.contentView.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForCellWithText:(NSString *)text constrainedToWidth:(float)width
{
    CGFloat height = 40;
    static UIFont *font = nil;
    if (!font) {
        font = [UIFont systemFontOfSize:([MAMHNController isPad] ? 18 : 16)];
    }
    
    CGRect fontRect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:font}  context:nil];
   
    return height + fontRect.size.height;
}

@end
