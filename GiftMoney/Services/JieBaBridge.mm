//
//  JieBaBridge.m
//  GiftMoney
//
//  Created by andy.bin on 2019/9/16.
//  Copyright © 2019 binea. All rights reserved.
//

#import "JieBaBridge.h"
#import "Segmentor.h"

@implementation JieBaTag

- (instancetype)initWith:(NSString*)word tag:(NSString*)tag
{
    self = [super init];
    if (self) {
        self.word = word;
        self.tag = tag;
    }
    return self;
}

@end


@implementation JieBaBridge

+(void)initJieBa {
    NSString *dictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/jieba.dict.small.utf8"];
    NSString *hmmPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/hmm_model.utf8"];
    NSString *userDictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/user.dict.utf8"];
    NSString *idfPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/idf.utf8"];
    NSString *stopWordPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/stop_words.utf8"];
    
    const char *cDictPath = [dictPath UTF8String];
    const char *cHmmPath = [hmmPath UTF8String];
    const char *cUserDictPath = [userDictPath UTF8String];
    const char *cIDFPath = [idfPath UTF8String];
    const char *cStopWordPath = [stopWordPath UTF8String];
    
    JiebaInit(cDictPath, cHmmPath, cUserDictPath, cIDFPath, cStopWordPath);
}
+(void)insertUserWord:(NSString*)word tag:(NSString*)tag {
    JiebaInsertUserWord([word UTF8String], [tag UTF8String]);
}

+(NSString*)jiebaCut:(NSString*)sentence {
    std::vector<std::string> words;
    JiebaCut([sentence UTF8String], words);
    std::string result;
    result << words;
    return [NSString stringWithUTF8String:result.c_str()];
}

+(NSMutableArray<JieBaTag*>*)jiebaTag:(NSString*)sentence {
    std::vector<std::pair<std::string, std::string> > tags;
    JiebaTag([sentence UTF8String], tags);
    int count = (int)tags.size();
    NSMutableArray<JieBaTag*>* result = [NSMutableArray<JieBaTag*> arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        NSString* word = [NSString stringWithUTF8String:tags[i].first.c_str()];
        NSString* tagName = [NSString stringWithUTF8String:tags[i].second.c_str()];
        JieBaTag* tag = [[JieBaTag alloc] initWith:word tag:tagName];
        [result addObject:tag];
    }
    return result;
}

@end
