

#include "SecBoxDefines.h"


SBoxRet SBoxCLIMain(int argc, const char *argv[]);

const char * SBoxErrStringWithErrCode(SBoxRet errCode);


#pragma mark infomation

SBoxRet SBoxShowHelp();
SBoxRet SBoxShowStatus();


#pragma mark account&encryption

SBoxRet SBoxSetAccountInfo(SBoxAccountType accountType, const char *userName, const char *password);
SBoxRet SBoxSetEncryptionInfo(const char *userName, const char *password);


#pragma mark individual file operations

SBoxRet SBoxListRemoteDirectory();
SBoxRet SBoxChangeRemoteDirectory(const char *path);

SBoxRet SBoxPutFile(const char *localPath, const char *remotePath);
SBoxRet SBoxGetFile(const char *remotePath, const char *localPath);
SBoxRet SBoxRemove(const char *remotePath);
SBoxRet SBoxMove(const char *remotePath1, const char *remotePath2);


#pragma mark synchronization

SBoxRet SBoxAddMap(const char *localPath, const char *remotePath);
SBoxRet SBoxRemoveMap(const char *localPath);
SBoxRet SBoxSync();


#pragma mark others

char* getString(char *string, int size, char secret, char *prompt);


