//
// DevLibDelegate.m
// Unbox
//
// Created by Árpád Goretity on 07/11/2011
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "DevLibDelegate.h"
#import "rocketbootstrap.h"

@implementation DevLibDelegate

- (id)init
{
	if ((self = [super init])) {
		center = [CPDistributedMessagingCenter centerNamed:@"com.imokhles.ifilevelox"];
		rocketbootstrap_distributedmessagingcenter_apply(center);
		[center runServerOnCurrentThread];

		[center registerForMessageName:@"com.imokhles.ifilevelox.move" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];
		[center registerForMessageName:@"com.imokhles.ifilevelox.copy" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];
		[center registerForMessageName:@"com.imokhles.ifilevelox.symlink" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];
		[center registerForMessageName:@"com.imokhles.ifilevelox.delete" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];
		[center registerForMessageName:@"com.imokhles.ifilevelox.attributes" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];
		[center registerForMessageName:@"com.imokhles.ifilevelox.dircontents" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];
		[center registerForMessageName:@"com.imokhles.ifilevelox.chmod" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];
		[center registerForMessageName:@"com.imokhles.ifilevelox.exists" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];
		[center registerForMessageName:@"com.imokhles.ifilevelox.isdir" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];
		[center registerForMessageName:@"com.imokhles.ifilevelox.mkdir" target:self selector:@selector(DevLib_handleMessageNamed:DevLib_userInfo:)];

		fileManager = [[NSFileManager alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[fileManager release];
	[super dealloc];
}

- (NSDictionary *)DevLib_handleMessageNamed:(NSString *)name DevLib_userInfo:(NSDictionary *)info
{
	NSString *sourceFile = [info objectForKey:@"DevLibSourceFile"];
	NSString *targetFile = [info objectForKey:@"DevLibTargetFile"];
	NSNumber *modeNumber = [info objectForKey:@"DevLibFileMode"];
	const char *source = [sourceFile UTF8String];
	const char *target = [targetFile UTF8String];
	mode_t mode = [modeNumber intValue];
	NSMutableDictionary *result = [NSMutableDictionary dictionary];

	if ([name isEqualToString:@"com.imokhles.ifilevelox.move"]) {
		[fileManager moveItemAtPath:sourceFile toPath:targetFile error:NULL];
	} else if ([name isEqualToString:@"com.imokhles.ifilevelox.copy"]) {
		[fileManager copyItemAtPath:sourceFile toPath:targetFile error:NULL];
	} else if ([name isEqualToString:@"com.imokhles.ifilevelox.symlink"]) {
		symlink(source, target);
	} else if ([name isEqualToString:@"com.imokhles.ifilevelox.delete"]) {
		[fileManager removeItemAtPath:targetFile error:NULL];
	} else if ([name isEqualToString:@"com.imokhles.ifilevelox.attributes"]) {
		[result setDictionary:[fileManager attributesOfItemAtPath:targetFile error:NULL]];
	} else if ([name isEqualToString:@"com.imokhles.ifilevelox.dircontents"]) {
		NSArray *contents = [fileManager contentsOfDirectoryAtPath:targetFile error:NULL];
		if (contents) {
			[result setObject:contents forKey:@"DevLibDirContents"];
		}
	} else if ([name isEqualToString:@"com.imokhles.ifilevelox.chmod"]) {
		chmod(target, mode);
	} else if ([name isEqualToString:@"com.imokhles.ifilevelox.exists"]) {
		BOOL exists = access(target, F_OK);
		NSNumber *num = [[NSNumber alloc] initWithBool:exists];
		[result setObject:num forKey:@"DevLibFileExists"];
		[num release];
	} else if ([name isEqualToString:@"com.imokhles.ifilevelox.isdir"]) {
		struct stat buf;
		stat(target, &buf);
		BOOL isDir = S_ISDIR(buf.st_mode);
		NSNumber *num = [[NSNumber alloc] initWithBool:isDir];
		[result setObject:num forKey:@"DevLibIsDirectory"];
		[num release];
	} else if ([name isEqualToString:@"com.imokhles.ifilevelox.mkdir"]) {
		[fileManager createDirectoryAtPath:targetFile withIntermediateDirectories:YES attributes:nil error:NULL];
	}

	return result;
}

- (void)DevLib_dummy {
	// Keep the timer alive ;)
	NSLog(@"DevLibFB Keeping server alive");
}

@end
