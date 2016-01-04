//
//  NSArray+LMMerge.h
//  Logmatic
//
//  Created by Roland Borgese on 21/12/2015.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (LMMerge)

+ (NSArray *)mergeSafelyArray:(NSArray *)array1 withArray:(NSArray *)array2;
+ (NSArray *)mergeSafelyArrays:(NSArray<NSArray *> *)arrays;
@end
