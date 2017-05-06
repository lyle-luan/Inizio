//
//  AppDelegate.m
//  Inizio
//
//  Created by Aaron on 16/8/15.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#import "AppDelegate.h"
#import "WFMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject);
    
    BOOL isFirstLaunch = ![[NSUserDefaults standardUserDefaults] boolForKey:@"NotFirstLaunch"];

    if (isFirstLaunch)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NotFirstLaunch"];
        [[NSUserDefaults standardUserDefaults] setObject:@"2.zip" forKey:@"LastClipNameKey"];
        
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        
        NSString *pic1Path = [[NSBundle mainBundle] pathForResource:@"000001" ofType:@"png"];
        NSString *movie1Path = [[NSBundle mainBundle] pathForResource:@"000001" ofType:@"mp4"];
        NSString *pic2Path = [[NSBundle mainBundle] pathForResource:@"000002" ofType:@"png"];
        NSString *movie2Path = [[NSBundle mainBundle] pathForResource:@"000002" ofType:@"mp4"];
        NSString *pic3Path = [[NSBundle mainBundle] pathForResource:@"000003" ofType:@"png"];
        NSString *movie3Path = [[NSBundle mainBundle] pathForResource:@"000003" ofType:@"mp4"];
        NSString *pic4Path = [[NSBundle mainBundle] pathForResource:@"000004" ofType:@"png"];
        NSString *movie4Path = [[NSBundle mainBundle] pathForResource:@"000004" ofType:@"mp4"];
        NSString *pic5Path = [[NSBundle mainBundle] pathForResource:@"000005" ofType:@"png"];
        NSString *movie5Path = [[NSBundle mainBundle] pathForResource:@"000005" ofType:@"mp4"];
        NSString *picDownloadPath = [[NSBundle mainBundle] pathForResource:@"Download" ofType:@"png"];
        
        [[NSFileManager defaultManager] copyItemAtPath:pic1Path toPath:[documentPath stringByAppendingPathComponent:[pic1Path lastPathComponent]] error:NULL];
        [[NSFileManager defaultManager] copyItemAtPath:movie1Path toPath:[documentPath stringByAppendingPathComponent:[movie1Path lastPathComponent]] error:NULL];
        
        [[NSFileManager defaultManager] copyItemAtPath:pic2Path toPath:[documentPath stringByAppendingPathComponent:[pic2Path lastPathComponent]] error:NULL];
        [[NSFileManager defaultManager] copyItemAtPath:movie2Path toPath:[documentPath stringByAppendingPathComponent:[movie2Path lastPathComponent]] error:NULL];
        
        [[NSFileManager defaultManager] copyItemAtPath:pic3Path toPath:[documentPath stringByAppendingPathComponent:[pic3Path lastPathComponent]] error:NULL];
        [[NSFileManager defaultManager] copyItemAtPath:movie3Path toPath:[documentPath stringByAppendingPathComponent:[movie3Path lastPathComponent]] error:NULL];
        
        [[NSFileManager defaultManager] copyItemAtPath:pic4Path toPath:[documentPath stringByAppendingPathComponent:[pic4Path lastPathComponent]] error:NULL];
        [[NSFileManager defaultManager] copyItemAtPath:movie4Path toPath:[documentPath stringByAppendingPathComponent:[movie4Path lastPathComponent]] error:NULL];
        
        [[NSFileManager defaultManager] copyItemAtPath:pic5Path toPath:[documentPath stringByAppendingPathComponent:[pic5Path lastPathComponent]] error:NULL];
        [[NSFileManager defaultManager] copyItemAtPath:movie5Path toPath:[documentPath stringByAppendingPathComponent:[movie5Path lastPathComponent]] error:NULL];
        
        [[NSFileManager defaultManager] copyItemAtPath:picDownloadPath toPath:[documentPath stringByAppendingPathComponent:[picDownloadPath lastPathComponent]] error:NULL];
    }
    return YES;
}

@end
