//
//  JieBaBridge.m
//  GiftMoney
//
//  Created by andy.bin on 2019/9/16.
//  Copyright © 2019 binea. All rights reserved.
//

#import "JieBaBridge.h"
#import "Segmentor.h"

@implementation JieBaBridge

+(void)initJieBa {
    NSString *dictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/jieba.dict.small.utf8"];
    NSString *hmmPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/hmm_model.utf8"];
    NSString *userDictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/user.dict.utf8"];
    
    const char *cDictPath = [dictPath UTF8String];
    const char *cHmmPath = [hmmPath UTF8String];
    const char *cUserDictPath = [userDictPath UTF8String];
    
    
    JiebaInit(cDictPath, cHmmPath, cUserDictPath);
}

+(NSString*)jiebaCut:(NSString*)sentence {
    std::vector<std::string> words;
    JiebaCut([sentence UTF8String], words);
    std::string result;
    result << words;
    return [NSString stringWithUTF8String:result.c_str()];
}

@end
