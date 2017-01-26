//
//  MovieCell.h
//  Flicks
//
//  Created by  Steve Carlson (Media Engineering) on 1/23/17.
//  Copyright © 2017 Steve Carlson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *overviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterImage;
@end
