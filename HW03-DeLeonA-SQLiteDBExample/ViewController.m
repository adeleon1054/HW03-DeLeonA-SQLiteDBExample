//
//  ViewController.m
//  HW03-DeLeonA-SQLiteDBExample
//
//  Created by Asdruval De Leon on 11/27/17.
//  Copyright © 2017 Asdruval De Leon. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "StudentInfo.h"

@interface ViewController ()
@property (nonatomic, strong)NSString * databaseName;
@property (nonatomic, strong)NSString * databasePath;
@property (nonatomic, strong)NSMutableArray * people;

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;

@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _people = [[NSMutableArray alloc]init];
    _databaseName = @"MyStudents.db";
    
    //find the path to document folder
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    _databasePath = [documentsDir stringByAppendingPathComponent:_databaseName];
    
    [self copyDatabasetoDocumentsDirectory];
    
    [self readFromDatabase];
    
    
}
-(void)readFromDatabase{
    //clear out the array
    [_people removeAllObjects];
    
    sqlite3 *database;
    //1. open the db
    if(sqlite3_open([_databasePath UTF8String],&database)== SQLITE_OK){
        
        //2. create a query
        char *sqlStatement = "select * from students";
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement,-1,&compiledStatement,NULL)== SQLITE_OK){
            while (sqlite3_step(compiledStatement)== SQLITE_ROW) {
                char *n = (char *)sqlite3_column_text(compiledStatement, 1);
                char *a = (char *)sqlite3_column_text(compiledStatement, 2);
                char *p = (char *)sqlite3_column_text(compiledStatement, 3);
                
                //convert chart to string
                NSString* name = [NSString stringWithUTF8String:n];
                NSString* address = [NSString stringWithUTF8String:a];
                NSString* phone = [NSString stringWithUTF8String:p];
                
                StudentInfo *aStudent = [[StudentInfo alloc]initWithData:name andAddress:address andPhone:phone];
                [_people addObject:aStudent];

            }
        }
        //free the allocated memory
        sqlite3_finalize(compiledStatement);
    }
    
    //close the DB connection
    sqlite3_close(database);
}

-(void)copyDatabasetoDocumentsDirectory{
    bool success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    success = [fileManager fileExistsAtPath:_databaseName];
    
    if (success)
        return;
    
    //if this is our first time using the app
    //copy the DB from app's Bundle to Docs dir
    NSString *databasePathFromApp = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:_databaseName];
    
    [fileManager copyItemAtPath:
     databasePathFromApp toPath:_databasePath error:nil];
}

-(BOOL)insertIntoDatabase:(StudentInfo *)aStudent{
    sqlite3 *database;
    
    BOOL returnCode = YES;
    
    if (sqlite3_open([_databasePath UTF8String], &database)== SQLITE_OK){
        char * sqlStatement = "insert into students values (NULL, ?,?,?)";
    
        sqlite3_stmt *complitedStatement;
        
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &complitedStatement, NULL)==SQLITE_OK){
            sqlite3_bind_text(complitedStatement, 1, [aStudent.name UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(complitedStatement, 2, [aStudent.address UTF8String],-1,SQLITE_TRANSIENT);
            sqlite3_bind_text(complitedStatement, 3, [aStudent.phone UTF8String],-1,SQLITE_TRANSIENT);
        }
        //run the query
        if(sqlite3_step(complitedStatement)!=SQLITE_DONE){
            NSLog(@"Error %s", sqlite3_errmsg(database));
            returnCode = NO;
        }
        else{
            NSLog(@"Inserted into row id: %lld", sqlite3_last_insert_rowid(database));
        }
        //cleanup
        sqlite3_finalize(complitedStatement);
    }
    //close database
    sqlite3_close(database);
    
    return returnCode;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addRecord:(UIButton *)sender {
    StudentInfo *person = [[StudentInfo alloc]initWithData:_txtName.text andAddress:_txtAddress.text andPhone:_txtPhone.text];
    
    BOOL retCode = [self insertIntoDatabase:person];
    if(retCode == NO){
        NSLog(@"Failed to add a record");
        _lblStatus.text = @"Failed to add a record";
    }
    else
    {
        NSLog(@"Added a record successfully");
        _lblStatus.text = @"Added a record successfully";
    }
    
}

-(void)findRecordInDatabase{
    
    sqlite3 *database;
    //1. open the db
    if(sqlite3_open([_databasePath UTF8String],&database)== SQLITE_OK){
        
        //2. create a query
        NSString *selectSQL = [NSString stringWithFormat:@"select address, phone from students where name = '%@'",_txtName.text];
        char *sqlStatement = (char *)[selectSQL UTF8String];
        sqlite3_stmt *compiledStatement;
        
        if (sqlite3_prepare_v2(database, sqlStatement,-1,&compiledStatement,NULL)== SQLITE_OK){
            if (sqlite3_step(compiledStatement)== SQLITE_ROW) {
                //char *n = (char *)sqlite3_column_text(compiledStatement, 1);
                char *a = (char *)sqlite3_column_text(compiledStatement, 0);
                char *p = (char *)sqlite3_column_text(compiledStatement, 1);
                
                //convert chart to string
                //NSString* name = [NSString stringWithUTF8String:n];
                NSString* address = [NSString stringWithUTF8String:a];
                NSString* phone = [NSString stringWithUTF8String:p];
                
                //update labels
                _txtAddress.text = address;
                _txtPhone.text = phone;
                _lblStatus.text = @"Match found";
                
            }
            else
            {
                _lblStatus.text = @"Match Not found";
            }
        }
        //free the allocated memory
        sqlite3_finalize(compiledStatement);
    }
    
    //close the DB connection
    sqlite3_close(database);
}

- (IBAction)findRecord:(UIButton *)sender {
    [self findRecordInDatabase];
}

- (IBAction)deleteRecord:(UIButton *)sender {
}



@end
