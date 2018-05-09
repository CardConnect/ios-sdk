#import "CardEntryViewController.h"

#import <PassKit/PassKit.h>

@interface CardEntryViewController () <CCCFormatterDelegateExtension,CCCSwiperDelegate, PKPaymentAuthorizationViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *cardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *expirationDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *CVVTextField;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeTextField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *swiperStatus;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *generateTokenBarButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *maskFormatSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *maskCharacterSegmentedControl;

@property (strong, nonatomic) IBOutlet CCCCardFormatterDelegate *cardFormatterDelegate;
@property (strong, nonatomic) IBOutlet CCCExpirationDateFormatterDelegate *expirationFormatterDelegate;
@property (strong, nonatomic) IBOutlet CCCCVVFormatterDelegate *cvvFormatterDelegate;

@property (nonatomic, strong) CCCSwiperController *swiper;

@property (nonatomic, strong) PKPaymentButton *applePayButton;
@property (nonatomic, strong) PKPaymentAuthorizationViewController *applePayViewController;

@property (nonatomic, strong) CCCCardInfo *card;

@end

@implementation CardEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.card = [CCCCardInfo new];

    self.cardNumberTextField.rightViewMode = UITextFieldViewModeAlways;
    self.expirationDateTextField.rightViewMode = UITextFieldViewModeAlways;
    self.CVVTextField.rightViewMode = UITextFieldViewModeAlways;

    if ([PKPaymentAuthorizationViewController canMakePayments] &&
        [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkAmex]])
    {
        self.applePayButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
        [self.applePayButton addTarget:self action:@selector(applePayPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.applePayButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.applePayButton];
        [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.applePayButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.swiperStatus attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0],
                                    [NSLayoutConstraint constraintWithItem:self.applePayButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.swiperStatus attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10]]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _swiper = [[CCCSwiperController alloc] initWithDelegate:self loggingEnabled:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    _swiper = nil;

    [super viewWillDisappear:animated];
}

#pragma mark Internal Methods

- (void)i_startActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    });
}

- (void)i_stopActivityIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}

- (void)i_updateCreateButton
{
    self.generateTokenBarButton.enabled =   self.cardFormatterDelegate.isValidCard &&
                                            self.expirationFormatterDelegate.isValidExpirationDate &&
                                            self.cvvFormatterDelegate.isValidCVV;
}

#pragma mark Action Methods

- (IBAction)createPressed:(id)sender
{
    [self.view endEditing:YES];

    [self i_startActivityIndicator];

    [[CCCAPI instance] generateAccountForCard:self.card completion:^(CCCAccount * _Nullable account, NSError * _Nullable error) {
        [self i_stopActivityIndicator];

        [self.cardFormatterDelegate clearTextField];
        [self.expirationFormatterDelegate clearTextField];
        [self.cvvFormatterDelegate clearTextField];
        self.postalCodeTextField.text = @"";
        self.card = [CCCCardInfo new];
        [self i_updateCreateButton];

        if (account)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Token Generated" message:account.token preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl*)sender
{
    if (sender == self.maskFormatSegmentedControl)
    {
        switch (sender.selectedSegmentIndex) {
            case 0:
                self.cardFormatterDelegate.maskFormat = CCCCardMaskFormatMaskWithLastFour;
                break;
            case 1:
                self.cardFormatterDelegate.maskFormat = CCCCardMaskFormatLastFour;
                break;
            case 2:
                self.cardFormatterDelegate.maskFormat = CCCCardMaskFormatFirstAndLastFour;
                break;
            default:
                break;
        }
    }
    else
    {
        switch (sender.selectedSegmentIndex) {
            case 0:
                self.cardFormatterDelegate.maskCharacter = '*';
                self.cvvFormatterDelegate.maskCharacter = '*';
                break;
            case 1:
                self.cardFormatterDelegate.maskCharacter = '&';
                self.cvvFormatterDelegate.maskCharacter = '&';
                break;
            case 2:
                self.cardFormatterDelegate.maskCharacter = '-';
                self.cvvFormatterDelegate.maskCharacter = '-';
                break;
            default:
                break;
        }
    }
}

- (void)applePayPressed:(PKPaymentButton*)paymentButton
{
    PKPaymentRequest *request = [PKPaymentRequest new];
    request.currencyCode = @"USD";
    request.countryCode = @"US";
    request.merchantIdentifier = @"merchant.test.id";

    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:@"1.00"];
    request.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:total]];
    request.supportedNetworks = @[PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkAmex];
    request.merchantCapabilities = PKMerchantCapability3DS;

    self.applePayViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    self.applePayViewController.delegate = self;
    [self presentViewController:self.applePayViewController animated:YES completion:nil];
}

#pragma mark CCCFormatterDelegateExtension

- (void)didChangeCharactersInRangeForFormatter:(CCCTextFieldDelegateProxy *)formatter
{
    if (formatter == self.cardFormatterDelegate)
    {
        if (self.cardNumberTextField.text.length > 0 &&
            !self.cardFormatterDelegate.isValidCard)
        {
            UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            xLabel.text = @"X";
            xLabel.textColor = [UIColor redColor];
            xLabel.font = [UIFont boldSystemFontOfSize:20];
            xLabel.textAlignment = NSTextAlignmentCenter;

            self.cardNumberTextField.rightView = xLabel;
        }
        else
        {
            self.cardNumberTextField.rightView = nil;
            [self.cardFormatterDelegate setCardNumberOnCardInfo:self.card];
        }
    }
    else if (formatter == self.expirationFormatterDelegate)
    {
        if (self.expirationDateTextField.text.length > 0 &&
            !self.expirationFormatterDelegate.isValidExpirationDate)
        {
            UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            xLabel.text = @"X";
            xLabel.textColor = [UIColor redColor];
            xLabel.font = [UIFont boldSystemFontOfSize:20];
            xLabel.textAlignment = NSTextAlignmentCenter;

            self.expirationDateTextField.rightView = xLabel;
        }
        else
        {
            self.expirationDateTextField.rightView = nil;
            [self.expirationFormatterDelegate setExpirationDateOnCardInfo:self.card];
        }
    }
    else if (formatter == self.cvvFormatterDelegate)
    {
        if (self.CVVTextField.text.length > 0 &&
            ![self.cvvFormatterDelegate isValidCVVWithCardFormatter:self.cardFormatterDelegate])
        {
            UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            xLabel.text = @"X";
            xLabel.textColor = [UIColor redColor];
            xLabel.font = [UIFont boldSystemFontOfSize:20];
            xLabel.textAlignment = NSTextAlignmentCenter;

            self.CVVTextField.rightView = xLabel;
        }
        else
        {
            self.CVVTextField.rightView = nil;
            [self.cvvFormatterDelegate setCVVOnCardInfo:self.card];
        }
    }

    [self i_updateCreateButton];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.cardNumberTextField)
    {
        self.card.cardNumber = nil;
    }
    else if (textField == self.expirationDateTextField)
    {
        self.card.expirationDate = nil;
    }
    else if (textField == self.CVVTextField)
    {
        self.card.CVV = nil;
    }

    [self i_updateCreateButton];

    return YES;
}

#pragma mark Swiper Delegate

- (void)swiper:(CCCSwiper *)swiper connectionStateHasChanged:(CCCSwiperConnectionState)state
{
    switch (state) {
        case CCCSwiperConnectionStateConnected:
            NSLog(@"Did Connect Swiper");
            self.swiperStatus.text = @"Connected";
            break;
        case CCCSwiperConnectionStateDisconnected:
            NSLog(@"Did Disconnect Swiper");
            self.swiperStatus.text = @"Disconnected";
            break;
        case CCCSwiperConnectionStateConnecting:
        default:
            NSLog(@"Will Connect Swiper");
            self.swiperStatus.text = @"Connecting";
            break;
    }
}

- (void)swiperDidStartMSR:(CCCSwiper *)swiper
{
    NSLog(@"MSR Started");
    [self.view endEditing:YES];
    [self i_startActivityIndicator];
}

- (void)swiper:(CCCSwiper *)swiper didGenerateTokenWithAccount:(CCCAccount *)account completion:(void (^)())completion
{
    [self i_stopActivityIndicator];

    if (account)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Token Generated" message:account.token preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completion();
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        completion();
    }
}

- (void)swiper:(CCCSwiper *)swiper didFailWithError:(NSError *)error completion:(void (^)())completion
{
    [self i_stopActivityIndicator];

    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@""
                                                                        message:[NSString stringWithFormat:@"An error occured:\n%@",error.localizedDescription]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completion();
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{

}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
