#import "SignatureViewController.h"



@interface SignatureViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) BOOL touchMoved;

@end

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchMoved = NO;
    UITouch *touch = [touches anyObject];
    self.lastPoint = [touch locationInView:self.tempDrawImage];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchMoved = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.tempDrawImage];

    CGSize size = self.tempDrawImage.frame.size;
    UIGraphicsBeginImageContext(size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2 );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);

    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:1];
    UIGraphicsEndImageContext();

    self.lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //Draws dots
    if(!self.touchMoved) {
        CGSize size = self.tempDrawImage.frame.size;
        UIGraphicsBeginImageContext(size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (IBAction)clear:(id)sender
{
    self.tempDrawImage.image = nil;
}

- (IBAction)test:(id)sender
{
    UIImage *original = [self rotateImage:self.tempDrawImage.image];

    NSString *compressedImage = CCC_Base64GZippedSignatureForImage(original);

    if (!compressedImage) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Couldn't compress image."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    UIImage *unconvertedImage = CCC_ImageFromBase64GZippedString(compressedImage);

    if (!unconvertedImage) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Couldn't uncompress image."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];

        [okButton setValue:[[self shrinkImage:unconvertedImage toSize:CGSizeMake(100, 50)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

        [alert addAction:okButton];

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
}

- (UIImage*)rotateImage:(UIImage*)image
{
    CGSize size = image.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)shrinkImage:(UIImage*)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
