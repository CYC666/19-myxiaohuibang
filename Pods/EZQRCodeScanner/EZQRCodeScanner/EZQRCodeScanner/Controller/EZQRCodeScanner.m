//
//  EZQRCodeScanner.m
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/18.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "EZQRCodeScanner.h"

@interface EZQRCodeScanner () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *captureDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMeradataOutput;

@property (strong, nonatomic) EZQRCodeScannerView *scannerView;     // 整个Background，而非扫描区域
@property (strong, nonatomic) UILabel *tipsLabel;
@property (strong, nonatomic) UIButton *flashLight;
@property (strong, nonatomic) UIButton *loadPic;

@property (nonatomic, getter=isTorchOn) BOOL torchOn;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation EZQRCodeScanner

@synthesize scanStyle = _scanStyle;

# pragma mark - Initial
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫描二维码";
    [self setupAVCaptureComponent:self.view.layer.bounds];
    [self.view addSubview:self.scannerView];
    [self addTipsLabel];
    [self addButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}

- (void)setScanStyle:(EZScanStyle)otherScanStyle {
    _scanStyle = otherScanStyle;
}

- (EZScanStyle)scanStyle {
    if (_scanStyle == EZScanStyleNone) {
        _scanStyle = EZScanStyleNetGrid;
    }
    return _scanStyle;
}

- (EZQRCodeScannerView *)scannerView {
    if (!_scannerView) {
        _scannerView = [[EZQRCodeScannerView alloc] initWithFrame:self.view.frame];
        _scannerView.scanStyle = self.scanStyle;
    }
    return _scannerView;
}

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        _imagePicker.allowsEditing = YES;
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        return _imagePicker;
    } else return nil;
}

- (void)addTipsLabel {
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.scannerView.frame), CGRectGetMaxY(self.scannerView.frame) * kHeightPaddingAspect - 40, self.scannerView.frame.size.width, 20)];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.textColor = [UIColor whiteColor];
    self.tipsLabel.text =  @"请将二维码放置于下框中";
    [self.view addSubview:self.tipsLabel];
}

- (void)addButtons {
    CGFloat minYUnderScannerRegion = self.scannerView.minYUnderScannerRegion;
    CGFloat buttonWidthAndHeight = CGRectGetWidth(self.view.bounds) / 5;
    
    // 添加闪光灯按钮
    self.flashLight = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashLight.layer.cornerRadius = 10;
    self.flashLight.clipsToBounds = YES;
    self.flashLight.frame = CGRectMake(buttonWidthAndHeight, minYUnderScannerRegion + 30, buttonWidthAndHeight, buttonWidthAndHeight);
    self.torchOn = NO;
    [self.flashLight setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
    [self.flashLight addTarget:self action:@selector(openTorch:) forControlEvents:UIControlEventTouchUpInside];
    [self.flashLight setBackgroundColor:[UIColor colorWithWhite:0.902 alpha:0.880]];
    [self.view addSubview:self.flashLight];
    // 添加读取图片库按钮
    self.loadPic = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loadPic.layer.cornerRadius = 10;
    self.loadPic.clipsToBounds = YES;
    self.loadPic.frame = CGRectMake(CGRectGetMaxX(self.flashLight.frame) + buttonWidthAndHeight, minYUnderScannerRegion + 30, buttonWidthAndHeight, buttonWidthAndHeight);
    [self.loadPic setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
    [self.loadPic addTarget:self action:@selector(openAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.loadPic setBackgroundColor:[UIColor colorWithWhite:0.902 alpha:0.880]];
    [self.view addSubview:self.loadPic];
    
}

# pragma mark - Running Control
- (void)startRunning {
    [self.scannerView startAnimation];
    [self.captureSession startRunning];
}
- (void)stopRunning {
    [self.scannerView stopAnimation];
    [self.captureSession stopRunning];
}

# pragma mark - ButtonEvent
- (void)openTorch:(UIButton *)button {
    self.torchOn = !self.isTorchOn;
    [self.captureDevice lockForConfiguration:nil];
    if (self.isTorchOn) {
        [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
        [self.flashLight setImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
    } else {
        [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
        [self.flashLight setImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
    }
    [self.captureDevice unlockForConfiguration];
}
- (void)openAlbum:(UIButton *)button {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

# pragma mark - Setup AVCapture Things
- (void)setupAVCaptureComponent:(CGRect)rect {
    NSError *error = nil;
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if (error || !self.captureDeviceInput) {
        NSLog(@"error: %@", [error localizedDescription]);
        return ;
    }
    self.captureMeradataOutput = [[AVCaptureMetadataOutput alloc] init];
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:self.captureDeviceInput];
    [self.captureSession addOutput:self.captureMeradataOutput];
    dispatch_queue_t dispatchQueue = dispatch_queue_create("AVCaptureQueue", DISPATCH_QUEUE_SERIAL);
    [self.captureMeradataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [self.captureMeradataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    self.capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.capturePreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.capturePreviewLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [self.view.layer insertSublayer:self.capturePreviewLayer atIndex:0];
    self.captureMeradataOutput.rectOfInterest = CGRectMake(kHeightPaddingAspect, kWidthPaddingAspect, kClearRectAspect * self.capturePreviewLayer.bounds.size.width / self.capturePreviewLayer.bounds.size.height , kClearRectAspect);
}

# pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    [self.captureSession stopRunning];
    __weak EZQRCodeScanner *weakSelf = self;
    if (metadataObjects != nil && metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // TODO
            if ([weakSelf.delegate respondsToSelector:@selector(scannerView:outputString:)]) {
                [weakSelf.delegate scannerView:weakSelf outputString:[metadataObj stringValue]];
            };
        } else {
            if ([weakSelf.delegate respondsToSelector:@selector(scannerView:errorMessage:)]) {
                [weakSelf.delegate scannerView:weakSelf errorMessage:@"Can not match the type:AVMetadataObjectTypeQRCode"];
            }
        }
    } else {
        if ([weakSelf.delegate respondsToSelector:@selector(scannerView:errorMessage:)]) {
            [weakSelf.delegate scannerView:weakSelf errorMessage:@"Can not get the message"];
        }
    }
}

# pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self.captureSession stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
    // 5S等架构为ARM64可用
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CIImage *ciImage = [CIImage imageWithCGImage:[image CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *detectorOptions = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:detectorOptions];
    NSArray *features = [detector featuresInImage:ciImage];
    NSString *msg = ((CIQRCodeFeature *)[features firstObject]).messageString;
    if ([self.delegate respondsToSelector:@selector(scannerView:outputString:)]) {
        [self.delegate scannerView:self outputString:msg];
    };
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
