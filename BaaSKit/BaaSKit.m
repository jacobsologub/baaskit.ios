/*
  ==============================================================================
 
  Copyright (C) 2012 Jacob Sologub
 
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
 
  ==============================================================================
*/

#import "BaaSKit.h"
#import "JSONKit.h"

#pragma mark BaaSKitConnection
#pragma mark -

typedef void (^BaaSKitConnectionBlock) (NSError* error, NSHTTPURLResponse* response, NSData* data);

@interface BaaSKitConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

/**	Creates an autoreleased BaaSKitConnection object.
 
    @see NSURLRequest
*/
+ (BaaSKitConnection*) connectionWithRequest: (NSURLRequest*) request;

//==============================================================================
/**	Gets or sets whether or not the connection should allow untrusted SSL
    Certificates.
*/
@property (nonatomic, assign) BOOL allowUntrustedCertificate;

//==============================================================================
/**	Kicks off the internal NSURLConnection object and executes a handler block
    on when the request completes or fails.
*/
- (void) startWithBlock: (BaaSKitConnectionBlock) block;

@end

@interface BaaSKitConnection ()
@property (nonatomic, retain) NSURLConnection* urlConnection;
@property (nonatomic, retain) NSURLResponse* urlResponse;
@property (nonatomic, retain) NSData* responseData;
@property (nonatomic, copy) BaaSKitConnectionBlock completionBlock;
@end

@implementation BaaSKitConnection

@synthesize urlConnection = _urlConnection;
@synthesize urlResponse = _urlResponse;
@synthesize responseData = _responseData;
@synthesize completionBlock = _completionBlock;
@synthesize allowUntrustedCertificate = _allowUntrustedCertificate;

#pragma mark -
#pragma mark Object Lifecycle
//==============================================================================
- (id) initWithRequest: (NSURLRequest*) request
{
    if ((self = [super init]) != nil)
    {
        self.urlConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: NO];
        
        self.urlResponse = nil;
        self.responseData = nil;
        
        self.allowUntrustedCertificate = NO;
    }
    
    return self;
}

+ (BaaSKitConnection*) connectionWithRequest: (NSURLRequest*) request
{
    return [[[BaaSKitConnection alloc] initWithRequest: request] autorelease];
}

- (void) dealloc
{
    self.urlConnection = nil;
    self.urlResponse = nil;
    self.responseData = nil;
    
    Block_release (_completionBlock);
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate
//==============================================================================
- (BOOL) connection: (NSURLConnection*) connection canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace*) protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString: NSURLAuthenticationMethodServerTrust];
}

- (void) connection: (NSURLConnection*) connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge*) challenge
{
    if (self.allowUntrustedCertificate)
    {
        [challenge.sender useCredential: [NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge: challenge];
    }
    else
    {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge: challenge];
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate
//==============================================================================
- (void) connection: (NSURLConnection*) connection didFailWithError: (NSError*) error
{
    self.completionBlock (error, 0, nil);
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate
//==============================================================================
- (void) connection: (NSURLConnection*) connection didReceiveResponse: (NSURLResponse*) response
{
    self.urlResponse = response;
}

- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data
{
    self.responseData = data;
}

- (void) connectionDidFinishLoading: (NSURLConnection*) connection
{
    self.completionBlock (nil, (NSHTTPURLResponse*) self.urlResponse, self.responseData);
}

#pragma mark -
#pragma mark Start
//==============================================================================
- (void) startWithBlock: (BaaSKitConnectionBlock) block
{
    self.completionBlock = block;
    [self.urlConnection start];
}
@end

#pragma mark -
#pragma mark BaaSKit
#pragma mark -

static BaaSKit* instance = nil;

static NSString* const BKHTTP_GET       = @"GET";
static NSString* const BKHTTP_POST      = @"POST";
static NSString* const BKHTTP_PUT       = @"PUT";
static NSString* const BKHTTP_DELETE    = @"DELETE";

@interface BaaSKit ()
@property (nonatomic, copy) NSURL* url;
@property (nonatomic, copy) NSString* appId;
@property (nonatomic, copy) NSString* appClientKey;
@property (nonatomic, assign) BOOL allowUntrustedCertificate;
- (NSMutableURLRequest*) requestWithUrlInternal: (NSURL*) url method: (NSString*) method;
@end

@implementation BaaSKit

@synthesize url = _url;
@synthesize appId = _appId;
@synthesize appClientKey = _appClientKey;
@synthesize allowUntrustedCertificate = _allowUntrustedCertificate;

#pragma mark -
#pragma mark Singleton
//==============================================================================
+ (BaaSKit*) instance
{
    @synchronized (self)
    {
        if (! instance)
        {
            instance = [[BaaSKit alloc] init];
        }
        
        return instance;
    }
}

+ (void) deleteInstance
{
    @synchronized(self)
    {
        if (instance)
        {
            [instance release], instance = nil;
        }
    }
}

#pragma mark -
#pragma mark Settings
//==============================================================================
+ (void) setUrl: (NSURL*) url_
{
    [BaaSKit instance].url = url_;
}

+ (NSURL*) url
{
    return [BaaSKit instance].url;
}

+ (void) setAppId: (NSString*) appId_ appClientKey: (NSString*) appClientKey_
{
    [BaaSKit instance].appId = appId_;
    [BaaSKit instance].appClientKey = appClientKey_;
}

+ (NSString*) appId
{
    return [BaaSKit instance].appId;
}

+ (NSString*) appClientKey
{
    return [BaaSKit instance].appClientKey;
}

+ (void) setAllowUntrustedCertificate: (BOOL) shouldAllowUntrustedCertificate
{
    [BaaSKit instance].allowUntrustedCertificate = shouldAllowUntrustedCertificate;
}

+ (BOOL) allowUntrustedCertificate
{
    return [BaaSKit instance].allowUntrustedCertificate;
}

- (NSMutableURLRequest*) requestWithUrlInternal: (NSURL*) url method: (NSString*) method
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: url];
    [request setValue: [BaaSKit appId] forHTTPHeaderField: @"X-Baaskit-Application-Id"];
    [request setValue: [BaaSKit appClientKey] forHTTPHeaderField: @"X-Baaskit-Application-Client-Key"];
    [request setHTTPMethod: method];
    
    return request;
}

#pragma mark -
#pragma mark Insert
//==============================================================================
+ (void) insertObject: (NSString*) collectionName
               object: (NSDictionary*) object
                block: (BaaSKitInsertObjectBlock) block
{
    NSString* urlString = [NSString stringWithFormat: @"%@/classes/%@", [BaaSKit url].absoluteString, collectionName];
    NSURL* url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    NSMutableURLRequest* request = [[BaaSKit instance] requestWithUrlInternal: url method: BKHTTP_POST];
    [request setHTTPBody: [object JSONData]];
    
    BaaSKitConnection* connection = [BaaSKitConnection connectionWithRequest: request];
    
    [connection setAllowUntrustedCertificate: [BaaSKit allowUntrustedCertificate]];
    [connection startWithBlock:^(NSError* error, NSHTTPURLResponse* response, NSData* data) {
        
        NSString* objectId = nil;
        
        if (error == nil && response.statusCode == 201)
        {
            NSArray* paths = [[response.allHeaderFields objectForKey: @"Location"] componentsSeparatedByString: @"/"];
            objectId = [paths lastObject];
        }
        
        block (error, response.statusCode, objectId);
    }];
}

#pragma mark -
#pragma mark Get
//==============================================================================
+ (void) getObject: (NSString*) collectionName
          objectId: (NSString*) objectId
             block: (BaaSKitGetObjectBlock) block
{
    NSString* urlString = [NSString stringWithFormat: @"%@/classes/%@/%@", [BaaSKit url].absoluteString, collectionName, objectId];
    NSURL* url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    BaaSKitConnection* connection = [BaaSKitConnection connectionWithRequest: [[BaaSKit instance] requestWithUrlInternal: url method: BKHTTP_GET]];
    [connection setAllowUntrustedCertificate: [BaaSKit allowUntrustedCertificate]];
    [connection startWithBlock: ^(NSError* error, NSHTTPURLResponse* response, NSData* data) {
        
        NSDictionary* object = [data objectFromJSONData];
        block (error, response.statusCode, object);
    }];
}

+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
              block: (BaaSKitGetObjectsBlock) block
{
    [self getObjects: collectionName query: query
                sort: nil
               limit: 0
                skip: 0
               block: block];
}

+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
               sort: (NSDictionary*) sort
              block: (BaaSKitGetObjectsBlock) block
{
    [self getObjects: collectionName query: query
                sort: sort
               limit: 0
                skip: 0
               block: block];
}

+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
               sort: (NSDictionary*) sort
              limit: (BOOL) limit
              block: (BaaSKitGetObjectsBlock) block
{
    [self getObjects: collectionName query: query
                sort: nil
               limit: limit
                skip: 0
               block: block];
}

+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
               sort: (NSDictionary*) sort
              limit: (BOOL) limit
               skip: (BOOL) skip
              block: (BaaSKitGetObjectsBlock) block
{
    query = (query != nil) ? query : @{};
    sort = (sort != nil) ? sort : @{};
    NSString* urlString = [NSString stringWithFormat: @"%@/classes/%@?where=%@&sort=%@&limit=%d&skip=%d", [BaaSKit url].absoluteString, collectionName, [query JSONString], [sort JSONString], limit, skip];
    NSURL* url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    BaaSKitConnection* connection = [BaaSKitConnection connectionWithRequest: [[BaaSKit instance] requestWithUrlInternal: url method: BKHTTP_GET]];
    [connection setAllowUntrustedCertificate: [BaaSKit allowUntrustedCertificate]];
    [connection startWithBlock: ^(NSError* error, NSHTTPURLResponse* response, NSData* data) {
        
        NSArray* results = [data objectFromJSONData];
        block (error, response.statusCode, results);
    }];
}

+ (void) getObjectCount: (NSString*) collectionName
                  query: (NSDictionary*) query
                  block: (BaaSKitGetObjectCountBlock) block
{
    query = (query != nil) ? query : @{};
    NSString* urlString = [NSString stringWithFormat: @"%@/classes/%@?where=%@&count", [BaaSKit url].absoluteString, collectionName, [query JSONString]];
    NSURL* url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    BaaSKitConnection* connection = [BaaSKitConnection connectionWithRequest: [[BaaSKit instance] requestWithUrlInternal: url method: BKHTTP_GET]];
    [connection setAllowUntrustedCertificate: [BaaSKit allowUntrustedCertificate]];
    [connection startWithBlock: ^(NSError* error, NSHTTPURLResponse* response, NSData* data) {
        
        NSDictionary* object = [data objectFromJSONData];
        block (error, response.statusCode, [[object objectForKey: @"count"] integerValue]);
    }];
}

#pragma mark -
#pragma mark Update
//==============================================================================
+ (void) updateObject: (NSString*) collectionName
             objectId: (NSString*) objectId
               object: (NSDictionary*) object
                block: (BaaSKitUpdateObjectBlock) block
{
    NSString* urlString = [NSString stringWithFormat: @"%@/classes/%@/%@", [BaaSKit url].absoluteString, collectionName, objectId];
    NSURL* url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    NSMutableURLRequest* request = [[BaaSKit instance] requestWithUrlInternal: url method: BKHTTP_PUT];
    [request setHTTPBody: [object JSONData]];
    
    BaaSKitConnection* connection = [BaaSKitConnection connectionWithRequest: request];
    [connection setAllowUntrustedCertificate: [BaaSKit allowUntrustedCertificate]];
    [connection startWithBlock: ^(NSError* error, NSHTTPURLResponse* response, NSData* data) {
        
        block (error, response.statusCode);
    }];
}

+ (void) updateObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                object: (NSDictionary*) object
                 block: (BaaSKitUpdateObjectsBlock) block
{
    [self updateObjects: collectionName
                 query: query
                object: object
                upsert: NO
                 multi: NO
                 block: block];
}

+ (void) updateObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                object: (NSDictionary*) object
                upsert: (BOOL) upsert
                 block: (BaaSKitUpdateObjectsBlock) block
{
    [self updateObjects: collectionName
                  query: query
                 object: object
                 upsert: upsert
                  multi: NO
                  block: block];
}

+ (void) updateObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                object: (NSDictionary*) object
                upsert: (BOOL) upsert
                 multi: (BOOL) multi
                 block: (BaaSKitUpdateObjectsBlock) block
{
    query = (query != nil) ? query : @{};
    NSString* urlString = [NSString stringWithFormat: @"%@/classes/%@?where=%@&upsert=%d&multi=%d", [BaaSKit url].absoluteString, collectionName, [query JSONString], upsert, multi];
    NSURL* url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    NSMutableURLRequest* request = [[BaaSKit instance] requestWithUrlInternal: url method: BKHTTP_PUT];
    [request setHTTPBody: [object JSONData]];
    
    BaaSKitConnection* connection = [BaaSKitConnection connectionWithRequest: request];
    [connection setAllowUntrustedCertificate: [BaaSKit allowUntrustedCertificate]];
    [connection startWithBlock: ^(NSError* error, NSHTTPURLResponse* response, NSData* data) {
        
        block (error, response.statusCode);
    }];
}

#pragma mark -
#pragma mark Delete
//==============================================================================
+ (void) deleteObject: (NSString*) collectionName
             objectId: (NSString*) objectId
                block: (BaaSKitDeleteObjectBlock) block
{
    NSString* urlString = [NSString stringWithFormat: @"%@/classes/%@/%@", [BaaSKit url].absoluteString, collectionName, objectId];
    NSURL* url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    BaaSKitConnection* connection = [BaaSKitConnection connectionWithRequest: [[BaaSKit instance] requestWithUrlInternal: url method: BKHTTP_DELETE]];
    [connection setAllowUntrustedCertificate: [BaaSKit allowUntrustedCertificate]];
    [connection startWithBlock: ^(NSError* error, NSHTTPURLResponse* response, NSData* data) {
        
        block (error, response.statusCode);
    }];
}

+ (void) deleteObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                 block: (BaaSKitDeleteObjectsBlock) block
{
    [self deleteObjects: collectionName
                  query: query
                  multi: NO
                  block: block];
}

+ (void) deleteObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                 multi: (BOOL) multi
                 block: (BaaSKitDeleteObjectsBlock) block
{
    query = (query != nil) ? query : @{};
    NSString* urlString = [NSString stringWithFormat: @"%@/classes/%@?where=%@&multi=%d", [BaaSKit url].absoluteString, collectionName, [query JSONString], multi];
    NSURL* url = [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    
    BaaSKitConnection* connection = [BaaSKitConnection connectionWithRequest: [[BaaSKit instance] requestWithUrlInternal: url method: BKHTTP_DELETE]];
    [connection setAllowUntrustedCertificate: [BaaSKit allowUntrustedCertificate]];
    [connection startWithBlock: ^(NSError* error, NSHTTPURLResponse* response, NSData* data) {
        
        block (error, response.statusCode);
    }];
}
@end
