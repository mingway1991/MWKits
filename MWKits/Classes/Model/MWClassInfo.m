//
//  MWClassInfo.m
//  MWKits
//
//  Created by 石茗伟 on 2018/9/14.
//

#import "MWClassInfo.h"
#import "MWDefines.h"

/** 根据attrType转换成对应的枚举 **/
MWPropertyType MWPropertyGetType(const char *attrType) {
    char *type = (char *)attrType;
    if (!type) return MWPropertyTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return MWPropertyTypeUnknown;
    
    len = strlen(type);
    if (len == 0) return MWPropertyTypeUnknown;
    
    switch (*type) {
        case 'v': return MWPropertyTypeVoid;
        case 'B': return MWPropertyTypeBool;
        case 'c': return MWPropertyTypeInt8;
        case 'C': return MWPropertyTypeUInt8;
        case 's': return MWPropertyTypeInt16;
        case 'S': return MWPropertyTypeUInt16;
        case 'i': return MWPropertyTypeInt32;
        case 'I': return MWPropertyTypeUInt32;
        case 'l': return MWPropertyTypeInt32;
        case 'L': return MWPropertyTypeUInt32;
        case 'q': return MWPropertyTypeInt64;
        case 'Q': return MWPropertyTypeUInt64;
        case 'f': return MWPropertyTypeFloat;
        case 'd': return MWPropertyTypeDouble;
        case 'D': return MWPropertyTypeLongDouble;
        case '#': return MWPropertyTypeClass;
        case ':': return MWPropertyTypeSEL;
        case '*': return MWPropertyTypeCString;
        case '^': return MWPropertyTypePointer;
        case '[': return MWPropertyTypeCArray;
        case '(': return MWPropertyTypeUnion;
        case '{': return MWPropertyTypeStruct;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return MWPropertyTypeBlock;
            else {
                //针对对象类型的，获取类名
                NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithUTF8String:type]];
                if ([scanner scanString:@"@\"" intoString:NULL]) {
                    Class cls;
                    NSString *clsName = nil;
                    if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                        if (clsName.length) cls = objc_getClass(clsName.UTF8String);
                    }
                    if (!cls) return MWPropertyTypeUnknown;
                    if ([cls isSubclassOfClass:[NSMutableString class]]) return MWPropertyTypeNSMutableString;
                    if ([cls isSubclassOfClass:[NSString class]]) return MWPropertyTypeNSString;
                    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return MWPropertyTypeNSDecimalNumber;
                    if ([cls isSubclassOfClass:[NSNumber class]]) return MWPropertyTypeNSNumber;
                    if ([cls isSubclassOfClass:[NSValue class]]) return MWPropertyTypeNSValue;
                    if ([cls isSubclassOfClass:[NSMutableData class]]) return MWPropertyTypeNSMutableData;
                    if ([cls isSubclassOfClass:[NSData class]]) return MWPropertyTypeNSData;
                    if ([cls isSubclassOfClass:[NSDate class]]) return MWPropertyTypeNSDate;
                    if ([cls isSubclassOfClass:[NSURL class]]) return MWPropertyTypeNSURL;
                    if ([cls isSubclassOfClass:[NSMutableArray class]]) return MWPropertyTypeNSMutableArray;
                    if ([cls isSubclassOfClass:[NSArray class]]) return MWPropertyTypeNSArray;
                    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return MWPropertyTypeNSMutableDictionary;
                    if ([cls isSubclassOfClass:[NSDictionary class]]) return MWPropertyTypeNSDictionary;
                    if ([cls isSubclassOfClass:[NSMutableSet class]]) return MWPropertyTypeNSMutableSet;
                    if ([cls isSubclassOfClass:[NSSet class]]) return MWPropertyTypeNSSet;
                }
            }
        }
        default: return MWPropertyTypeUnknown;
    }
}

static force_inline BOOL MWPropertyTypeIsNumber(MWPropertyType type) {
    switch (type) {
        case MWPropertyTypeBool:
        case MWPropertyTypeInt8:
        case MWPropertyTypeUInt8:
        case MWPropertyTypeInt16:
        case MWPropertyTypeUInt16:
        case MWPropertyTypeInt32:
        case MWPropertyTypeUInt32:
        case MWPropertyTypeInt64:
        case MWPropertyTypeUInt64:
        case MWPropertyTypeFloat:
        case MWPropertyTypeDouble:
        case MWPropertyTypeLongDouble: return YES;
        default: return NO;
    }
}

#pragma mark - MWPropertyInfo

@interface MWPropertyInfo ()

@property (nonatomic, assign, readwrite) objc_property_t property;
@property (nonatomic, copy, readwrite) NSString *propertyName;
@property (nonatomic, copy, readwrite) NSString *attrType;
@property (nonatomic, assign, readwrite) SEL getter;
@property (nonatomic, assign, readwrite) SEL setter;

@property (nonatomic, assign, readwrite, nullable) Class cls;
@property (nonatomic, assign, readwrite) MWPropertyType type;
@property (nonatomic, assign ,readwrite) BOOL isNumber;
@property (nonatomic, assign ,readwrite) BOOL isFromFoundation;

@end

@implementation MWPropertyInfo

- (instancetype)copyWithZone:(NSZone *)zone {
    MWPropertyInfo *info = [[self class] alloc];
    return info;
}

- (instancetype)initWithProperty:(objc_property_t)property {
    if (self = [super init]) {
        _property = property;
        const char *name = property_getName(property);
        if (name) {
            _propertyName = [NSString stringWithUTF8String:name];
        }
        
        unsigned int attrCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
        for (unsigned int i = 0; i < attrCount; i++) {
            switch (attrs[i].name[0]) {
                case 'T': { // Type
                    if (attrs[i].value) {
                        _attrType = [NSString stringWithUTF8String:attrs[i].value];
                        _type = MWPropertyGetType(attrs[i].value);
                        _isNumber = MWPropertyTypeIsNumber(_type);
                        _isFromFoundation = (_type == MWPropertyTypeUnknown) ? NO : YES;
                    }
                    break;
                }
                case 'G':{
                    if (attrs[i].value) {
                        _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                    break;
                }
                case 'S': {
                    if (attrs[i].value) {
                        _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                    }
                    break;
                }
                case 'V':
                case 'R':
                case 'C':
                case '&':
                case 'N':
                case 'D':
                    break;
            }
        }
        if (attrs) {
            free(attrs);
            attrs = NULL;
        }
        
        if (_propertyName.length) {
            //默认的getter和setter方法
            if (!_getter) {
                _getter = NSSelectorFromString(_propertyName);
            }
            if (!_setter) {
                _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_propertyName substringToIndex:1].uppercaseString, [_propertyName substringFromIndex:1]]);
            }
        }
    }
    return self;
}



@end

#pragma mark - MWClassInfo

@interface MWClassInfo ()

@property (nonatomic, assign, readwrite) Class cls;
@property (nonatomic, copy, readwrite) NSString *className;
@property (nonatomic, strong, readwrite) NSDictionary<NSString *, MWPropertyInfo *> *propertyDict;

@end

@implementation MWClassInfo

- (instancetype)copyWithZone:(NSZone *)zone {
    MWClassInfo *info = [[self class] alloc];
    info.cls = _cls;
    info.className = [_className copy];
    info.propertyDict = [_propertyDict copy];
    return info;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    if (!cls) return nil;
    static CFMutableDictionaryRef classCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    MWClassInfo *info = CFDictionaryGetValue(classCache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    if (!info) {
        info = [[MWClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

- (instancetype)initWithClass:(Class)cls {
    if (self = [super init]) {
        _cls = cls;
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        NSMutableDictionary *propertyDict = [NSMutableDictionary dictionaryWithCapacity:count];
        
        for(int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            MWPropertyInfo *info = [[MWPropertyInfo alloc] initWithProperty:property];
            [propertyDict setObject:info forKey:[NSString stringWithUTF8String:propertyName]];
        }
        
        if (properties) {
            free(properties);
            properties = NULL;
        }
        
        _className = NSStringFromClass(cls);
        _propertyDict = propertyDict;
    }
    return self;
}

@end
