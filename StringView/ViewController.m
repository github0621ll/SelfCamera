//
//  ViewController.m
//  StringView
//
//  Created by 樊琳琳 on 16/4/1.
//  Copyright © 2016年 fll. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIButton+Badge.h"

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define GET_IMAGE(__NAME__,__TYPE__)    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:__NAME__ ofType:__TYPE__]]

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

{
    BOOL *isBool;
    UIImageView *imageView;
    UIImage *imageG;
}
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    isBool=0;
    UIButton *swButton=[[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, 60, 100, 30)];
    swButton.backgroundColor=[UIColor redColor];
    [swButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swButton];
    
    imageView=[[UIImageView alloc] initWithFrame:CGRectMake(20, 130, 280, 320)];
    imageView.backgroundColor=[UIColor greenColor];
    [self.view addSubview:imageView];

    
    _imagePickerController.cameraViewTransform = CGAffineTransformMakeScale(1.2,1.2);
     self.automaticallyAdjustsScrollViewInsets = NO;

    _imagePickerController.showsCameraControls = NO;

    _imagePickerController.cameraViewTransform = CGAffineTransformScale(_imagePickerController.cameraViewTransform, 1.6, 1.6);

    
}
- (void)takePhoto:(id)sender
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    self.imagePickerController = picker;
    [self setupImagePicker:sourceType];
    picker = nil;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}
//这里是主要函数
- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController.sourceType = sourceType;
    
    self.imagePickerController.showsCameraControls = NO;
    self.imagePickerController.cameraViewTransform = CGAffineTransformMakeScale(1.8,1.8);
    
    UIView *topView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [self.imagePickerController.cameraOverlayView addSubview:topView];
    topView.backgroundColor = [UIColor blackColor];
    
    UIView *bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-100, self.view.frame.size.width, 100)];
    [self.imagePickerController.cameraOverlayView addSubview:bottomView];
    bottomView.backgroundColor=[UIColor blackColor];
    
    //闪光灯
    UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake(10, 10, 50, 30);
    flashBtn.showsTouchWhenHighlighted = YES;
    flashBtn.tag = 100;
    [flashBtn setImage:GET_IMAGE(@"light_off.png", nil) forState:
     UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(pushButton:) forControlEvents:
     UIControlEventTouchUpInside];
    UIBarButtonItem *flashItem = [[UIBarButtonItem alloc] initWithCustomView:flashBtn];
    if (isPad) {
        //ipad,禁用闪光灯
        flashItem.enabled = NO;
    }
    [topView addSubview:flashBtn];
    
    //拍照
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake(self.view.frame.size.width/2-30, 20, 60, 60);
    cameraBtn.showsTouchWhenHighlighted = YES;
    [cameraBtn setImage:GET_IMAGE(@"takephote.png", nil) forState:
     UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(stillImage:) forControlEvents:
     UIControlEventTouchUpInside];
    [cameraBtn badgeNumber:-1];
    //    UIBarButtonItem *takePicItem = [[UIBarButtonItem alloc] initWithCustomView:cameraBtn];
    [bottomView addSubview:cameraBtn];
    
    
    //摄像头切换
    UIButton *cameraDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraDevice.frame = CGRectMake(self.view.frame.size.width-60, 10, 50, 30);
    cameraDevice.showsTouchWhenHighlighted = YES;
    [cameraDevice setImage:GET_IMAGE(@"camera_change.png", nil) forState:UIControlStateNormal];
    [cameraDevice addTarget:self action:@selector(changeCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cameraDeviceItem = [[UIBarButtonItem alloc] initWithCustomView:cameraDevice];
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        //判断是否支持前置摄像头
        cameraDeviceItem.enabled = NO;
    }
    [topView addSubview:cameraDevice];

    //取消、完成
    UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    done.frame = CGRectMake(self.view.frame.size.width-60, 35, 50, 30);
    done.showsTouchWhenHighlighted = YES;
    [done setTitle:@"取消" forState:UIControlStateNormal];
    [done addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:done];
    
}

#pragma mark 闪光灯
-(void)pushButton:(UIButton *)sender
{
    if ((isBool=!isBool)) {
        [sender setImage:[UIImage imageNamed:@"light_on.png"] forState:UIControlStateNormal];
        _imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    }else{
        [sender setImage:[UIImage imageNamed:@"light_off.png"] forState:UIControlStateNormal];
        _imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }
}
- (void)changeCameraDevice:(id)sender
{
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

//拍照
- (void)stillImage:(id)sender
{
    [self.imagePickerController takePicture];
}

//完成、取消
- (void)doneAction
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //保存相片到数组，这种方法不可取,会占用过多内存
    //如果是一张就无所谓了，到时候自己改
    [picker dismissViewControllerAnimated:YES completion:nil];

    imageG=[info objectForKey:UIImagePickerControllerOriginalImage];
    imageView.image=[info objectForKey:UIImagePickerControllerOriginalImage];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
