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

#import <Foundation/Foundation.h>

@interface BaaSKit : NSObject

typedef void (^BaaSKitInsertObjectBlock) (NSError* error, NSInteger statusCode, NSString* objectId);
typedef void (^BaaSKitGetObjectBlock) (NSError* error, NSInteger statusCode, NSDictionary* object);
typedef void (^BaaSKitGetObjectsBlock) (NSError* error, NSInteger statusCode, NSArray* objects);
typedef void (^BaaSKitGetObjectCountBlock) (NSError* error, NSInteger statusCode, int count);
typedef void (^BaaSKitUpdateObjectBlock) (NSError* error, NSInteger statusCode);
typedef void (^BaaSKitUpdateObjectsBlock) (NSError* error, NSInteger statusCode);
typedef void (^BaaSKitDeleteObjectBlock) (NSError* error,  NSInteger statusCode);
typedef void (^BaaSKitDeleteObjectsBlock) (NSError* error,  NSInteger statusCode);

//==============================================================================
/**	Sets the URL that will be used for any subsequent calls to the BaaSKit 
    server.
 
    @example @"http://yourserver.com/v1"
*/
+ (void) setUrl: (NSURL*) url;


/**	Returns the server URL used for all server calls.
    
    @see setUrl
*/
+ (NSURL*) url;

/**	Sets the application id and application client key that should be used when
    calling the server.
    
    @code
    
    [BaaSKit setAppId: @"your-applicaiton-id"
         appClientKey: @"your-applicaiton-client-key"];
 
    @endcode
*/
+ (void) setAppId: (NSString*) appId appClientKey: (NSString*) appClientKey;

/**	Returns the application id.

    @see setAppId:appClientKey
*/
+ (NSString*) appId;

/**	Returns the application client key.
 
    @see setAppId:appClientKey
*/
+ (NSString*) appClientKey;


/**	Sets whether or not the client should allow untrusted ssl certificates. This
    is useful for testing and is not recommended for production use.
 
    @see allowUntrustedCertificate
*/
+ (void) setAllowUntrustedCertificate: (BOOL) shouldAllowUntrustedCertificate;

/**	Returns a value indicating whether or not the client allows untrusted 
    certificate.
 
    @see setAllowUntrustedCertificate
*/
+ (BOOL) allowUntrustedCertificate;

//==============================================================================
/**	Inserts a new object into a specified collection. 
 
    @param collectionName   The collection to use.
*/
+ (void) insertObject: (NSString*) collectionName
               object: (NSDictionary*) object
                block: (BaaSKitInsertObjectBlock) block;

//==============================================================================
/**	Gets an object in a collection with a specified object id.
    
    @param collectionName   The collection to use.
    @param objectId         The object id to use.
*/
+ (void) getObject: (NSString*) collectionName
          objectId: (NSString*) objectId
             block: (BaaSKitGetObjectBlock) block;

/**	Gets objects in a collection matching the specified query.
 
    @param collectionName   The collection to use.
    @param query            The query to use.
*/
+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
              block: (BaaSKitGetObjectsBlock) block;

/**	Gets objects in a collection matching the specified query and 
    sort.
 
    @param collectionName   The collection to use.
    @param query            The query object to use.
    @param sort             The sort object to use.
*/
+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
               sort: (NSDictionary*) sort
              block: (BaaSKitGetObjectsBlock) block;

/**	Gets objects in a collection matching the specified query, sort 
    and limit.
 
    @param collectionName   The collection to use.
    @param query            The query object to use.
    @param sort             The sort object to use.
    @param limit            The maximum number of results to return.
*/
+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
               sort: (NSDictionary*) sort
              limit: (BOOL) limit
              block: (BaaSKitGetObjectsBlock) block;

/**	Gets objects in a collection matching the specified query, sort
    limit and skip.
 
    @param collectionName   The collection to use.
    @param query            The query object to use.
    @param sort             The sort object to use.
    @param limit            The maximum number of results to return.
    @param skip             The number of results to skip.
*/
+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
               sort: (NSDictionary*) sort
              limit: (BOOL) limit
               skip: (BOOL) skip
              block: (BaaSKitGetObjectsBlock) block;

/**	Gets the number of objects in a collection matching a query.
 
    @param collectionName   The collection to use.
    @param query            The query object to use.
*/
+ (void) getObjectCount: (NSString*) collectionName
                  query: (NSDictionary*) query
                  block: (BaaSKitGetObjectCountBlock) block;


//==============================================================================
/**	Updates an object in a collection with a specified object id.
    
    @param collectionName   The collection name.
    @param objectId         The object id.
    @param object           The update object.
*/
+ (void) updateObject: (NSString*) collectionName
             objectId: (NSString*) objectId
               object: (NSDictionary*) object
                block: (BaaSKitUpdateObjectBlock) block;


/**	Updates objects in a collection matching a query.
 
    @param collectionName   The collection name.
    @param query            The query object.
    @param object           The update object.
*/
+ (void) updateObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                object: (NSDictionary*) object
                 block: (BaaSKitUpdateObjectsBlock) block;

/**	Updates objects in a collection matching a query.
 
    @param collectionName   The collection name.
    @param query            The query object.
    @param object           The update object.
    @param upsert           Whether or to update an object if present, or insert
                            a new object.
*/
+ (void) updateObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                object: (NSDictionary*) object
                upsert: (BOOL) upsert
                 block: (BaaSKitUpdateObjectsBlock) block;

/**	Updates objects in a collection matching a query.
 
    @param collectionName   The collection name.
    @param query            The query object.
    @param object           The update object.
    @param upsert           Whether or to update an object if present, or insert
                            a new object.
    @param multi            Whether or to modify all matched objects, this is 
                            false by default.
*/
+ (void) updateObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                object: (NSDictionary*) object
                upsert: (BOOL) upsert
                 multi: (BOOL) multi
                 block: (BaaSKitUpdateObjectsBlock) block;


//==============================================================================
/**	Deletes an object in a collection with a specified object id.
    
    @param objectId         The object id.
*/
+ (void) deleteObject: (NSString*) collectionName
             objectId: (NSString*) objectId
                block: (BaaSKitDeleteObjectBlock) block;

/**	Deletes objects in a collection matching a query.
 
    @param query            The query object.
*/
+ (void) deleteObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                 block: (BaaSKitDeleteObjectsBlock) block;

/**	Deletes objects in a collection matching a query.
 
    @param query            The query object.
    @param multi            Whether or to modify all matched objects, this is
                            false by default.
*/
+ (void) deleteObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                 multi: (BOOL) multi
                 block: (BaaSKitDeleteObjectsBlock) block;
@end