//
//  ItemInputViewController.m
//  Camille
//
//  Created by 杨淳引 on 2017/2/5.
//  Copyright © 2017年 shayneyeorg. All rights reserved.
//

#import "ItemInputViewController.h"
#import "ItemNameCollectCell.h"
#import "CMLDataManager.h"

#define kCharLimit 20

@interface ItemInputViewController () <UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) CGRect initialPosition;
@property (nonatomic, copy) NSString *itemType;
@property (nonatomic, strong) NSArray *itemsArr;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *inputFieldBackgroundView;
@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) NSString *initialText;

@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, strong) UICollectionView *itemsCollectionView;

@end

@implementation ItemInputViewController

#pragma mark - Life Cycle

+ (instancetype)initWithInitialPosition:(CGRect)initialPosition itemType:(NSString *)itemType initialText:(NSString *)initialText {
    ItemInputViewController *itemInputViewController = [ItemInputViewController new];
    itemInputViewController.initialPosition = initialPosition;
    itemInputViewController.itemType = itemType;
    itemInputViewController.initialText = initialText;
    return itemInputViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configBackgroundView];
    [self registerNotidications];
    
    if (self.initialPosition.size.width > 0 && self.initialPosition.size.height > 0 && self.itemType.length) {
        DECLARE_WEAK_SELF
        [CMLDataManager fetchItemsWithItemType:self.itemType callback:^(CMLResponse *response) {
            if (PHRASE_ResponseSuccess && [response.responseDic[KEY_Items] isKindOfClass:[NSArray class]]) {
                weakSelf.itemsArr = response.responseDic[KEY_Items];
                [weakSelf configInputFieldBackgroundView];
                [weakSelf configInputField];
                [weakSelf configDismissBtn];
                [weakSelf configConfirmBtn];
                [weakSelf startInitialAnamation];
                
            } else {
                CMLLog(@"数据出错");
            }
        }];
        
        
    } else {
        CMLLog(@"需要使用initWithInitialPosition:方法先指定inputField的初始位置");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self removeNotifications];
    CMLLog(@"%s", __func__);
}

#pragma mark - UI Configuration

- (void)configBackgroundView {
    self.backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backgroundView];
}

- (void)configDismissBtn {
    self.dismissBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.backgroundView.frame.size.width, 30, 40, self.inputFieldBackgroundView.frame.size.height)];
    self.dismissBtn.backgroundColor = [UIColor clearColor];
    self.dismissBtn.alpha = 0;
    [self.dismissBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.dismissBtn setTitleColor:kAppTextColor forState:UIControlStateNormal];
    [self.dismissBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:self.dismissBtn];
}

- (void)configConfirmBtn {
    self.confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.backgroundView.frame.size.width - 50, 30, 40, self.inputFieldBackgroundView.frame.size.height)];
    self.confirmBtn.backgroundColor = [UIColor clearColor];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:kAppTextColor forState:UIControlStateNormal];
    [self.confirmBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    self.confirmBtn.hidden = YES;
    [self.backgroundView addSubview:self.confirmBtn];
}

- (void)configInputFieldBackgroundView {
    self.inputFieldBackgroundView = [[UIView alloc]initWithFrame:self.initialPosition];
    self.inputFieldBackgroundView.backgroundColor = RGB(230, 230, 230);
    self.inputFieldBackgroundView.layer.cornerRadius = 5;
    self.inputFieldBackgroundView.clipsToBounds = YES;
    [self.backgroundView addSubview:self.inputFieldBackgroundView];
}

- (void)configInputField {
    self.inputField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, self.inputFieldBackgroundView.width - 20, self.inputFieldBackgroundView.height)];
    self.inputField.delegate = self;
    self.inputField.placeholder = @"项目";
    self.inputField.text = self.initialText;
    self.inputField.backgroundColor = RGB(230, 230, 230);
    self.inputField.borderStyle = UITextBorderStyleNone;
    self.inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.inputFieldBackgroundView addSubview:self.inputField];
    self.inputField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.itemsCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 80, kScreen_Width - 20, kScreen_Height - 80) collectionViewLayout:layout];
    self.itemsCollectionView.backgroundColor = [UIColor whiteColor];
    self.itemsCollectionView.delegate = self;
    self.itemsCollectionView.dataSource = self;
    self.itemsCollectionView.showsVerticalScrollIndicator = NO;
    [self.itemsCollectionView registerClass:[ItemNameCollectCell class] forCellWithReuseIdentifier:@"ItemNameCell"];
    [self.backgroundView addSubview:self.itemsCollectionView];
}

#pragma mark - Notification

- (void)registerNotidications {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)keyboardChange:(NSNotification *)notification {
    //获取键盘的y值
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.itemsCollectionView.frame = CGRectMake(self.itemsCollectionView.x, self.itemsCollectionView.y, self.itemsCollectionView.width, keyboardRect.origin.y - self.itemsCollectionView.y);
    }];
}

- (void)textFieldTextDidChange:(NSNotification *)notification {
    if (self.inputField.text.length > 0) {
        [self showConfirmBtn];
        
    } else {
        [self showDismissBtn];
    }
}

#pragma mark - Private

- (void)startInitialAnamation {
    [UIView animateWithDuration:0.2 animations:^{
        self.inputFieldBackgroundView.frame = CGRectMake(10, 30, self.backgroundView.frame.size.width - 20, self.inputFieldBackgroundView.frame.size.height);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.inputFieldBackgroundView.frame = CGRectMake(10, 30, self.backgroundView.frame.size.width - 70, self.inputFieldBackgroundView.frame.size.height);
            self.dismissBtn.frame = CGRectMake(self.backgroundView.frame.size.width - 50, 30, 40, self.inputFieldBackgroundView.frame.size.height);
            self.dismissBtn.alpha = 1;
            
        } completion:^(BOOL finished) {
            [self configCollectionView];
            [self.inputField becomeFirstResponder];
        }];
    }];
}

- (void)showConfirmBtn {
    self.confirmBtn.hidden = NO;
    self.dismissBtn.hidden = YES;
}

- (void)showDismissBtn {
    self.confirmBtn.hidden = YES;
    self.dismissBtn.hidden = NO;
}

- (void)dismiss {
    if (self.dismissBlock) {
        [self.dismissBtn removeFromSuperview];
        [self.confirmBtn removeFromSuperview];
        [self.itemsCollectionView removeFromSuperview];
        [UIView animateWithDuration:0.2 animations:^{
            self.inputFieldBackgroundView.frame = self.initialPosition;
            
        } completion:^(BOOL finished) {
            self.dismissBlock(nil, nil);
        }];
    }
}

- (void)confirm {
    if (self.inputField.text.length > kCharLimit) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"项目名不可超过%zd个字符", kCharLimit]];
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemName == %@", self.inputField.text];
    NSArray *selectedItems = [self.itemsArr filteredArrayUsingPredicate:predicate];
    if (selectedItems.count) {
        //此item已存在
        if (self.dismissBlock) {
            Item *selectedItem = selectedItems.firstObject;
            [self.dismissBtn removeFromSuperview];
            [self.confirmBtn removeFromSuperview];
            [self.itemsCollectionView removeFromSuperview];
            [UIView animateWithDuration:0.2 animations:^{
                self.inputFieldBackgroundView.frame = self.initialPosition;
                
            } completion:^(BOOL finished) {
                self.dismissBlock(selectedItem.itemID, selectedItem.itemName);
            }];
        }
        
    } else {
        //此item不存在
        [CMLDataManager addItemWithName:self.inputField.text type:self.itemType callBack:^(CMLResponse * _Nonnull response) {
            if (response && [response.code isEqualToString:RESPONSE_CODE_SUCCEED]) {
                Item *selectedItem = response.responseDic[KEY_Item];
                [self.dismissBtn removeFromSuperview];
                [self.confirmBtn removeFromSuperview];
                [self.itemsCollectionView removeFromSuperview];
                [UIView animateWithDuration:0.2 animations:^{
                    self.inputFieldBackgroundView.frame = self.initialPosition;
                    
                } completion:^(BOOL finished) {
                    self.dismissBlock(selectedItem.itemID, selectedItem.itemName);
                }];
            }
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //Item长度不能超过kCharLimit个字
    NSMutableString *newText = textField.text.mutableCopy;
    [newText replaceCharactersInRange:range withString:string];
    if (newText.length > kCharLimit && string.length) {
        return NO;
    }
    
    //Item不可包含空格
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Item *selectedItem = self.itemsArr[indexPath.row];
    self.inputField.text = selectedItem.itemName;
    [self confirm];
}

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = self.itemsArr[indexPath.row];
    CGFloat width = [CMLTool widthWithText:item.itemName font:[UIFont systemFontOfSize:16]];
    return CGSizeMake(width + 10, 30);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemNameCollectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemNameCell" forIndexPath:indexPath];
    Item *item = self.itemsArr[indexPath.row];
    cell.itemName = item.itemName;
    
    return cell;
}

@end
