//
//  Person.h
//  iOSBottomTheoryDemo
//
//  Created by qzwh on 2018/11/4.
//  Copyright © 2018年 qianjinjia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
{
    NSString *_sex;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger age;

- (void)sayHi;

@end
