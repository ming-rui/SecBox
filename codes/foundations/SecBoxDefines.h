
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
	SBoxRetInvalidArgument		= -1,
	SBoxRetInvalidInput			= -2,
	SBoxRetLocalFileNotExist	= -3,
	SBoxRetCantCreateLocalFile	= -4,
}SBoxErrCode;
typedef int SBoxRet;
