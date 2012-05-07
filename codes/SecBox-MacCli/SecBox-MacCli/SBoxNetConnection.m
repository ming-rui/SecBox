
#import "SBoxNetConnection.h"

#import "SBoxDefines.h"

#define kDefaultDataSize	256

@implementation SBoxNetConnection

//@synthesize receivedResponse=_response;
@synthesize urlString=_urlString;

- (void) delayedConnectionFailedWhileIniting {
	[_delegate connectionFailed:self];
	
	[self release];		//self release
}

- (id) initWithURLString:(NSString*)urlString delegate:(id<SBoxNetConnectionDelegate>)delegate {
	if(self=[super init]){
		DLog(@"[NetConnection] initWithURLString:%@",urlString);
		_delegate = delegate;
		if(urlString==nil){
			DAssert(NO,@"");
			[self performSelector:@selector(delayedConnectionFailedWhileIniting) withObject:nil afterDelay:0.0];
			return self;
		}
		_urlString = [urlString retain];
		_dataSize = kDefaultDataSize;
		NSURL *url = [NSURL URLWithString:_urlString];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		[request setValue:@"close" forHTTPHeaderField:@"Connection"];
		//[request setValue:[sys userAgentString] forHTTPHeaderField:@"User-Agent"];
		_connectionPtr = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
		[_connectionPtr scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		[_connectionPtr start];
		[_connectionPtr release];
		if(_connectionPtr==nil){
			DLog(@"[NetConnection] connection==nil");
			[self performSelector:@selector(delayedConnectionFailedWhileIniting) withObject:nil afterDelay:0.0];
			return self;
		}
	}
	
	return [self retain];	//self retain
}

- (id) initWithRequest:(NSMutableURLRequest*)request delegate:(id<SBoxNetConnectionDelegate>)delegate {
	if(self=[super init]){
		DLog(@"[NetConnection] initWithRequest:%@",request);
		_delegate = delegate;
		if(request==nil){
			DAssert(NO,@"");
			[self performSelector:@selector(delayedConnectionFailedWhileIniting) withObject:nil afterDelay:0.0];
			return self;
		}
		_dataSize = kDefaultDataSize;
		[request setValue:@"close" forHTTPHeaderField:@"Connection"];
		_connectionPtr = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
		[_connectionPtr scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		[_connectionPtr start];
		[_connectionPtr release];
		if(_connectionPtr==nil){
			DLog(@"[NetConnection] connection==nil");
			[self performSelector:@selector(delayedConnectionFailedWhileIniting) withObject:nil afterDelay:0.0];
			return self;
		}
	}
	
	return [self retain];	//self retain
}

+ (id) connectionWithURLString:(NSString *)urlString delegate:(id<SBoxNetConnectionDelegate>)delegate {
	return [[[self alloc] initWithURLString:urlString delegate:delegate] autorelease];
}

+ (id) connectionWithRequest:(NSURLRequest*)request delegate:(id<SBoxNetConnectionDelegate>)delegate {
	return [[[self alloc] initWithRequest:request delegate:delegate] autorelease];
}

- (void) dealloc {
	[_urlString release];
	[_data release];
	[_response release];
	
	[super dealloc];
}

- (void) cancel {
	DLog(@"[NetConnection] cancel");
	if(_connectionPtr==nil)
		return;
	
	[_connectionPtr cancel];
	_connectionPtr = nil;
	_delegate = nil;	//for safety
	
	[self release];		//self release
}

- (NSData*) receivedData {
	if(!_dataReady)
		return nil;
	return _data;
}

#pragma mark NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	DLog(@"[NetConnection] connectionDidReceiveResponse:%@",response);
	//DAssert(_response==nil,@"response!=nil");
	_response = [response retain];
	DAssert(_connectionPtr!=nil,@"_connectionPtr==nil");
	long long length = [response expectedContentLength];
	if(length>0&&length<NSUIntegerMax){
		_dataSize = (NSUInteger)length;
	}else{
		_dataSize = kDefaultDataSize;
	}
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	//DLog(@"[NetConnection] connection:didReceiveData:");
	DAssert(_connectionPtr!=nil,@"_connectionPtr==nil");
	if(_data==nil){
		_data = [[NSMutableData alloc] initWithCapacity:_dataSize];
		if(_data==nil){
			[_connectionPtr cancel];
			[self connection:connection didFailWithError:nil];
			return;		//bugfix!
		}
	}
	[_data appendData:data];
	if([_delegate respondsToSelector:@selector(connection:receivedOfPercentage:)]){
		long long length = [_response expectedContentLength];
		if(length!=NSURLResponseUnknownLength)
			[_delegate connection:self receivedOfPercentage:(float)[_data length]/(unsigned)length];
	}
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DLog(@"[NetConnection] connection:didFailWithError:%@",error);
	DAssert(_connectionPtr!=nil,@"_connectionPtr==nil");
	_connectionPtr = nil;
	[_delegate connectionFailed:self];
	
	[self release];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
	DLog(@"[NetConnection] connectionDidFinishLoading:");
	DAssert(_connectionPtr!=nil,@"_connectionPtr==nil");
	if(_data==nil){
		[self connection:connection didFailWithError:nil];
		return;
	}
	
	_connectionPtr = nil;
	_dataReady = YES;
	[_delegate connectionFinishedLoading:self];
	
	[self release];
}

@end
