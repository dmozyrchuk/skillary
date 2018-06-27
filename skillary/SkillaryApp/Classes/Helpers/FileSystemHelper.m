//
//  FileSystemHelper.m
//  SkillaryApp
//
//  Created by Dmitry Mozyrchuk on 26/06/2018.
//

#import "FileSystemHelper.h"


@implementation FileSystemHelper

+ (NSString *)pathForVideoAtVideoFolder {
    NSError *error;
    NSString *documentsPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                       inDomains:NSUserDomainMask] lastObject] path];
    NSString *libraryPath = [documentsPath stringByAppendingPathComponent:@"Library"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath isDirectory:nil] == NO) {

        [[NSFileManager defaultManager] createDirectoryAtPath:libraryPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:libraryPath error:&error];
    if (files.count > 0) {
        NSString *fileName = [(NSString *)[files lastObject] stringByDeletingPathExtension];
        return [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.mp4", [fileName intValue] + 1]];
    } else {
        return [libraryPath stringByAppendingPathComponent:@"0.mp4"];
    }
}

+ (void)moveVideoAtPath:(NSString *)sourcePath toPath:(NSString *)destPath {
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:sourcePath] toURL:[NSURL fileURLWithPath:destPath] error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

+ (NSString *)pathForLastVideoInLibrary {
    NSError *error;
    NSString *documentsPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                       inDomains:NSUserDomainMask] lastObject] path];
    NSString *libraryPath = [documentsPath stringByAppendingPathComponent:@"Library"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath isDirectory:nil] == NO) {

        [[NSFileManager defaultManager] createDirectoryAtPath:libraryPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:libraryPath error:&error];
    if (files.count > 0) {
        return  [libraryPath stringByAppendingPathComponent:[files lastObject] ];
    } else {
        return nil;
    }
}

+ (UIImage *)thumbnailForLatestVideoInGallery {
    NSError *error;
    NSString *pathForVideo = [FileSystemHelper pathForLastVideoInLibrary];
    if (pathForVideo != nil) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:pathForVideo]];
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        CMTime time = asset.duration;
        CMTime actualTime;
        time.value = MIN(time.value, 2);
        CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if (error == nil) {
            return  [UIImage imageWithCGImage:imageRef];
        } else {
            NSLog(@"%@", error.localizedDescription);
            return nil;
        }
    } else {
        return nil;
    }
}

+ (UIImage *)thumbnailFor:(NSString *)videoPath {
    NSError *error;
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    CMTime time = asset.duration;
    CMTime actualTime;
    time.value = MIN(time.value, 2);
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (error == nil) {
        return  [UIImage imageWithCGImage:imageRef];
    } else {
        NSLog(@"%@", error.localizedDescription);
        return nil;
    }
}

+ (NSArray <AVURLAsset *> *)getVideoFilesFromLibrary {
    NSMutableArray *videos = [[NSMutableArray alloc] init];
    NSError *error;
    NSString *documentsPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                       inDomains:NSUserDomainMask] lastObject] path];
    NSString *libraryPath = [documentsPath stringByAppendingPathComponent:@"Library"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath isDirectory:nil] == NO) {

        [[NSFileManager defaultManager] createDirectoryAtPath:libraryPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:libraryPath error:&error];
    if (files.count > 0) {
        for (NSString *file in files) {
            NSString *filePath = [libraryPath stringByAppendingPathComponent:file];
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
            [videos addObject:asset];
        }
    }
    return videos;
}

+ (NSArray *)generateThumbnailsForVideosInGallery {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSError *error;
    NSString *documentsPath = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                       inDomains:NSUserDomainMask] lastObject] path];
    NSString *libraryPath = [documentsPath stringByAppendingPathComponent:@"Library"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:libraryPath isDirectory:nil] == NO) {

        [[NSFileManager defaultManager] createDirectoryAtPath:libraryPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:libraryPath error:&error];
    if (files.count > 0) {
        for (NSString *file in files) {
            NSString *filePath = [libraryPath stringByAppendingPathComponent:file];
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
            AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
            CMTime time = asset.duration;
            CMTime actualTime;
            time.value = MIN(time.value, 2);
            CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
            if (error == nil) {
                [images addObject:[UIImage imageWithCGImage:imageRef]];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }
    return images;
}

+ (void)removeFileAtPath:(NSString *)filePath {
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error != nil) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
}

@end
