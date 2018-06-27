//
//  FileSystemHelper.h
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 26/06/2018.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface FileSystemHelper : NSObject

+ (NSString *)pathForVideoAtVideoFolder;
+ (void)moveVideoAtPath:(NSString *)sourcePath toPath:(NSString *)destPath;
+ (NSArray *)generateThumbnailsForVideosInGallery;
+ (UIImage *)thumbnailForLatestVideoInGallery;
+ (NSString *)pathForLastVideoInLibrary;
+ (UIImage *)thumbnailFor:(NSString *)videoPath;
+ (NSArray <AVURLAsset *> *)getVideoFilesFromLibrary;
+ (void)removeFileAtPath:(NSString *)filePath;

@end
