//
//  NSArray+LMMerge.m
//  Logmatic
//
//  Created by Roland Borgese on 21/12/2015.
//
//

#import "NSArray+LMMerge.h"

@implementation NSArray (LMMerge)

+ (NSArray *)mergeSafelyArray:(NSArray *)array1 withArray:(NSArray *)array2 {
    if (array1 && array2) {
        NSMutableArray * newArray1 = [NSMutableArray arrayWithArray:array1];
        [newArray1 addObjectsFromArray:array2];
        return newArray1;
    }
    return array1 ?: array2;
}

+ (NSArray *)mergeSafelyArrays:(NSArray<NSArray *> *)arrays {
    NSMutableArray * merged = [NSMutableArray new];
    for (NSArray * array in arrays) {
        [merged addObjectsFromArray:array];
    }
    return merged;
}

@end
