//
// DevLibClient.m
// Unbox
//
// Created by Árpád Goretity on 07/11/2011
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import "DevLibClient.h"
#import "rocketbootstrap.h"

@implementation DevLibClient

+ (id)sharedInstance
{
	static id shared = nil;
	if (shared == nil) {
		shared = [[self alloc] init];
	}

	return shared;
}

- (id)init
{
	if ((self = [super init])) {
		center = [CPDistributedMessagingCenter centerNamed:@"com.imokhles.ifilevelox"];
		rocketbootstrap_distributedmessagingcenter_apply(center);
	}

	return self;
}

- (NSString *)DevLib_temporaryFile
{
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
	CFRelease(uuidRef);
	NSString *path = [NSString stringWithFormat:@"/tmp/%@.tmp", uuid];
	CFRelease(uuid);
	return path;
}

- (void)DevLib_moveFile:(NSString *)file1 DevLib_toFile:(NSString *)file2
{
	if (file1 == nil || file2 == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file1 forKey:@"DevLibSourceFile"];
	[info setObject:file2 forKey:@"DevLibTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.move" userInfo:info];
	[info release];
}

- (void)DevLib_copyFile:(NSString *)file1 DevLib_toFile:(NSString *)file2
{
	if (file1 == nil || file2 == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file1 forKey:@"DevLibSourceFile"];
	[info setObject:file2 forKey:@"DevLibTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.copy" userInfo:info];
	[info release];
}

- (void)DevLib_symlinkFile:(NSString *)file1 DevLib_toFile:(NSString *)file2
{
	if (file1 == nil || file2 == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file1 forKey:@"DevLibSourceFile"];
	[info setObject:file2 forKey:@"DevLibTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.symlink" userInfo:info];
	[info release];
}

- (void)DevLib_deleteFile:(NSString *)file
{
	if (file == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"DevLibTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.delete" userInfo:info];
	[info release];
}

- (NSDictionary *)DevLib_attributesOfFile:(NSString *)file
{
	if (file == nil) {
		return nil;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"DevLibTargetFile"];
	NSDictionary *reply = [center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.attributes" userInfo:info];
	[info release];
	return reply;
}

- (NSArray *)DevLib_contentsOfDirectory:(NSString *)dir
{
	if (dir == nil) {
		return nil;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:dir forKey:@"DevLibTargetFile"];
	NSDictionary *reply = [center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.dircontents" userInfo:info];
	[info release];
	NSArray *result = [reply objectForKey:@"DevLibDirContents"];
	return result;
}

- (void)DevLib_chmodFile:(NSString *)file mode:(mode_t)mode
{
	if (file == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"DevLibTargetFile"];
	NSNumber *modeNumber = [[NSNumber alloc] initWithInt:mode];
	[info setObject:modeNumber forKey:@"DevLibFileMode"];
	[modeNumber release];
	[center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.chmod" userInfo:info];
	[info release];
}

- (BOOL)DevLib_fileExists:(NSString *)file
{
	if (file == nil) {
		return NO;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"DevLibTargetFile"];
	NSDictionary *reply = [center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.exists" userInfo:info];
	[info release];
	BOOL result = [(NSNumber *)[reply objectForKey:@"DevLibFileExists"] boolValue];
	return result;
}

- (BOOL)DevLib_fileIsDirectory:(NSString *)file
{
	if (file == nil) {
		return NO;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:file forKey:@"DevLibTargetFile"];
	NSDictionary *reply = [center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.isdir" userInfo:info];
	[info release];
	BOOL result = [(NSNumber *)[reply objectForKey:@"DevLibIsDirectory"] boolValue];
	return result;
}

- (void)DevLib_createDirectory:(NSString *)dir
{
	if (dir == nil) {
		return;
	}

	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	[info setObject:dir forKey:@"DevLibTargetFile"];
	[center sendMessageAndReceiveReplyName:@"com.imokhles.ifilevelox.mkdir" userInfo:info];
	[info release];
}

@end
