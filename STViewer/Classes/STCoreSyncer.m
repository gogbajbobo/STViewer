//
//  STCoreSyncer.m
//  STViewer
//
//  Created by Maxim Grigoriev on 9/30/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STCoreSyncer.h"
#import "STViewerCore.h"

@interface STCoreSyncer() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURL *connectionUrl;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic) BOOL isSyncing;
@property (nonatomic, strong) NSString *mode;

@end

@implementation STCoreSyncer


- (NSMutableURLRequest *)requestWithURLString:(NSString *)url andParameters:(NSString *)parameters {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    
//    NSLog(@"request %@", request);
//    NSLog(@"request.URL %@", request.URL);

    return request;
    
}

- (void)getAccessTokenWithRefreshToken:(NSString *)refreshToken clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret {
    
    self.isSyncing = YES;
    self.mode = @"getAccessToken";

    NSString *parameters = [NSString stringWithFormat:@"refresh_token=%@&client_id=%@&client_secret=%@", refreshToken, clientId, clientSecret];
    NSURLRequest *request = [self requestWithURLString:OAUTH_ACCESS_TOKEN_URL andParameters:parameters];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (!connection) {
//            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no connection" type:@"error"];
            self.isSyncing = NO;
        } else {
//            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer send data" type:@""];
        }
    
}

- (void)getRolesForAccessToken:(NSString *)accessToken {
    
    self.isSyncing = YES;
    self.mode = @"getRoles";

    NSString *parameters = [NSString stringWithFormat:@"access_token=%@", accessToken];
    NSURLRequest *request = [self requestWithURLString:OAUTH_ROLES_URL andParameters:parameters];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no connection" type:@"error"];
        self.isSyncing = NO;
    } else {
        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer send data" type:@""];
    }

}

- (void)getEntityPropertiesPage:(int)pageNumber {

    self.isSyncing = YES;
    self.mode = @"getEntities";

    NSString *parameters = [NSString stringWithFormat:@"page-size:=%d&page-number:=%d", PAGESIZE, pageNumber];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", REST_URL, @"ch.entityproperty"];
    NSMutableURLRequest *request = [self requestWithURLString:urlString andParameters:parameters];

    [request setValue:[[STViewerCore sharedViewerCore] accessToken] forHTTPHeaderField:@"Authorization"];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
//        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no connection" type:@"error"];
        self.isSyncing = NO;
    } else {
//        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer send data" type:@""];
    }
    
}

- (void)getEntityRolesPage:(int)pageNumber {
    
    self.isSyncing = YES;
    self.mode = @"getEntityRoles";
    
    NSString *parameters = [NSString stringWithFormat:@"page-size:=%d&page-number:=%d", PAGESIZE, pageNumber];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", REST_URL, @"ch.entityrole"];
    NSMutableURLRequest *request = [self requestWithURLString:urlString andParameters:parameters];
        
    [request setValue:[[STViewerCore sharedViewerCore] accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        //        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no connection" type:@"error"];
        self.isSyncing = NO;
    } else {
        //        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer send data" type:@""];
    }

}

- (void)getItemListForEntityName:(NSString *)entityName page:(int)pageNumber {
    
    self.isSyncing = YES;
    self.mode = @"getItemList";
    
    NSString *parameters = [NSString stringWithFormat:@"page-size:=%d&page-number:=%d", PAGESIZE, pageNumber];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@", REST_URL, @"ch.", entityName];
    NSMutableURLRequest *request = [self requestWithURLString:urlString andParameters:parameters];
    
    [request setValue:[[STViewerCore sharedViewerCore] accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        //        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no connection" type:@"error"];
        self.isSyncing = NO;
    } else {
        //        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer send data" type:@""];
    }

}

- (void)getPropertiesForItemWithXid:(NSString *)xid andEntityName:(NSString *)entityName {
    
    self.isSyncing = YES;
    self.mode = @"getPropertiesForItem";
    
    NSString *parameters = [NSString stringWithFormat:@"xid=%@", xid];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@", REST_URL, @"ch.", entityName];
    NSMutableURLRequest *request = [self requestWithURLString:urlString andParameters:parameters];
    
    [request setValue:[[STViewerCore sharedViewerCore] accessToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        //        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no connection" type:@"error"];
        self.isSyncing = NO;
    } else {
        //        //            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer send data" type:@""];
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.isSyncing = NO;
    NSLog(@"connection didFailWithError %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
//    NSLog(@"self.responseData %@", self.responseData);
    
    self.isSyncing = NO;
  
    self.responseParser.mode = self.mode;
    [self.responseParser parseResponse:self.responseData];

}

- (STResponseParser *)responseParser {
    
    if (!_responseParser) {
        _responseParser = [[STResponseParser alloc] init];
    }
    return _responseParser;
    
}

@end
