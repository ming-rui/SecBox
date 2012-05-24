
#import <Foundation/Foundation.h>


@protocol SBoxNetConnectionDelegate;

@interface SBoxNetConnection : NSObject<NSURLConnectionDelegate> {
	@private
	NSString *_urlString;
	id<SBoxNetConnectionDelegate> _delegate;
	NSURLConnection *_connectionPtr;
	NSMutableData *_data;
	NSUInteger _dataSize;	//only for indications
	NSURLResponse *_response;
	BOOL _dataReady;
}

@property(readonly) NSString *urlString;
//@property(readonly) NSURLResponse *receivedResponse;
@property(readonly) NSData *receivedData;

//autostart
//CAUTION: urlString should be added percent escapes
//CAUTION: delegate won't be retained
//will delay the error reply with delegate methods, never return nil!
+ (id) connectionWithURLString:(NSString*)urlString delegate:(id<SBoxNetConnectionDelegate>)delegate;
+ (id) connectionWithRequest:(NSMutableURLRequest*)request delegate:(id<SBoxNetConnectionDelegate>)delegate;

- (void) cancel;

@end


@protocol SBoxNetConnectionDelegate<NSObject>
@required
- (void) connectionFailed:(SBoxNetConnection*)connection;
- (void) connectionFinishedLoading:(SBoxNetConnection*)connection;
@optional
- (void) connection:(SBoxNetConnection*)connection receivedOfPercentage:(float)percentage;
@end