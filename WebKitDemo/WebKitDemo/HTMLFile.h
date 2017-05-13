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

@property (nonatomic,strong) NSString *indexFileName;
@property (nonatomic,strong) NSString *wwwFolderName;


- (void)loadWebView:(WKWebView *)webView;

@end
