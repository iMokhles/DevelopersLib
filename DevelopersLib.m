#import "DevelopersLib.h"
#import "Vendors/rocketbootstrap.h"
#import "Vendors/ExportMusic.h"
#import "Vendors/TTOpenInAppActivity.h"
#import "Vendors/ProgressHUD.h"
#import "Vendors/ARSpeechActivity.h"
#import "MyColorPicker/IMOColorViewController.h"

OBJC_EXTERN CFStringRef MGCopyAnswer(CFStringRef key) WEAK_IMPORT_ATTRIBUTE;

static NSString *UniqueID_;
static UIWindow *mainImoWindow;
static UINavigationController *navigationController;

static NSString *DevLibUniqueIdentifier(UIDevice *device) {
    return (__bridge NSString *)MGCopyAnswer(CFSTR("UniqueDeviceID"));
}

@interface DevelopersLib () <TTOpenInAppActivityDelegate, DevLibFileBrowserViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    MFMailComposeViewController *mailComposer;
}
@end

@implementation DevelopersLib
@synthesize selfRootViewController, lastImagePath;
+ (id)sharedInstance
{
    static id shared = nil;
    if (shared == nil) {
        shared = [[self alloc] init];
    }
    
    return shared;
}

- (id)init
{
    if ((self = [super init])) {
        
        mainImoWindow = [[UIApplication sharedApplication] windows][0];
        selfRootViewController = mainImoWindow.rootViewController;
        
        self.fileBrowser = [[DevLibFileBrowserViewController alloc] init];
        self.fileBrowser.delegate = self;
        navigationController = [[UINavigationController alloc] initWithRootViewController:self.fileBrowser];
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        
    }
    return self;
}
- (NSString *)devlib_temporaryFile {
    return [[DevLibClient sharedInstance] DevLib_temporaryFile];
}
- (void)devlib_moveFile:(NSString *)file1 devlib_toFile:(NSString *)file2 {
    [[DevLibClient sharedInstance] DevLib_moveFile:file1 DevLib_toFile:file2];
}
- (void)devlib_copyFile:(NSString *)file1 devlib_toFile:(NSString *)file2 {
    [[DevLibClient sharedInstance] DevLib_copyFile:file1 DevLib_toFile:file2];
}
- (void)devlib_symlinkFile:(NSString *)file1 devlib_toFile:(NSString *)file2 {
    [[DevLibClient sharedInstance] DevLib_symlinkFile:file1 DevLib_toFile:file2];
}
- (void)devlib_deleteFile:(NSString *)file {
    [[DevLibClient sharedInstance] DevLib_deleteFile:file];
}
- (NSDictionary *)devlib_attributesOfFile:(NSString *)file {
    return [[DevLibClient sharedInstance] DevLib_attributesOfFile:file];
}
- (NSArray *)devlib_contentsOfDirectory:(NSString *)dir {
    return [[DevLibClient sharedInstance] DevLib_contentsOfDirectory:dir];
}
- (void)devlib_chmodFile:(NSString *)file mode:(mode_t)mode {
    [[DevLibClient sharedInstance] DevLib_chmodFile:file mode:mode];
}
- (BOOL)devlib_fileExists:(NSString *)file {
    return [[DevLibClient sharedInstance] DevLib_fileExists:file];
}
- (BOOL)devlib_fileIsDirectory:(NSString *)file {
    return [[DevLibClient sharedInstance] DevLib_fileIsDirectory:file];
}
- (void)devlib_createDirectory:(NSString *)dir {
    [[DevLibClient sharedInstance] DevLib_createDirectory:dir];
}

- (void)devlib_dismissMainWindow {
    [mainImoWindow setRootViewController:nil];
    mainImoWindow = nil;
    [mainImoWindow setHidden:YES];
}
- (NSString *)devlib_deviceUDIDValue {
    UIDevice *device = [UIDevice currentDevice];
    UniqueID_ = DevLibUniqueIdentifier(device);
    return UniqueID_;
}

- (NSString *)devlib_deviceSysName {
    return [UIDevice currentDevice].systemName;
}
- (NSString *)devlib_deviceSysVersion {
    return [UIDevice currentDevice].systemVersion;
}
- (NSString *)devlib_deviceHardware {
    return [self devlib_hardwareDescription];
}

- (NSString *)devlib_hardwareString {
    int name[] = {CTL_HW,HW_MACHINE};
    size_t size = 100;
    sysctl(name, 2, NULL, &size, NULL, 0); // getting size of answer
    char *hw_machine = malloc(size);
    
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}

- (void)devlib_getLastImageCompletion:(finishedWithImage)image {
    // get last image
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Preparing Image....."];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        __block UIImage *latestPhoto;
        // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            // Within the group enumeration block, filter to enumerate just photos.
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            // Chooses the photo at the last index
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                
                // The end of the enumeration is signaled by asset == nil.
                if (alAsset) {
                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                    latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                    image(latestPhoto);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ProgressHUD showSuccess:@"Finished....."];
                    });
                    // lastTakenImage = latestPhoto;
                    // Stop the enumerations
                    *stop = YES; *innerStop = YES;
                    
                }
            }];
        } failureBlock: ^(NSError *error) {
            // Typically you should handle an error more gracefully than this.
            NSLog(@"**[ DevelopersLib ] No groups");
        }];
    });
    // return [UIImage imageWithContentsOfFile:lastImagePath];
}

- (void)devlib_shareFileAtPath:(NSString *)path {
    // [mainImoWindow setHidden:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Preparing File....."];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *URL = [NSURL fileURLWithPath:path];
        TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:selfRootViewController.view andRect:selfRootViewController.view.frame];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[openInAppActivity]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            openInAppActivity.superViewController = activityViewController;
            [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                NSLog(@"[DevLib] completed: %@, \n%d, \n%@, \n%@,", activityType, completed, returnedItems, activityError);
                if (completed && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[DevLib sharedInstance] dismissMainWindow];
                }
                if (activityError && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[DevLib sharedInstance] dismissMainWindow];
                }
            }];
            // Show UIActivityViewController
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfRootViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        } else {
            // Create pop up
            UIPopoverPresentationController *presentPOP = activityViewController.popoverPresentationController;
            activityViewController.popoverPresentationController.sourceRect = CGRectMake(400,200,0,0);
            activityViewController.popoverPresentationController.sourceView = selfRootViewController.view;
            presentPOP.permittedArrowDirections = UIPopoverArrowDirectionRight;
            presentPOP.delegate = self;
            presentPOP.sourceRect = CGRectMake(700,80,0,0);
            presentPOP.sourceView = selfRootViewController.view;
            openInAppActivity.superViewController = presentPOP;
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfRootViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        }
        
    });
}

- (void)devlib_shareText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Preparing Text....."];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:@[[[ARSpeechActivity alloc] init]]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                NSLog(@"[DevLib] completed: %@, \n%d, \n%@, \n%@,", activityType, completed, returnedItems, activityError);
                if (completed && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[DevLib sharedInstance] dismissMainWindow];
                }
                if (activityError && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[DevLib sharedInstance] dismissMainWindow];
                }
            }];
            // Show UIActivityViewController
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfRootViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        } else {
            // Create pop up
            UIPopoverPresentationController *presentPOP = activityViewController.popoverPresentationController;
            activityViewController.popoverPresentationController.sourceRect = CGRectMake(400,200,0,0);
            activityViewController.popoverPresentationController.sourceView = selfRootViewController.view;
            presentPOP.permittedArrowDirections = UIPopoverArrowDirectionRight;
            presentPOP.delegate = self;
            presentPOP.sourceRect = CGRectMake(700,80,0,0);
            presentPOP.sourceView = selfRootViewController.view;
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfRootViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        }
        
    });
}

- (void)devlib_openDevlibFileBrowserWithDocumentPath:(NSString *)docPath {
    self.fileBrowser.documentPath = docPath;
    [mainImoWindow setHidden:NO];
    if (selfRootViewController.splitViewController.viewControllers.count > 0) {
        [selfRootViewController.splitViewController.viewControllers[0] presentViewController:navigationController animated:YES completion:nil];
    } else {
        [selfRootViewController presentViewController:navigationController animated:YES completion:nil];
    }
}
- (void)didSelectFile:(NSString *)path {
    [self.fileBrowser dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(filebrowser_didSelectFile:)]) {
            [self.delegate filebrowser_didSelectFile:path];
            // [mainImoWindow setHidden:YES];
        }
    }];
}
- (BOOL)shouldDeleteFileAtPath:(NSString *)path {
    if ([self.delegate respondsToSelector:@selector(filebrowser_shouldDeleteFileAtPath:)]) {
        [self.delegate filebrowser_shouldDeleteFileAtPath:path];
        return YES;
        // [mainImoWindow setHidden:YES];
    }
    return NO;
}
- (void)didLoadDirectory:(NSString *)path {
    if ([self.delegate respondsToSelector:@selector(filebrowser_didLoadDirectory:)]) {
        [self.delegate filebrowser_didLoadDirectory:path];
    }
}
- (void)fileBrowserDidCancelled {
    [self.fileBrowser dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(filebrowser_fileBrowserDidCancelled)]) {
            [self.delegate filebrowser_fileBrowserDidCancelled];
            // [mainImoWindow setHidden:NO];
        }
    }];
}
- (void)devlib_exportM4aFileFromMPMediaItems:(MPMediaItemCollection *)mediaItemCollection toFolder:(NSString *)folderName completion:(finishedWithFilePath)filePath {
    NSArray *items = mediaItemCollection.items;
    MPMediaItem *selectedItem =  [items objectAtIndex:0];
    [[MPMusicPlayerController iPodMusicPlayer] setQueueWithItemCollection:mediaItemCollection];
    [[MPMusicPlayerController iPodMusicPlayer] setNowPlayingItem:selectedItem];
    NSString* title = [selectedItem valueForProperty:MPMediaItemPropertyTitle];
    NSURL* assetURL = [selectedItem valueForProperty:MPMediaItemPropertyAssetURL];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Preparing Song....."];
    });
    [self exportM4aAssetAtURL:assetURL withTitle:title toFolder:folderName completion:^(NSURL *filePathURL) {
        filePath(filePathURL);
    }];
}
- (void)devlib_exportMp3FileFromMPMediaItems:(MPMediaItemCollection *)mediaItemCollection toFolder:(NSString *)folderName completion:(finishedWithFilePath)filePath {
    NSArray *items = mediaItemCollection.items;
    MPMediaItem *selectedItem =  [items objectAtIndex:0];
    [[MPMusicPlayerController iPodMusicPlayer] setQueueWithItemCollection:mediaItemCollection];
    [[MPMusicPlayerController iPodMusicPlayer] setNowPlayingItem:selectedItem];
    NSString* title = [selectedItem valueForProperty:MPMediaItemPropertyTitle];
    NSURL* assetURL = [selectedItem valueForProperty:MPMediaItemPropertyAssetURL];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Preparing Song....."];
    });
    [self exportMp3AssetAtURL:assetURL withTitle:title toFolder:folderName completion:^(NSURL *filePathURL) {
        filePath(filePathURL);
    }];
}
- (void)exportM4aAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title toFolder:(NSString *)folderName completion:(finishedWithFilePath)filePath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // NSString* ext = [ExportMusic extensionForAssetURL:assetURL];
        NSString* pathLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dataPath = [pathLibrary stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",folderName]];
        NSError *cFolderError = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&cFolderError]; //Create folder
            if (cFolderError) {
                NSLog(@"[DevLib] Error %@", [cFolderError localizedDescription]);
            }
        }
        
        NSURL* outURL = [[NSURL fileURLWithPath:[dataPath stringByAppendingPathComponent:@"Song"]] URLByAppendingPathExtension:@"m4a"];
        // we're responsible for making sure the destination url doesn't already exist
        [[NSFileManager defaultManager] removeItemAtURL:outURL error:nil];
        // create the import object
        ExportMusic *DevLibExport = [[ExportMusic alloc] init];
        [DevLibExport importAsset:assetURL toURL:outURL completionBlock:^(ExportMusic *import) {
            [ProgressHUD showSuccess:@"Finished....."];
            filePath(outURL);
        }];
    });
}
- (void)exportMp3AssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title toFolder:(NSString *)folderName completion:(finishedWithFilePath)filePath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // NSString* ext = [ExportMusic extensionForAssetURL:assetURL];
        NSString* pathLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dataPath = [pathLibrary stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",folderName]];
        NSError *cFolderError = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&cFolderError]; //Create folder
            if (cFolderError) {
                NSLog(@"[DevLib] Error %@", [cFolderError localizedDescription]);
            }
        }
        
        NSURL* outURL = [[NSURL fileURLWithPath:[dataPath stringByAppendingPathComponent:@"Song"]] URLByAppendingPathExtension:@"mp3"];
        // we're responsible for making sure the destination url doesn't already exist
        [[NSFileManager defaultManager] removeItemAtURL:outURL error:nil];
        // create the import object
        ExportMusic *DevLibExport = [[ExportMusic alloc] init];
        [DevLibExport importAsset:assetURL toURL:outURL completionBlock:^(ExportMusic *import) {
            [ProgressHUD showSuccess:@"Finished....."];
            filePath(outURL);
        }];
    });
}
- (void)openInAppActivityWillPresentDocumentInteractionController:(TTOpenInAppActivity*)activity {
    
}
- (void)openInAppActivityDidDismissDocumentInteractionController:(TTOpenInAppActivity*)activity {
    // [mainImoWindow setHidden:YES];
}
- (void)openInAppActivityDidEndSendingToApplication:(TTOpenInAppActivity*)activity {
    // [mainImoWindow setHidden:YES];
}

- (PSViewController *)colorPickerWithTweakDefaults:(NSString *)tweakPrefsID notification:(NSString *)notify appToKill:(NSString *)appName saveKey:(NSString *)saveKey {
    NSString *savedKey = saveKey;
    NSString *notification = notify;
    
    IMOColorViewController *colorPickerPrefs = [[IMOColorViewController alloc] init];
    colorPickerPrefs.tweakDefaults = tweakPrefsID;
    colorPickerPrefs.cellKey = savedKey;
    colorPickerPrefs.tweakKillAppName = appName;
    if (notification) {
        colorPickerPrefs.callNotification = notification;
    }
    return colorPickerPrefs;
}
- (void)sendEmailTo:(NSString *)emailAddress subject:(NSString *)subject text:(NSString *)text attachment:(NSData *)attachment mimeType:(NSString *)mimeType fileName:(NSString *)filename {
    
    if ([MFMailComposeViewController canSendMail]) {
        mailComposer = [[MFMailComposeViewController alloc]init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setToRecipients:[NSArray arrayWithObject:emailAddress]];
        [mailComposer setSubject:subject];
        [mailComposer setMessageBody:[NSString stringWithFormat:@"Don't delete any information here\n---------------------------------\n%@: %@\nDevice Type: %@\n%@\n\n[Write your message after]\n\n %@ \n\n[Write your message before]", [self devlib_deviceSysName], [self devlib_deviceSysVersion], [self devlib_deviceHardware], [self devlib_deviceUDIDValue], text] isHTML:NO];
        
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/cydia.log"] mimeType:@"text/plain" fileName:@"cydia.log"];
        system("/usr/bin/dpkg -l >/tmp/dpkgl.log");
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.log"];
        
        if (attachment != nil && [mimeType length] == 0 && [filename length] == 0) {
            return;
        } else if (attachment != nil && [mimeType length] > 1 && [filename length] > 1) {
            [mailComposer addAttachmentData:attachment mimeType:mimeType fileName:filename];
        }
        [mainImoWindow setHidden:NO];
        if (selfRootViewController.splitViewController.viewControllers.count > 0) {
            [selfRootViewController.splitViewController.viewControllers[0] presentViewController:mailComposer animated:YES completion:nil];
        } else {
            [selfRootViewController presentViewController:mailComposer animated:YES completion:nil];
        }
        
//        [self.navigationController presentViewController:mailComposer animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"iMokhles Info Page"
                                  message:@"There is no Email Account Available in your device"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}
#pragma mark - mail compose delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed: {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send Email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MFMailComposeResultSent: {
            UIAlertView *sucessAlert = [[UIAlertView alloc] initWithTitle:@"Sucess" message:@"Mail Sent [Thanks]!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [sucessAlert show];
            break;
        }
        default:
            break;
    }
    [self devlib_dismissMainWindow];
    
}

- (NSString*)devlib_hardwareDescription {
    NSString *hardware = [self devlib_hardwareString];
    if ([hardware isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([hardware isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([hardware isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([hardware isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([hardware isEqualToString:@"iPhone3,2"])    return @"iPhone 4 (GSM Rev. A)";
    if ([hardware isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([hardware isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([hardware isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([hardware isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (Global)";
    if ([hardware isEqualToString:@"iPhone5,3"])    return @"iPhone 5C (GSM)";
    if ([hardware isEqualToString:@"iPhone5,4"])    return @"iPhone 5C (Global)";
    if ([hardware isEqualToString:@"iPhone6,1"])    return @"iPhone 5S (GSM)";
    if ([hardware isEqualToString:@"iPhone6,2"])    return @"iPhone 5S (Global)";
    
    if ([hardware isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([hardware isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([hardware isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([hardware isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([hardware isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([hardware isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([hardware isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([hardware isEqualToString:@"iPad1,1"])      return @"iPad (WiFi)";
    if ([hardware isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([hardware isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([hardware isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([hardware isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([hardware isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi Rev. A)";
    if ([hardware isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([hardware isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([hardware isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
    if ([hardware isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
    if ([hardware isEqualToString:@"iPad3,3"])      return @"iPad 3 (Global)";
    if ([hardware isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,5"])      return @"iPad 4 (CDMA)";
    if ([hardware isEqualToString:@"iPad3,6"])      return @"iPad 4 (Global)";
    if ([hardware isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([hardware isEqualToString:@"iPad4,2"])      return @"iPad Air (WiFi+GSM)";
    if ([hardware isEqualToString:@"iPad4,3"])      return @"iPad Air (WiFi+CDMA)";
    if ([hardware isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    if ([hardware isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (WiFi+CDMA)";
    if ([hardware isEqualToString:@"iPad4,6"])      return @"iPad Mini Retina (Wi-Fi + Cellular CN)";
    if ([hardware isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (Wi-Fi)";
    if ([hardware isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Wi-Fi + Cellular)";
    if ([hardware isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (Wi-Fi)";
    if ([hardware isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Wi-Fi + Cellular)";
    if ([hardware isEqualToString:@"i386"])         return @"Simulator";
    if ([hardware isEqualToString:@"x86_64"])       return @"Simulator";
    
    NSLog(@"[DevLib] This is a device is not listed in this category");
    NSLog(@"[DevLib] Your device hardware string is: %@", hardware);
    if ([hardware hasPrefix:@"iPhone"]) return @"iPhone";
    if ([hardware hasPrefix:@"iPod"]) return @"iPod";
    if ([hardware hasPrefix:@"iPad"]) return @"iPad";
    return nil;
}

@end


int main(int argc, char **argv, char **envp) {
	return 0;
}

// vim:ft=objc
