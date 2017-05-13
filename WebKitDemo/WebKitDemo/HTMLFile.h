//
//  HTMLFile.h
//  WebKitDemo
//
//  Created by Tyler on 2017/5/12.
//  Copyright © 2017年 ZhiDian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface HTMLFile : NSObject


/**
 name for index file, including .html
 */
@property (nonatomic,strong) NSString *indexFileName;

/**
 folder name for js,css
 */
@property (nonatomic,strong) NSString *wwwFolderName;


/**
 
call this function to load webview in iOS8
 @param webView WKWebView
 */
- (void)loadWebView:(WKWebView *)webView;

@end
