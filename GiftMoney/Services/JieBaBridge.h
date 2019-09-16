//
//  JieBaBridge.h
//  GiftMoney
//
//  Created by andy.bin on 2019/9/16.
//  Copyright © 2019 binea. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JieBaTag : NSObject

@property(nonatomic, copy) NSString* word;
@property(nonatomic, copy) NSString* tag;

- (instancetype)initWith:(NSString*)word tag:(NSString*)tag;

@end

@interface JieBaBridge : NSObject

+(void)initJieBa;
+(NSString*)jiebaCut:(NSString*)sentence;
+(NSMutableArray<JieBaTag*>*)jiebaTag:(NSString*)sentence;

@end

NS_ASSUME_NONNULL_END
