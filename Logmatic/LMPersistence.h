//
//  LMPersistence.h
//  Logmatic
//
//  Created by Roland Borgese on 21/12/2015.
//
//

#import <Foundation/Foundation.h>

@protocol LMPersistence <NSObject>
- (void)replaceLogs:(nullable NSArray<NSDictionary *> *)logs;
- (void)addLogs:(nullable NSArray<NSDictionary *> *)logs;
- (void)deleteAllLogs;
- (nullable NSArray<NSDictionary *> *)savedLogs;
@end
