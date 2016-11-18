# EZQRCodeScanner
    
![](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)
![](https://img.shields.io/badge/CocoaPods-v1.0.0-green.svg?style=flat)
![](https://img.shields.io/badge/platform-iOS-red.svg?style=flat)
> EZQRCodeScanner in Objective-C.    
> A simple QRCode scanner, including a view controller which is in charge of the working of AVFoundation and other UI things, a view which draws the line, sets the background color and makes a transparent region at the center. It's very simple so I have nothing to show off, hhhh.    
> Why I make this QRCode Scanner is that I want to simplify the same work I usually do. The next time I need the QRCode Scanner, I can use it immediately.    

Actually, I want to create three mode of the animation to show in the scanner view. But I have some problems in the last mode. So the version 1.0.0 only has the mode "line" and mode "netgrid". I will create the third mode as soon as possible.    
![](NetGrid.png) ![](Line.png)    
The flash button can turn the flash light on or off, and the album button can open the album of your device for you to choose a QRCode picture to be analysed(Only support iPhone5S and later thanks to the arm64).    
    
## How To Get Started

### Installation

You can install EZQRCodeScanner in a traditional way -- drag the **EZQRCodeScanner/EZQRCodeScanner** into your project.<font color=red>(recommended)</font>         
你可以直接将 **EZQRCodeScanner/EZQRCodeScanner**文件夹加入到项目中直接使用。

### Install with CocoaPods

CocoaPods is a dependency manager for Objective-C and Swift, which automates and simplifies the process of using 3rd-party libraries like EZHeartForLike in your projects.    
However, it is strongly recommended that you <font color=red>do not</font> install via CocoaPods in this situation, because this pod includes a view controller and we all know usually we have to do some individual work in the controller, so the better way to install this pod is to use the way up there.    
But I still show you how to install with Cocoapods.

* Podfile

	```           
	pod 'EZQRCodeScanner', '~> 1.0.0'
	```
	

### Usage

#### Create a EZQRCodeScanner

1. Import the "EZQRCodeScanner.h" to your controller.
    
    ``` 
    #import "EZQRCodeScanner.h"
    ```
    
2. Init the EZQRCodeScanner into your controller.

    ```
    EZQRCodeScanner *scanner = [[EZQRCodeScanner alloc] init];
    ```
   If you want to do something after invoking the EZQRCodeScanner, set up the delegate.    
   一般来说，需要在扫描器得到结果后会通过delegate回调，因此需设置代理并实现相关方法。
    
    ```
    scanner.delegate = self;
    ```
3. Set the animation mode of the scan region. You can choose the mode "Line"(consume CPU strongly) or "NetGrid". 

	```
	scanner.scanStyle = EZScanStyleLine;
	```

4. Show the EZQRCodeScanner;

    ```
    [self.navigationController pushViewController:scanner animated:YES];
    ```
    
5. You can see the demo for detail.Enjoy. :) 


#### EZQRCodeScannerDelegate

* -(void)scannerView:(EZQRCodeScanner *)scanner outputString:(NSString *)output;  @required     
    When the scanner get the message from the QRCode correctly, it will invoke this delegate function. The output is the message inside the QRCode.    
    
    ```
    - (void)scannerView:(EZQRCodeScanner *)scanner outputString:(NSString *)output {    
        // do something to the output
    }
    ```

* -(void)scannerView:(EZQRCodeScanner *)scanner errorMessage:(NSString *)errorMessage;  @optional        
	    
    ```
    - (void)scannerView:(EZQRCodeScanner *)scanner errorMessage:(NSString *)errorMessage {    
        // optional, do something to deal with the error
    }
    ```

## update

		1.0.0     初始化版本，包含两种扫描动画。

## Issues, Bugs, Suggestions

Open an [issue](https://github.com/Ezfen/EZQRCodeScanner/issues)

## License

EZQRCodeScanner is available under the MIT license. See the LICENSE file for more info.
