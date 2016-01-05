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
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:logs forKey:kUserDefaultsLogsKey];
    [userDefaults synchronize];
}

- (void)addLogs:(NSArray<NSDictionary *> *)logs {
    NSArray<NSDictionary *> * existingLogs = [self savedLogs];
    NSArray<NSDictionary *> * mergedLogs = [NSArray mergeSafelyArray:logs withArray:existingLogs];
    [self replaceLogs:mergedLogs];
}

- (NSArray<NSDictionary *> *)savedLogs {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kUserDefaultsLogsKey];
}

- (void)deleteAllLogs {
    [self replaceLogs:nil];
}

@end
