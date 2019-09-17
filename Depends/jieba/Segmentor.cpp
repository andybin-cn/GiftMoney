//
//  Segmentor.cpp
//  iosjieba
//
//  Created by yanyiwu on 14/12/24.
//  Copyright (c) 2014年 yanyiwu. All rights reserved.
//

#include <stdio.h>
#include <string>
#include <vector>
#include "CppJieba/Jieba.hpp"
#include <iostream>

using namespace cppjieba;

cppjieba::Jieba* globalSegmentor;

void JiebaInit(const string& dictPath, const string& hmmPath, const string& userDictPath, const string& idfPath, const string& stopWordPath)
{
    if(globalSegmentor == NULL) {
        globalSegmentor = new Jieba(dictPath,
                                    hmmPath,
                                    userDictPath,
                                    idfPath,
                                    stopWordPath);
    }
    cout << __FILE__ << __LINE__ << endl;
}

void JiebaCut(const string& sentence, vector<string>& words)
{
    assert(globalSegmentor);
    globalSegmentor->Cut(sentence, words);
    cout << __FILE__ << __LINE__ << endl;
    cout << words << endl;
}

void JiebaTag(const string& sentence, vector<pair<string, string>>& tags)
{
    assert(globalSegmentor);
    globalSegmentor->Tag(sentence, tags);
    cout << __FILE__ << __LINE__ << endl;
    cout << tags << endl;
}

void JiebaInsertUserWord(const string& word, const string& tag)
{
    assert(globalSegmentor);
    globalSegmentor->InsertUserWord(word, tag);
}
