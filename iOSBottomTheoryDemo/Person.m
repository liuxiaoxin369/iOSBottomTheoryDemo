//
//  Person.m
//  iOSBottomTheoryDemo
//
//  Created by qzwh on 2018/11/4.
//  Copyright © 2018年 qianjinjia. All rights reserved.
//

#import "Person.h"

@implementation Person

- (void)sayHi {
    
}

- (void)willChangeValueForKey:(NSString *)key {
    NSLog(@"----willChangeValueForKey----start");
    [super willChangeValueForKey:key];
    NSLog(@"----willChangeValueForKey----end");
}

- (void)didChangeValueForKey:(NSString *)key {
    NSLog(@"----didChangeValueForKey----start");
    [super didChangeValueForKey:key];
    NSLog(@"----didChangeValueForKey----end");
}

@end
