//
//  ViewController.m
//  Macys.assesment
//
//  Created by Krishna on 2/18/16.
//  Copyright © 2016 krishna. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPSessionManager.h"
#import "MBProgressHUD.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSArray *fullformArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchField.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)searchFullText:(id)sender {
    [_searchField resignFirstResponder];
    if(_searchField==nil || [_searchField.text  isEqual: @""]){
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py"];
    NSURL *URL = [NSURL URLWithString:urlString];
    //NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:urlString parameters:@{@"sf": _searchField.text} error:nil];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            //NSLog(@"Error: %@", error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            _fullformArray=nil;
            [_tableView reloadData];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@ ----->%@", response, responseArray[0][@"lfs"]);
            _fullformArray = responseArray[0][@"lfs"];
            [_tableView reloadData];
        }
    }];
    [dataTask resume];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _fullformArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"acronymcell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"acronymcell"];
    }
    cell.textLabel.text = _fullformArray[indexPath.row][@"lf"];
    return cell;
}



-(BOOL)textFieldShouldClear:(UITextField *)textField{
    _fullformArray=nil;
    [_tableView reloadData];
    return YES;
}

@end
