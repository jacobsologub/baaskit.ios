baaskit.ios
============
Backend as a Service Kit iOS Client Library
Usage
-------------

Import the library:

    #import <BaaSKit/BaaSKit.h>

Setup the library:

    [BaaSKit setAppId: @"your-app-id" appClientKey: @"your-app-client-key"];
    [BaaSKit setUrl: [NSURL URLWithString: @"http://www.yourbaaskitserver.com"]];

Create an object:
    
    [BaaSKit insertObject: @"example"
                   object: @{ @"foo" : @"hello", @"bar" : @"world" }
                    block: ^(NSError* error, NSInteger statusCode, NSString* objectId) {  
                        if (!error && statusCode == 201)
                        {
                            // Do something interesting.
                        }
                    }];

Get object(s):

    [BaaSKit getObjects: @"example"
                  query: @{ @"bar" : @"world" }
                   sort: nil
                  block: ^(NSError* error, NSInteger statusCode, NSArray* objects) {
                      if (!error && statusCode == 200 && objects.count > 0)
                      {
                          NSDictionary* obj = [objects objectAtIndex: 0];
                          NSString* helloString = [obj objectForKey: @"foo"];
                      }
                  }];

Update object(s):
    
    // (Update single object with id.)
    [BaaSKit updateObject: @"example"
                 objectId: @"50a32ff707056ebfe92f28f1"
                   object: @{ @"$set" : @{ @"foo" : @"goodbye" } }
                    block: ^(NSError* error, NSInteger statusCode) {
                        if (!error && statusCode == 200)
                        {
                            NSLog (@"Success!");
                        }
                    }];
    
    // (Update multiple objects matching a query.)
    [BaaSKit updateObjects: @"example"
                     query: @{ @"bar" : @"world" }
                    object: @{ @"$set" : @{ @"foo" : @"goodbye" }}
                    upsert: NO
                     multi: YES
                     block: ^(NSError* error, NSInteger statusCode) {
                         if (!error && statusCode == 200)
                         {
                             NSLog (@"Success!");
                         }
                     }];

# License

This library is released under the [The MIT License (MIT)](https://github.com/jacobsologub/baaskit.ios/blob/master/LICENSE).
    
