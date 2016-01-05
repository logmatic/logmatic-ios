//
//  LMLogger.h
//  Logmatic
//
//  Created by Roland Borgese on 17/12/2015.
//
//

#import "LMPersistence.h"

typedef NS_ENUM(NSUInteger, LMLogLevel) {
    LMLogLevelNone,
    LMLogLevelShort,
    LMLogLevelVerbose
};

@interface LMLogger : NSObject
@property (nonatomic) LMLogLevel logLevel;

+ (nullable instancetype)sharedLogger;

- (void)setKey:(nullable NSString *)key;
- (void)setMetas:(nullable NSDictionary *)metas;
- (void)setIPTracking:(nullable NSString *)ipTracking;
- (void)setUserAgentTracking:(nullable NSString *)userAgentTracking;
- (void)setSendingFrequency:(NSTimeInterval)frequency;
- (void)usePersistence:(BOOL)usePersistence; //if YES, when the app is terminated, the ongoing logs are saved and will be send again on next launching

- (void)startLogger;
- (void)stopLogger;
- (void)log:(nullable NSDictionary *)dictionary withMessage:(nullable NSString *)message;

//for the moment, only one logger at the same time is available
+ (nullable instancetype)new NS_UNAVAILABLE;
- (nullable instancetype)init NS_UNAVAILABLE;
@end
