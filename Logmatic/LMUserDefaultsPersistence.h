//
//  LMUserDefaultsPersistence.h
//  Logmatic
//
//  Created by Roland Borgese on 21/12/2015.
//
//

#import "LMPersistence.h"

@interface LMUserDefaultsPersistence : NSObject<LMPersistence>

+ (nullable instancetype)sharedUserDefaultsPersistence;

+ (nonnull instancetype)new NS_UNAVAILABLE;
- (nonnull instancetype)init NS_UNAVAILABLE;
@end
