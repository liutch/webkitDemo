//
//  ViewController.m
//  WebKitDemo
//
//  Created by Tyler on 2017/5/2.
//  Copyright © 2017年 ZhiDian. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "HTMLFile.h"


#define SCREEN_WIDTH    ([[UIScreen mainScreen] bounds].size.width)

#define SCREEN_HEIGHT   ([[UIScreen mainScreen] bounds].size.height)

@interface ViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKWebViewConfiguration *configuration;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect frame = CGRectMake(50, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.configuration = [[WKWebViewConfiguration alloc] init];
    self.configuration.userContentController = [[WKUserContentController alloc]init];
    self.configuration.preferences.javaScriptEnabled = YES;
    
    [self.configuration.userContentController addScriptMessageHandler:self name:@"emit"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"adminEmit"];
    [self.configuration.userContentController addScriptMessageHandler:self name:@"refreshWatcher"];
    
    self.webView = [[WKWebView alloc] initWithFrame:frame configuration:self.configuration];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.scrollView.bounces = YES;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.webView];
    [self loadUrl];
    
}

-(void)loadUrl{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"wbindex" ofType:@"html" inDirectory:@"www"];
    
    //http://www.cnblogs.com/duzhaoquan/p/6016757.html
    //    if(path){
    //        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
    //            // iOS9. One year later things are OK.
    //            NSURL *fileURL = [NSURL fileURLWithPath:path];
    //            [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    //        } else {
    //            // iOS8. Things can be workaround-ed
    //            //   Brave people can do just this
    //            //   fileURL = try! pathForBuggyWKWebView8(fileURL)
    //            //   webView.loadRequest(NSURLRequest(URL: fileURL))
    //
    //            NSURL *fileURL = [self.fileHelper fileURLForBuggyWKWebView8:[NSURL fileURLWithPath:path]];
    //            NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    //            [self.webView loadRequest:request];
    //        }
    //    }
    //     [self.webView loadFileURL:[NSURL fileURLWithPath:path] allowingReadAccessToURL:[NSURL fileURLWithPath:accessPath]];
    if(path){
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
            // iOS9.
            NSString *path2 = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:path2];
            NSString *encodedPath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            //本地请求path = encodedPath
            NSURL *fileURL = [NSURL fileURLWithPath:encodedPath];
            [self.webView loadFileURL:fileURL allowingReadAccessToURL:baseURL];
        } else {
            // iOS8.
            NSLog(@"-----path = %@",path);
            HTMLFile *hf = [[HTMLFile alloc] init];
            hf.indexFileName = @"wbindex.html";
            hf.wwwFolderName = @"www";
            [hf loadWebView:self.webView];
        }
    }
}

- (IBAction)strongLight:(UIButton *)sender {
    NSLog(@"laserPointer");
    NSString *textJS = [NSString stringWithFormat:@"buttonClick('laserPointer')"];
    [self sendMessageToH5:textJS];
}

- (IBAction)wbViewPenClick:(UIButton *)sender {
    NSLog(@"pen");
    NSString *textJS = [NSString stringWithFormat:@"buttonClick('penBtn')"];
    [self sendMessageToH5:textJS];
}

- (void) allFilesAtPath:(NSString*) dirString {
    NSLog(@" list all files ------%@",dirString);
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    for (NSString* fileName in tempArray) {
        BOOL flag = YES;
        NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                NSLog(@"fileName= %@",fileName);
            }
        }
    }
}

- (void)listAllFiles:(NSURL*)url lastComponent:(NSString*)lastComponent{
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSRange temp = [url.path rangeOfString:lastComponent];
    NSString *path = [url.path substringToIndex:temp.location];
    NSArray *files = [fileManager subpathsAtPath:path];
    for ( int i=0;i<files.count; i++ ) {
        NSLog(@" files (%d):%@",i,[files objectAtIndex:i]);
    }
}


- (IBAction)followMove:(UIButton *)sender {
    [self sendMessageToH5:@"followMove()"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark WK delegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%s",__FUNCTION__);
    /**
     *typedef NS_ENUM(NSInteger, WKNavigationActionPolicy) {
     WKNavigationActionPolicyCancel, // 取消
     WKNavigationActionPolicyAllow,  // 继续
     }
     */
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark 身份验证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    // 不要证书验证
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

#pragma mark 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%s",__FUNCTION__);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark WKNavigation导航错误
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark WKWebView终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - WKNavigationDelegate 页面加载
#pragma mark 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%@", error.localizedDescription);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    self.webView.frame = CGRectMake(50, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    NSLog(@"-->%f,%f,%f,%f",self.webView.frame.size.width,self.webView.frame.size.height,self.webView.frame.origin.x,self.webView.frame.origin.y);
    webView.scrollView.bounces = NO;
    
    NSLog(@"------------webViewDidFinishLoad--------------");
    
    //    _context = [_h5view valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //    _context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //    _context.exceptionHandler = ^(JSContext *con, JSValue *exception) {
    //        NSLog(@"JSException:\n%@",exception);
    //        con.exception = exception;
    //    };
    //    if([_myWbView canBecomeFirstResponder]){
    //        [_myWbView becomeFirstResponder];
    //    }
    
    
//    [self wbViewPenClick];
    
    [self sendMessageToH5:@"whiteboard.refreshWatcher()"];
}


-(void)sendMessageToH5:(NSString*)string{
    NSLog(@"==sendMsg = %@",string);
    [self.webView evaluateJavaScript:string completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"%s",__FUNCTION__);
        NSLog(@" === %@,  %@",response,error);
    }];
}

- (IBAction)wbViewPenClick {
    NSLog(@"pen");
    NSString *textJS = [NSString stringWithFormat:@"buttonClick('penBtn')"];
    [self sendMessageToH5:textJS];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"--%@",NSStringFromSelector(_cmd));
    NSLog(@"--%@",message.body);
    
    if ([message.name isEqualToString:@"emit"]) {
        NSLog(@"=== emit");
    }
    
    if ([message.name isEqualToString:@"refreshWatcher"]) {
        
    }
    
    if ([message.name isEqualToString:@"adminEmit"]) {
        
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
