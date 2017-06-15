//
//  NSObject+ORM.m
//
//  Created by midmirror on 2017/3/24.
//  Copyright © 2017年 midmirror. All rights reserved.
//

#import "NSObject+ORM.h"
#import <objc/runtime.h>

/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"
#define PrimaryKey  @"primary key"

#define primaryId   @"id"

@implementation NSObject (ORM)

+ (NSString *)orm_createTableSqlProperty {
    
    NSMutableString *sqlSrc = [NSMutableString string];
    NSDictionary *propertyDict = [self.class orm_properties];
    
    for (NSString *propertyName in propertyDict.allKeys) {
        NSString *propertyType = propertyDict[propertyName];
        [sqlSrc appendString:[NSString stringWithFormat:@"%@ %@,", propertyName, propertyType]];
    }
    NSString *sql = [sqlSrc substringToIndex:sqlSrc.length-1]; // 删除最后一个逗号
    NSLog(@"sql:%@",sql);
    
    return sql;
}

/** 获取所有属性，包含主键pk */
+ (NSDictionary *)orm_properties {
    
    NSMutableDictionary *propertyDict = [[NSMutableDictionary alloc] init];
    
    [propertyDict setObject:[NSString stringWithFormat:@"%@ %@",SQLTEXT,PrimaryKey] forKey:primaryId];
    
    NSArray *blackList = [[self class] blackList];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([blackList containsObject:propertyName]) {
            continue;
        }
//        [proNames addObject:propertyName];
        //获取属性类型等参数
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         各种符号对应类型，部分类型在新版SDK中有所变化，如long 和long long
         c char         C unsigned char
         i int          I unsigned int
         l long         L unsigned long
         s short        S unsigned short
         d double       D unsigned double
         f float        F unsigned float
         q long long    Q unsigned long long
         B BOOL
         @ 对象类型 //指针 对象类型 如NSString 是@“NSString”
         
         
         64位下long 和long long 都是Tq
         SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
         因为在项目中用的类型不多，故只考虑了少数类型
         */
        NSString *propType = @"";
        if ([propertyType hasPrefix:@"T@\"NSString\""]) {
            propType = SQLTEXT;
        } else if ([propertyType hasPrefix:@"T@\"NSData\""]) {
            propType = SQLBLOB;
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]||[propertyType hasPrefix:@"Tq"]||[propertyType hasPrefix:@"TQ"]) {
            propType = SQLINTEGER;
        } else {
            propType = SQLREAL;
        }
        [propertyDict setObject:propType forKey:propertyName];
    }
    free(properties);
    
    return propertyDict;
}

#pragma mark - must be override method
/** 如果子类中有一些property不需要创建数据库字段，那么这个方法必须在子类中重写
 */
+ (NSArray *)blackList
{
    return [NSArray array];
}

@end
