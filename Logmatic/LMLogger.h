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
@property (nonatomic, copy, nullable) NSString * key;
@property (nonatomic, copy, nullable) NSDictionary * metas;
@property (nonatomic) NSTimeInterval sendingFrequency;
@property (nonatomic) BOOL usePersistence; //if YES, when the app is terminated, the ongoing logs are saved and will be send again on next launching
@property (nonatomic) LMLogLevel logLevel;

+ (nullable instancetype)sharedLogger;

- (void)setIPTracking:(nullable NSString *)ipTracking;
- (void)setUserAgentTracking:(nullable NSString *)userAgentTracking;

- (void)startLogger;
- (void)stopLogger;
- (void)log:(nullable NSDictionary *)dictionary withMessage:(nullable NSString *)message;

// for the moment, only one logger at the same time is available
+ (nonnull instancetype)new NS_UNAVAILABLE;
- (nonnull instancetype)init NS_UNAVAILABLE;
@end
