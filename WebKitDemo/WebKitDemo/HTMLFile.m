//
//  HTMLFile.m
//  WebKitDemo
//
//  Created by Tyler on 2017/5/12.
//  Copyright © 2017年 ZhiDian. All rights reserved.
//

#import "HTMLFile.h"
#import <objc/message.h>

@implementation HTMLFile

- (instancetype)init{
    if ( self=[super init] ) {
        
    }
    return self;
}

- (void)loadWebView:(WKWebView *)webView{
//    SEL sel = NSSelectorFromString(@"loadFileURL:allowingReadAccessToURL:");
    NSURL *urlToLoad = [self createTmpFileUrlHelper];
//    NSString* directory = [urlToLoad.path stringByDeletingLastPathComponent];
//    ((id (*)(id, SEL, id, id))objc_msgSend)(webView, sel, [NSURL URLWithString:urlToLoad], [NSURL URLWithString:directory]);
//    [webView loadFileURL:[NSURL URLWithString:urlToLoad] allowingReadAccessToURL:[NSURL URLWithString:directory]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlToLoad];
    [webView loadRequest:request];
}
- (NSURL*) createTmpFileUrlHelper{
    return [self createFileUrlHelper:[self copyBundleWWWFolderToFolder:NSTemporaryDirectory()]];
}

- (NSURL*) createFileUrlHelper:(NSString*)folderPath
{
    NSString* path = [folderPath stringByAppendingPathComponent:self.indexFileName];
    NSURL* url = [NSURL fileURLWithPath:path];
    return url;
}

- (NSString*) wwwBundleFolderPath
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* wwwFileBundlePath = [mainBundle pathForResource:self.indexFileName ofType:@"" inDirectory:self.wwwFolderName];
    return [wwwFileBundlePath stringByDeletingLastPathComponent];
}


- (NSString*) copyBundleWWWFolderToFolder:(NSString*)folderPath
{
    NSString* location = nil;
    BOOL copyOK = NO;
    
    // is the bundle www index.html there
    NSString* indexFileWWWBundlePath = [self.wwwBundleFolderPath stringByAppendingPathComponent:self.indexFileName];
    BOOL readable = [[NSFileManager defaultManager] isReadableFileAtPath:indexFileWWWBundlePath];
    NSLog(@"File %@ is readable: %@", indexFileWWWBundlePath, readable? @"YES" : @"NO");
    
    if (readable) {
        NSString* newFolderPath = [folderPath stringByAppendingPathComponent:@"www"];
        
        // create the folder, if needed
        [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        // copy
        NSError* error = nil;
        if ((copyOK = [self copyFrom:self.wwwBundleFolderPath to:newFolderPath error:&error])) {
            location = newFolderPath;
        }
        [self listAllFiles:newFolderPath];
        NSLog(@"Copy from %@ to %@ is ok: %@", folderPath, newFolderPath, copyOK? @"YES" : @"NO");
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            location = nil;
        }
    }
    
    return location;
}

- (void)listAllFiles:(NSString*)path{
    NSLog(@"-->path = %@",path);
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSArray *files = [fileManager subpathsAtPath:path];
    for ( int i=0;i<files.count; i++ ) {
        NSLog(@" files (%d):%@",i,[files objectAtIndex:i]);
    }
}

- (BOOL)copyFrom:(NSString*)src to:(NSString*)dest error:(NSError* __autoreleasing*)error
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:src]) {
        NSString* errorString = [NSString stringWithFormat:@"%@ file does not exist.", src];
        if (error != NULL) {
            (*error) = [NSError errorWithDomain:@"TestDomainTODO"
                                           code:1
                                       userInfo:[NSDictionary dictionaryWithObject:errorString
                                                                            forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }
    
    // generate unique filepath in temp directory
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    NSString* tempBackup = [[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString*)uuidString] stringByAppendingPathExtension:@"bak"];
    CFRelease(uuidString);
    CFRelease(uuidRef);
    
    BOOL destExists = [fileManager fileExistsAtPath:dest];
    
    // backup the dest
    if (destExists && ![fileManager copyItemAtPath:dest toPath:tempBackup error:error]) {
        return NO;
    }
    
    // remove the dest
    if (destExists && ![fileManager removeItemAtPath:dest error:error]) {
        return NO;
    }
    
    // create path to dest
    if (!destExists && ![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:error]) {
        return NO;
    }
    
    // copy src to dest
    if ([fileManager copyItemAtPath:src toPath:dest error:error]) {
        // success - cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return YES;
    } else {
        // failure - we restore the temp backup file to dest
        [fileManager copyItemAtPath:tempBackup toPath:dest error:error];
        // cleanup - delete the backup to the dest
        if ([fileManager fileExistsAtPath:tempBackup]) {
            [fileManager removeItemAtPath:tempBackup error:error];
        }
        return NO;
    }
}


@end
