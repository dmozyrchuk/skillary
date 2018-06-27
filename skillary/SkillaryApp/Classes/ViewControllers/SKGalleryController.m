//
//  SKGalleryController.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 26/06/2018.
//

#import "SKGalleryController.h"
#import <AVFoundation/AVFoundation.h>
#import "LibraryCell.h"
#import "FileSystemHelper.h"

@interface SKGalleryController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btDelete;

@property (nonatomic, strong) NSArray<AVURLAsset *> *dataSource;

@end

@implementation SKGalleryController {
    AVURLAsset *selectedAsset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [FileSystemHelper getVideoFilesFromLibrary];
    [self.navigationController.navigationBar setHidden:NO];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonTapped {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Обратите внимание," message:@"что до момента появления результатов оценки, видео удалять нельзя." preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Отправить" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.delegate videoSelectedWith:[NSString stringWithFormat:@"%lld", selectedAsset.duration.value / selectedAsset.duration.timescale] path:selectedAsset.URL.path];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [controller addAction:doneAction];
    [controller addAction:cancelAction];
    [self presentViewController:controller animated:YES completion:nil];

}

- (IBAction)deleteButonTapped:(id)sender {
    [FileSystemHelper removeFileAtPath:selectedAsset.URL.path];
    selectedAsset = nil;
    self.dataSource = [FileSystemHelper getVideoFilesFromLibrary];
    [self.collectionView reloadData];
    [self.navigationItem.leftBarButtonItem setEnabled:selectedAsset != nil];
    self.btDelete.enabled = selectedAsset != nil;
}

#pragma mark - Custom Accessors

- (void)setupButtons {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonTapped)];
    [self.navigationItem setRightBarButtonItem:rightItem];
    UIBarButtonItem *leftIitem = [[UIBarButtonItem alloc] initWithTitle:@"Выбрать" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonTapped)];
    [self.navigationItem setLeftBarButtonItem:leftIitem];
    [self.navigationItem.leftBarButtonItem setEnabled:selectedAsset != nil];
    self.btDelete.enabled = selectedAsset != nil;
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LibraryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LibraryCell" forIndexPath:indexPath];
    AVURLAsset *asset = self.dataSource[indexPath.row];
    cell.ivPreview.image = [FileSystemHelper thumbnailFor:asset.URL.path];
    int minutes = (asset.duration.value / asset.duration.timescale) / 60;
    int seconds = (asset.duration.value / asset.duration.timescale) % 60;
    cell.lbTime.text = [NSString stringWithFormat:@"%d:%2d", minutes, seconds];
    if (cell.gradientLayer == nil) {
        cell.gradientLayer = [CAGradientLayer layer];
        cell.gradientLayer.frame = cell.vwGradient.bounds;
        NSArray *gradientLocations = [NSArray arrayWithObjects:[NSNumber numberWithInt:0.0],[NSNumber numberWithInt:1.0], nil];
        cell.gradientLayer.locations = gradientLocations;
        cell.gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],(id)[[UIColor blackColor] CGColor], nil];
        [cell.vwGradient.layer addSublayer:cell.gradientLayer];
    }
    cell.ivCheckbox.hidden = ![asset isEqual:selectedAsset];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.width / 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSMutableArray *indexPathes = [[NSMutableArray alloc] init];
    if (selectedAsset != nil) {
        NSInteger index = [self.dataSource indexOfObject:selectedAsset];
        [indexPathes addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    [indexPathes addObject:indexPath];
    if ([selectedAsset isEqual:self.dataSource[indexPath.row]]) {
        selectedAsset = nil;
    } else {
        selectedAsset = self.dataSource[indexPath.row];
    }
    [collectionView reloadItemsAtIndexPaths:indexPathes];
    [self.navigationItem.leftBarButtonItem setEnabled:selectedAsset != nil];
    self.btDelete.enabled = selectedAsset != nil;
}

@end
