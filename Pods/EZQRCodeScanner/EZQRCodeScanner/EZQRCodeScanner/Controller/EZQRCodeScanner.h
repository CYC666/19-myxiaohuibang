//
//  EZQRCodeScanner.h
//  EZQRCodeScanner
//
//  Created by ezfen on 16/5/18.
//  Copyright © 2016年 Ezfen Cheung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZQRCodeScannerView.h"

@class EZQRCodeScanner;
@protocol EZQRCodeScannerDelegate <NSObject>

@required
- (void)scannerView:(EZQRCodeScanner *)scanner outputString:(NSString *)output;
@optional
- (void)scannerView:(EZQRCodeScanner *)scanner errorMessage:(NSString *)errorMessage;

@end

@interface EZQRCodeScanner : UIViewController

@property (weak, nonatomic) id<EZQRCodeScannerDelegate> delegate;
@property (nonatomic) EZScanStyle scanStyle;

@end
