//
//  Order.m
//  fszl
//
//  Created by huqin on 1/16/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "Order.h"
#import <objc/runtime.h>

@implementation Order

- (NSArray *)propertyNames{
    // Check for a cached value (we use _cmd as the cache key,
    // which represents @selector(propertyNames))
    NSMutableArray *array = objc_getAssociatedObject([self class], _cmd);
    if (array)
    {
        return array;
    }
    
    // Loop through our superclasses until we hit NSObject
    array = [NSMutableArray array];
    Class subclass = [self class];
    while (subclass != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(subclass,
                                                             &propertyCount);
        for (int i = 0; i < propertyCount; i++)
        {
            // Get property name
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = @(propertyName);
            
            // Check if there is a backing ivar
            char *ivar = property_copyAttributeValue(property, "V");
            if (ivar)
            {
                // Check if ivar has KVC-compliant name
                NSString *ivarName = @(ivar);
                if ([ivarName isEqualToString:key] ||
                    [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
                {
                    // setValue:forKey: will work
                    [array addObject:key];
                }
                free(ivar);
            }
        }
        free(properties);
        subclass = [subclass superclass];
    }
    
    // Cache and return array
    objc_setAssociatedObject([self class], _cmd, array, 
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return array;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [self init]))
    {
        // Loop through the properties
        for (NSString *key in [self propertyNames])
        {
            // Decode the property, and use the KVC setValueForKey: method to set it
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    // Loop through the properties
    for (NSString *key in [self propertyNames])
    {
        // Use the KVC valueForKey: method to get the property and then encode it
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

@end
