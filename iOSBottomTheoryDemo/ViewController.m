//
//  ViewController.m
//  iOSBottomTheoryDemo
//
//  Created by qzwh on 2018/11/4.
//  Copyright © 2018年 qianjinjia. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Person.h"

struct xx_cc_objc_class{
    Class isa;
};

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //iOS中对象底层包含内容
//    [self iOSObject];
    
    //KVO底层实现
//    [self KVOBottomTheory];
}

- (void)KVOBottomTheory {
    /**
     KVO底层原理：
     当一个实例变量利用KVO监听属性之变化的时候，会对该类在运行时创建一个NSKVONotifyin_Person子类，该类的isa指针指向子类，superClass指向Person类，在该类中重写了该属性的set方法，在set方法内部调用了_NSsetIntValueAndNotify，该类的内部首先调用willChangeValueForKey 将要改变方法，之后调用父类的setage方法对成员变量赋值，最后调用didChangeValueForKey已经改变方法。didChangeValueForKey中会调用监听器的监听方法，最终来到监听者的observeValueForKeyPath方法中。
     
     NSKVONotifyin_Person该类的内部重写了class方法。如果NSKVONotifyin_Person不重写class方法，那么当对象要调用class对象方法的时候就会一直向上找来到nsobject，而nsobect的class的实现大致为返回自己isa指向的类，返回p1的isa指向的类那么打印出来的类就是NSKVONotifyin_Person，但是apple不希望将NSKVONotifyin_Person类暴露出来，并且不希望我们知道NSKVONotifyin_Person内部实现，所以在内部重写了class类，直接返回Person类，所以外界在调用p1的class对象方法时，是Person类。这样p1给外界的感觉p1还是Person类，并不知道NSKVONotifyin_Person子类的存在。
     
     重写的内部实现大致为：
     - (Class) class {
        // 得到类对象，在找到类对象父类
        return class_getSuperclass(object_getClass(self));
     }
     
     如果想要手动调用KVO代理方法，必须要调用willChangeValueForKey和didChangeValueForKey，两个方法缺一不可。
     */
    
    
    Person *p1 = [Person new];
    Person *p2 = [Person new];
    
    p1.age = 1;
    p1.age = 5;
    p2.age = 2;
    
    //添加通知之前setAge地址
    NSLog(@"添加通知之前setAge地址：p1 = %p，p2 = %p", [p1 methodForSelector:@selector(setAge:)], [p2 methodForSelector:@selector(setAge:)]);
    
    [p1 addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    NSLog(@"添加通知之前setAge地址：p1 = %p，p2 = %p", [p1 methodForSelector:@selector(setAge:)], [p2 methodForSelector:@selector(setAge:)]);
    
//    [self printMethodList:[p1 class]];
//    [self printMethodList:[p2 class]];
    
//    p1.age = 10;
    [p1 willChangeValueForKey:@"age"];
    [p1 didChangeValueForKey:@"age"];
    
    [p1 removeObserver:self forKeyPath:@"age"];
}

- (void)printMethodList:(Class)cla {
    unsigned int count = 0;
    Method *methods = class_copyMethodList([Person class], &count);
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
//        SEL sel = method_getName(method);
//        const char *name = sel_getName(sel);
        NSString *methodName  = NSStringFromSelector(method_getName(method));
        NSLog(@"方法：%@", methodName);
    }
    free(methods);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"change:%@", change);
}

- (void)iOSObject {
    /**
     总结：
     //isa指向总结
     1.实例变量的isa指针指向类对象
     2.类对象的isa指针指向meta-class对象
     3.meta-class对象的isa指针指向他的父类
     4.加入父类不存在就指向元类（基类）的meta-class
     5.元类的isa指针指向它本身
     
     //实例变量、类、meta-class分别存储的内容
     1.实例变量存储类中成员变量的值
     2.类中存储实例变量、实例方法、协议等信息
     3.meta-class存储类方法
     
     //实力变量调用实例方法、实例变量过程
     1.首先通过实例变量中的isa指针，找到所属类
     2.在该类的缓存方法列表中查找，如果找到就执行，没找到会去方法列表中查找
     3.在类中没找到，会通过类中的superclass找到其该类的父类，在父类的方法列表中查询，找到执行，没找到继续通过父类中的superclass查找
     4.如果superclass没有父类，则superclass指针为nil   调用的该方法不存在
     
     //类方法调用过程
     1.首先通过isa找到该类对应的meta-class，查找调用方法是否存在，如果不存在
     2.通过superclass找到该类的父类，通过isa找到父类的meta-class，查找调用方法，如果不存在
     3.找到基类的时候依然不存在，isa指向本身，superclass指向nil。 调用该方法不存在
     */
    
    //验证上面isa指针指向是否正确
    NSObject *obj = [[NSObject alloc] init]; //实例变量 isa的地址与objClass相同
    Class objClass = [NSObject class]; //类变量 isa的地址与objMetaClass相同
    Class objMetaClass = object_getClass([NSObject class]); //父类变量
    struct xx_cc_objc_class *objectClass2 = (__bridge struct xx_cc_objc_class *)(objClass);
    NSLog(@"%@ %@ %@ %@", obj, objClass, objMetaClass, objectClass2);
    
    //通过打断点来查看isa指针地址
    //例如 p/x objMetaClass  或者使用expression objMetaClass
    
    
    
    //获取Person的成员变量
    unsigned int count = 0;
    // 拷贝出所有的成员变量列表
    Ivar *ivars = class_copyIvarList([Person class], &count);
    for (int i = 0; i < count; i++) {
        // 取出成员变量
        Ivar ivar = *(ivars + i);
        // 打印成员变量名字
        NSLog(@"成员变量：%s", ivar_getName(ivar));
    }
    // 释放
    free(ivars);
    
    //获取Person的属性
    objc_property_t *proIvars = class_copyPropertyList([Person class], &count);
    for (int i = 0; i < count; i++) {
        //取出属性
        objc_property_t pro = *(proIvars + i);
        // 打印属性名字
        NSLog(@"属性：%s", property_getName(pro));
    }
    free(proIvars);
    
    //获取方法列表
    Method *methods = class_copyMethodList([Person class], &count);
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL sel = method_getName(method);
        const char *name = sel_getName(sel);
        NSLog(@"方法：%s", name);
    }
    free(methods);
}

@end
