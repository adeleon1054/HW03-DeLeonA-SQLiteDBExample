//
//  StudentInfo.h
//  HW03-DeLeonA-SQLiteDBExample
//
//  Created by Asdruval De Leon on 11/29/17.
//  Copyright © 2017 Asdruval De Leon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentInfo : NSObject
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *address;
@property(nonatomic, strong)NSString *phone;

-(id)initWithData: (NSString *)n andAddress: (NSString *)a andPhone: (NSString *)p;

@end
