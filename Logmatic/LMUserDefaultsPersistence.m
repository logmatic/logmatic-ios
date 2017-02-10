//
//  LMUserDefaultsPersistence.m
//  Logmatic
//
//  Created by Roland Borgese on 21/12/2015.
//
//

#import "LMUserDefaultsPersistence.h"
#import "NSArray+LMMerge.h"

static NSString * const kUserDefaultsLogsKey = @"io.logmatic.logmatic.user-defaults.logs";

static LMUserDefaultsPersistence * sSharedUserDefaultsPersistence;

@implementation LMUserDefaultsPersistence

#pragma mark - LMUserDefaultsPersistence

+ (instancetype)sharedUserDefaultsPersistence {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedUserDefaultsPersistence = [[self alloc] init];
    });
    return sSharedUserDefaultsPersistence;
}

#pragma mark - LMPersistence

- (void)replaceLogs:(NSArray<NSDictionary *> *)logs {
    NSData *data = nil;
    if (logs) {
        data = [NSKeyedArchiver archivedDataWithRootObject:logs];
    }
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:kUserDefaultsLogsKey];
    [userDefaults synchronize];
}

- (void)addLogs:(NSArray<NSDictionary *> *)logs {
    NSArray<NSDictionary *> * existingLogs = [self savedLogs];
    NSArray<NSDictionary *> * mergedLogs = [NSArray mergeSafelyArray:logs withArray:existingLogs];
    [self replaceLogs:mergedLogs];
}

- (nullable NSArray<NSDictionary *> *)savedLogs {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLogsKey];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (void)deleteAllLogs {
    [self replaceLogs:nil];
}

@end
