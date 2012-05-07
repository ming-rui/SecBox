

#define kSBoxExecutableName		"secbox"
#define kSBoxEncryptionKeySize	32	//AES256

typedef enum {
	SBoxAccountTypeWeibo	=	0,
	SBoxAccountTypeWeipan	=	1,
}SBoxAccountType;

typedef enum {
	SBoxSuccess = 0,
	SBoxFail = -1,
}SBoxReturnType;


SBoxReturnType SBoxCLIMain(int argc, const char *argv[]);


#pragma mark infomation

SBoxReturnType SBoxShowHelp();
SBoxReturnType SBoxShowStatus();


#pragma mark account&encryption

SBoxReturnType SBoxSetAccountInfo(SBoxAccountType accountType, const char *userName, const char *password);
SBoxReturnType SBoxSetEncryptionInfo(const char *userName, const char *password);


#pragma mark individual file operations

SBoxReturnType SBoxListRemoteDirectory();
SBoxReturnType SBoxChangeRemoteDirectory(const char *path);

SBoxReturnType SBoxPutFile(const char *localSubPath, const char *remoteSubPath);
SBoxReturnType SBoxGetFile(const char *remoteSubPath, const char *localSubPath);


#pragma mark synchronization

SBoxReturnType SBoxSetLocalRoot(const char *path);
SBoxReturnType SBoxSetRemoteRoot(const char *path);

SBoxReturnType SBoxPush();
SBoxReturnType SBoxPull();



