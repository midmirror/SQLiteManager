//
//  NSObject+ORM.h
//
//  Created by midmirror on 2017/3/24.
//  Copyright © 2017年 midmirror. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ORM)

+ (NSString *)orm_createTableSqlProperty;
+ (NSDictionary *)orm_properties;

@end
