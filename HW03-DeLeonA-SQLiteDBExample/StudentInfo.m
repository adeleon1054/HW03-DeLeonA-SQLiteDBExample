//
//  StudentInfo.m
//  HW03-DeLeonA-SQLiteDBExample
//
//  Created by Asdruval De Leon on 11/29/17.
//  Copyright © 2017 Asdruval De Leon. All rights reserved.
//

#import "StudentInfo.h"

@implementation StudentInfo
-(id)initWithData: (NSString *)n andAddress: (NSString *)a andPhone: (NSString *)p{
    if(self == [super init]){
        [self setName:n];
        [self setAddress:a];
        [self setPhone:p];
    }
    return self;
}
@end
