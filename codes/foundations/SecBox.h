

#define kSBoxExecutableName			"secbox"
#define kSBoxEncryptionKeySize		32	//AES256

#define kAccountTypeStringWeibo		"weibo"
#define kAccountTypeStringWeipan	"weipan"

typedef enum {
	SBoxAccountTypeWeibo	=	0,
	SBoxAccountTypeWeipan	=	1,
}SBoxAccountType;
#define SBoxAccountTypeString(type)	((type)?kAccountTypeStringWeipan:kAccountTypeStringWeibo)


typedef enum {
	SBoxSuccess = 0,
	SBoxFail = -1,
}SBoxErrCode;
typedef int SBoxRet;


SBoxRet SBoxCLIMain(int argc, const char *argv[]);


#pragma mark infomation

SBoxRet SBoxShowHelp();
SBoxRet SBoxShowStatus();


#pragma mark account&encryption

SBoxRet SBoxSetAccountInfo(SBoxAccountType accountType, const char *userName, const char *password);
SBoxRet SBoxSetEncryptionInfo(const char *userName, const char *password);


#pragma mark individual file operations

SBoxRet SBoxListRemoteDirectory();
SBoxRet SBoxChangeRemoteDirectory(const char *path);

SBoxRet SBoxPutFile(const char *localSubPath, const char *remoteSubPath);
SBoxRet SBoxGetFile(const char *remoteSubPath, const char *localSubPath);
SBoxRet SBoxRemoveRemoteFile(const char *remoteSubPath);


#pragma mark synchronization

//SBoxRet SBoxSetLocalRoot(const char *path);
//SBoxRet SBoxSetRemoteRoot(const char *path);
//
//SBoxRet SBoxPush();
//SBoxRet SBoxPull();



