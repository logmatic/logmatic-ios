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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *data = nil;
    if (logs && logs.count > 0) {
        data = [NSKeyedArchiver archivedDataWithRootObject:logs];
        [userDefaults setObject:data forKey:kUserDefaultsLogsKey];
    } else {
        [userDefaults removeObjectForKey:kUserDefaultsLogsKey];
    }
    
    [userDefaults synchronize];
}

- (void)addLogs:(NSArray<NSDictionary *> *)logs {
    NSArray<NSDictionary *> *existingLogs = [self savedLogs];
    NSArray<NSDictionary *> *mergedLogs = [NSArray mergeSafelyArray:logs withArray:existingLogs];
    [self replaceLogs:mergedLogs];
}

- (NSArray<NSDictionary *> *)savedLogs {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    id object = [userDefaults objectForKey:kUserDefaultsLogsKey];
    NSArray<NSDictionary *> *logs = nil;
    
    if ([object isKindOfClass:[NSData class]]) {
        logs = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)object];
    }
    return logs;
}

- (void)deleteAllLogs {
    [self replaceLogs:nil];
}

@end
