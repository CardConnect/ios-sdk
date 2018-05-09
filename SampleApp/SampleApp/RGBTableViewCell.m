#import "RGBTableViewCell.h"

@interface RGBTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;

@property (nonatomic, weak) id target;
@property (nonatomic, strong) NSString *key;

@end

@implementation RGBTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.colorView.layer.borderColor = [UIColor grayColor].CGColor;
    self.colorView.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)sliderValueChanged:(id)sender
{
    UIColor *newColor = [self colorFromSliders];

    [UIView animateWithDuration:0.1f animations:^{
        self.colorView.backgroundColor = newColor;
    }];

    if(self.key)
    {
        [self.target setValue:newColor forKeyPath:self.key];
    }
}

- (UIColor*)colorFromSliders
{
    return [UIColor colorWithRed:self.redSlider.value
                           green:self.greenSlider.value
                            blue:self.blueSlider.value
                           alpha:1.0f];
}

- (void)setTitle:(NSString *)title target:(id)target key:(NSString *)key initialValue:(UIColor *)color
{
    self.titleLabel.text = title;
    self.target = target;
    self.key = key;

    if (color)
    {
        size_t compCount = CGColorGetNumberOfComponents(color.CGColor);
        const CGFloat *colors = CGColorGetComponents(color.CGColor);

        if (compCount == 4)
        {
            self.redSlider.value = colors[0];
            self.greenSlider.value = colors[1];
            self.blueSlider.value = colors[2];
        }
        else
        {
            CGFloat color = colors[0];
            self.redSlider.value = color;
            self.greenSlider.value = color;
            self.blueSlider.value = color;
        }

        self.colorView.backgroundColor = [self colorFromSliders];
    }
}

@end
