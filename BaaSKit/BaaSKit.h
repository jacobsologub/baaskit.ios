/*
  ==============================================================================
 
  Copyright (C) 2013 Jacob Sologub
 
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

//==============================================================================
/**	BaaSKit completion block typedefs. */
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
/**	Inserts a new object into a specified collection and executes a block when 
    the request completes or fails. If the collection with the specified name 
    does not exist, one will be created.
 
    @param collectionName   the collection to use.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) insertObject: (NSString*) collectionName
               object: (NSDictionary*) object
                block: (BaaSKitInsertObjectBlock) block;

//==============================================================================
/**	Gets an object in a collection with a specified object id and executes a 
    block when the request completes or fails.
 
    @param collectionName   the collection to use.
    @param objectId         the object id to use.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) getObject: (NSString*) collectionName
          objectId: (NSString*) objectId
             block: (BaaSKitGetObjectBlock) block;

/**	Gets objects in a collection matching the specified query and executes a 
    block when the request completes or fails.
 
    @param collectionName   the collection to use.
    @param query            the query to use.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
              block: (BaaSKitGetObjectsBlock) block;

/**	Gets objects in a collection matching the specified query and sort and 
    executes a block when the request completes or fails.
 
    @param collectionName   the collection to use.
    @param query            the query object to use.
    @param sort             the sort object to use.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
               sort: (NSDictionary*) sort
              block: (BaaSKitGetObjectsBlock) block;

/**	Gets objects in a collection matching the specified query, sort and limit 
    and executes a block when the request completes or fails.
 
    @param collectionName   the collection to use.
    @param query            the query object to use.
    @param sort             the sort object to use.
    @param limit            the maximum number of results to return.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
               sort: (NSDictionary*) sort
              limit: (BOOL) limit
              block: (BaaSKitGetObjectsBlock) block;

/**	Gets objects in a collection matching the specified query, sort limit and 
    skip and executes a block when the request completes or fails.
 
    @param collectionName   the collection to use.
    @param query            the query object to use.
    @param sort             the sort object to use.
    @param limit            the maximum number of results to return.
    @param skip             the number of results to skip.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) getObjects: (NSString*) collectionName
              query: (NSDictionary*) query
               sort: (NSDictionary*) sort
              limit: (BOOL) limit
               skip: (BOOL) skip
              block: (BaaSKitGetObjectsBlock) block;

/**	Gets the number of objects in a collection matching a query and executes a 
    block when the request completes or fails.
 
    @param collectionName   the collection to use.
    @param query            the query object to use.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) getObjectCount: (NSString*) collectionName
                  query: (NSDictionary*) query
                  block: (BaaSKitGetObjectCountBlock) block;


//==============================================================================
/**	Updates an object in a collection with a specified object id and executes a 
    block when the request completes or fails.
 
    @param collectionName   the collection name.
    @param objectId         the object id.
    @param object           the update object.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) updateObject: (NSString*) collectionName
             objectId: (NSString*) objectId
               object: (NSDictionary*) object
                block: (BaaSKitUpdateObjectBlock) block;


/**	Updates objects in a collection matching a query and executes a block when
    the request completes or fails.
 
    @param collectionName   the collection name.
    @param query            the query object.
    @param object           the update object.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) updateObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                object: (NSDictionary*) object
                 block: (BaaSKitUpdateObjectsBlock) block;

/**	Updates objects in a collection matching a query and executes a block when
    the request completes or fails.
 
    @param collectionName   the collection name.
    @param query            the query object.
    @param object           the update object.
    @param upsert           Whether or to update an object if present, or insert
                            a new object.
 	@param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) updateObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                object: (NSDictionary*) object
                upsert: (BOOL) upsert
                 block: (BaaSKitUpdateObjectsBlock) block;

/**	Updates objects in a collection matching a query and executes a block when
    the request completes or fails.
 
    @param collectionName   the collection name.
    @param query            the query object.
    @param object           the update object.
    @param upsert           Whether or to update an object if present, or insert
                            a new object.
    @param multi            Whether or to modify all matched objects, this is 
                            false by default.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) updateObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                object: (NSDictionary*) object
                upsert: (BOOL) upsert
                 multi: (BOOL) multi
                 block: (BaaSKitUpdateObjectsBlock) block;


//==============================================================================
/**	Deletes an object in a collection with a specified object id and executes a 
    block when the request completes or fails.
 
    @param objectId         the object id.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) deleteObject: (NSString*) collectionName
             objectId: (NSString*) objectId
                block: (BaaSKitDeleteObjectBlock) block;

/**	Deletes objects in a collection matching a query and executes a block when 
    the request completes or fails.
 
    @param query            the query object.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) deleteObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                 block: (BaaSKitDeleteObjectsBlock) block;

/**	Deletes objects in a collection matching a query and executes a block when 
    the request completes or fails.
 
    @param query            the query object.
    @param multi            Whether or to modify all matched objects, this is
                            false by default.
    @param block            the block that will be executed when the request 
                            completes or fails.
*/
+ (void) deleteObjects: (NSString*) collectionName
                 query: (NSDictionary*) query
                 multi: (BOOL) multi
                 block: (BaaSKitDeleteObjectsBlock) block;
@end