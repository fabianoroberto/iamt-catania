//
//  XMLReader.h
//  iamtcatania
//
//  Created by Dr Thief on 31/12/13.
//  Copyright (c) 2013 Dr Thief. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject <NSXMLParserDelegate> {
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError *errorPointer;
}

+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end
