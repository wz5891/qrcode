#import "QrScanModule.h"
#import <React/RCTLog.h>
#import "QrScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation QrScanModule

// To export a module named CalendarManager
RCT_EXPORT_MODULE();

RCT_REMAP_METHOD(startQRCode,
                 title:(NSString *)title
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  if (device) {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
      case AVAuthorizationStatusNotDetermined: {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
          if (granted) {
            dispatch_sync(dispatch_get_main_queue(), ^{
              
              dispatch_async(dispatch_get_main_queue(), ^{
                
                QrScanViewController * vc = [[QrScanViewController alloc] init];
                vc.resolveBlock = resolve;
                vc.rejectBlock = reject;
                // vc.title = title ? title : @"扫一扫";
                vc.scanTip = title;
                
                UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                UIViewController * rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                [rootViewController presentViewController:nvc animated:YES completion:nil];
              
              });
            });
            NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
          } else {
            NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
          }
        }];
        break;
      }
      case AVAuthorizationStatusAuthorized: {
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
          QrScanViewController * vc = [[QrScanViewController alloc] init];
          vc.resolveBlock = resolve;
          vc.rejectBlock = reject;
          vc.scanTip = @"将二维码/条码放入框内, 即可自动扫描";
          
          UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:vc];
          UIViewController * rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
          [rootViewController presentViewController:nvc animated:YES completion:nil];
          
        });
        
        break;
      }
      default:
        break;
    }
    return;
  }
  
  UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
  UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    
  }];
  
  [alertC addAction:alertA];
  dispatch_async(dispatch_get_main_queue(), ^{
    UINavigationController * nvc = [[UINavigationController alloc] initWithRootViewController:alertC];
    UIViewController * rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentViewController:nvc animated:YES completion:nil];
  });
}

@end
