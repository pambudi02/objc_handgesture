//
//  PointsPair.m
//  HandGesture
//
//  Created by Pambudi on 21/11/20.
//

#import "PointsPair.h"

@interface PointsPair()
{
    NSDictionary *_dict;
}

@end

@implementation PointsPair

- (id)initWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt {
    _dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys count:cnt];
    return self;
}

- (NSUInteger)count {
    return [_dict count];
}

- (id)objectForKey:(id)aKey {
    return [_dict objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return [_dict keyEnumerator];
}

-(void)setThumbTip:(CGPoint)point
{
    NSMutableDictionary *mdd = [self mutableCopy];
    [mdd setValue:CFBridgingRelease(CGPointCreateDictionaryRepresentation(point))
           forKey:kPointPairThumbTip];
    _dict = [mdd copy];
}

-(CGPoint)thumbTip
{
    CFDictionaryRef dict = (__bridge CFDictionaryRef)([self objectForKey:kPointPairThumbTip]);
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    return point;
}


-(void)setIndexTip:(CGPoint)point
{
    NSMutableDictionary *mdd = [self mutableCopy];
    [mdd setValue:CFBridgingRelease(CGPointCreateDictionaryRepresentation(point))
           forKey:kPointPairIndexTip];
    _dict = [mdd copy];
}


-(CGPoint)indexTip
{
    CFDictionaryRef dict = (__bridge CFDictionaryRef)([self objectForKey:kPointPairIndexTip]);
    CGPoint point;
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    return point;
}

+(instancetype)pointsPairWithThumbTip:(CGPoint)thumbTip indexTip:(CGPoint)indexTip
{
    NSMutableDictionary *mdd = [NSMutableDictionary new];
    [mdd setValue:CFBridgingRelease(CGPointCreateDictionaryRepresentation(thumbTip))
           forKey:kPointPairThumbTip];
    [mdd setValue:CFBridgingRelease(CGPointCreateDictionaryRepresentation(indexTip))
           forKey:kPointPairIndexTip];
    
    return [PointsPair dictionaryWithDictionary:mdd];
}
@end
