#import "ThemingTableViewController.h"

#import "RGBTableViewCell.h"

@interface ThemingTableViewController ()

@property (nonatomic,strong) UIColor *navigationBarColor;
@property (nonatomic,strong) UIColor *navigationTitleColor;
@property (nonatomic,strong) UIColor *navigationButtonColor;
@property (nonatomic,strong) UIColor *backgroundColor;
@property (nonatomic,strong) UIColor *disclaimerTextColor;
@property (nonatomic,strong) UIColor *buttonColor;
@property (nonatomic,strong) UIColor *buttonTextColor;
@property (nonatomic,strong) UIColor *spinnerBackgroundColor;
@property (nonatomic,strong) UIColor *listSeparatorColor;
@property (nonatomic,strong) UIColor *listCellColor;
@property (nonatomic,strong) UIColor *listTextColor;
@property (nonatomic,strong) UIColor *listSecondaryTextColor;
@property (nonatomic,strong) UIColor *listSectionHeaderColor;
@property (nonatomic,strong) UIColor *cardColor;
@property (nonatomic,strong) UIColor *cardTextColor;
@property (nonatomic,strong) UIColor *listInputTextColor;
@property (nonatomic,strong) UIColor *listToggleOnColor;
@property (nonatomic,strong) UIColor *listToggleTintColor;
@property (nonatomic,strong) UIColor *listToggleThumbColor;

@property (nonatomic, strong) NSArray *valueKeys;

@end

@implementation ThemingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(savePressed)],
                                                [[UIBarButtonItem alloc] initWithTitle:@"Reset"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(reset)]];

    self.valueKeys = @[@"navigationBarColor",
                       @"navigationTitleColor",
                       @"navigationButtonColor",
                       @"backgroundColor",
                       @"disclaimerTextColor",
                       @"buttonColor",
                       @"buttonTextColor",
                       @"spinnerBackgroundColor",
                       @"listSeparatorColor",
                       @"listCellColor",
                       @"listTextColor",
                       @"listSecondaryTextColor",
                       @"listSectionHeaderColor",
                       @"cardColor",
                       @"cardTextColor",
                       @"listInputTextColor",
                       @"listToggleOnColor",
                       @"listToggleTintColor",
                       @"listToggleThumbColor"];

    [self.tableView registerNib:[UINib nibWithNibName:@"RGBTableViewCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"RGBCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setValuesWithObject:self.theme];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setValuesWithObject:(id)object
{
    for (NSString *keyPath in self.valueKeys)
    {
        id value = [object valueForKeyPath:keyPath];
        if (value)
        {
            [self setValue:value forKey:keyPath];
        }
    }

    [self.tableView reloadData];
}

- (void)savePressed
{
    for (NSString *keyPath in self.valueKeys)
    {
        id value = [self valueForKeyPath:keyPath];
        if (value)
        {
            [self.theme setValue:value forKey:keyPath];
        }
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reset
{
    [self setValuesWithObject:[CCCTheme new]];

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.valueKeys.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *key = self.valueKeys[indexPath.row];
    id value = [self valueForKeyPath:key];

    RGBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RGBCell"];
    [cell setTitle:key target:self key:key initialValue:value];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

@end
