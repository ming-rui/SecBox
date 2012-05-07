
#include "SecBox.h"

#include "stdio.h"
#include "string.h"
#include "unistd.h"

#define kCmdCStringHelp						"help"
#define kCmdCStringShowStatus				"status"
#define kCmdCStringSetAccount				"setacc"
#define kCmdCStringSetEncryption			"setenc"
#define kCmdCStringListRemoteDirectory		"ls"
#define kCmdCStringChangeRemoteDirectory	"cd"
#define kCmdCStringPutFile					"put"
#define kCmdCStringGetFile					"get"


#define kAccountTypeStringWeibo				"weibo"
#define kAccountTypeStringWeipan			"weipan"

char* getString(char *string, int size, char secret, char *prompt) {
	char *retv = NULL;
	if(secret){
		char *pass = getpass(prompt);
		strlcpy(string, pass, size);
		retv = string;
	}else{
		printf("%s",prompt);
		retv = fgets(string, size, stdin);
		if(retv!=NULL){
			for(int i=0; string[i]!='\0'; i++){
				if(string[i]=='\r'||string[i]=='\n'){
					string[i]=0;
					break;
				}
			}
		}
	}
	return retv;
}

SBoxReturnType invalidInput() {
	printf("invalid input!\n");
	
	return SBoxFail;
}

SBoxReturnType inputAccountType(SBoxAccountType *accountType) {
	char inputString[10];
	char *prompt = "Set Account Type(" kAccountTypeStringWeibo " or " kAccountTypeStringWeipan "):";
	char *retv = getString(inputString, sizeof(inputString), 0, prompt);
	
	if(retv==NULL)
		return SBoxFail;
	
	if(strcmp(inputString, kAccountTypeStringWeibo)==0){
		*accountType = SBoxAccountTypeWeibo;
	}else if(strcmp(inputString, kAccountTypeStringWeipan)==0){
		*accountType = SBoxAccountTypeWeipan;
	}else{
		return invalidInput();
	}
	
	return SBoxSuccess;
}

SBoxReturnType inputAccountUserName(char *userName, int size) {
	char *retv = getString(userName, size, 0, "Set Account User Name:");
	
	if(retv==NULL)
		return SBoxFail;
	
	if(retv[0]=='\0')
		return invalidInput();
	
	return SBoxSuccess;
}

SBoxReturnType inputAccountPassword(char *password, int size) {
	char *retv = getString(password, size, 1, "Set Account Password:");
	
	if(retv==NULL)
		return SBoxFail;
	
	if(retv[0]=='\0')
		return invalidInput();
	
	return SBoxSuccess;
}

SBoxReturnType inputEncryptionUserName(char *userName, int size) {
	char *retv = getString(userName, size, 0, "Set Encryption User Name:");
	
	if(retv==NULL)
		return SBoxFail;
	
	if(retv[0]=='\0')
		return invalidInput();
	
	return SBoxSuccess;
}

SBoxReturnType inputEncryptionPassword(char *password, int size) {
	char *retv = getString(password, size, 1, "Set Encryption Password:");
	
	if(retv==NULL)
		return SBoxFail;
	
	if(retv[0]=='\0')
		return invalidInput();
	
	return SBoxSuccess;
}

SBoxReturnType putFile(const char *localSubPath, const char *remoteSubPath);
SBoxReturnType getFile(const char *remoteSubPath, const char *localSubPath);

SBoxReturnType changeRemoteDirectory(const char *path);
SBoxReturnType listRemoteDirectory();


SBoxReturnType SBoxShowHelp() {
	printf("\nExamples:\n"
		   "\t%s %s : show help \n"
		   "\t%s %s : show status \n"
		   "\t%s %s : set vdisk account \n"
		   "\t%s %s : set encryption\n"
		   "\t%s %s : list current remote directory \n"
		   "\t%s %s <path> : change current remote directory \n"
		   "\t%s %s <local path> <remote path> : put local file(s) to remote\n"
		   "\t%s %s <remote path> <local path> : get remote file(s) to local\n"
		   "\n",
		   kSBoxExecutableName, kCmdCStringHelp,
		   kSBoxExecutableName, kCmdCStringShowStatus,
		   kSBoxExecutableName, kCmdCStringSetAccount, 
		   kSBoxExecutableName, kCmdCStringSetEncryption,
		   kSBoxExecutableName, kCmdCStringListRemoteDirectory,
		   kSBoxExecutableName, kCmdCStringChangeRemoteDirectory,
		   kSBoxExecutableName, kCmdCStringPutFile,
		   kSBoxExecutableName, kCmdCStringGetFile
		   );
	
	return SBoxSuccess;
}

SBoxReturnType invalidArguments() {
	printf("\nWrong Arguments!\n");
	SBoxShowHelp();
	
	return SBoxFail;
}

SBoxReturnType SBoxCLIMain(int argc, const char *argv[]) {
	if(argc<2)
		return invalidArguments();
	
	const char *cmdString = argv[1];
	if(strcmp(cmdString, kCmdCStringShowStatus)==0&&argc==2){
		//show status
		return SBoxShowStatus();
	}else if(strcmp(cmdString, kCmdCStringHelp)==0&&argc==2){
		//show help
		return SBoxShowHelp();
	}else if(strcmp(cmdString, kCmdCStringSetAccount)==0&&argc==2){
		//set account info
		char userName[40];
		char password[40];
		SBoxAccountType accountType;
		
		if(inputAccountType(&accountType)!=SBoxSuccess)
			return SBoxFail;
		if(inputAccountUserName(userName, sizeof(userName))!=SBoxSuccess)
			return SBoxFail;
		if(inputAccountPassword(password, sizeof(password))!=SBoxSuccess)
			return SBoxFail;
		
		SBoxReturnType retv = SBoxSetAccountInfo(accountType, userName, password);
		return retv;
	}else if(strcmp(cmdString, kCmdCStringSetEncryption)==0&&argc==2){
		//set encryption info
		char userName[40];
		char password[40];
		
		if(inputEncryptionUserName(userName, sizeof(userName))!=SBoxSuccess)
			return SBoxFail;
		if(inputEncryptionPassword(password, sizeof(password))!=SBoxSuccess)
			return SBoxFail;
		SBoxReturnType retv = SBoxSetEncryptionInfo(userName, password);
		return retv;
	}else if(strcmp(cmdString, kCmdCStringListRemoteDirectory)==0&&argc==2){
		//list remote directory
		return SBoxListRemoteDirectory();
	}else if(strcmp(cmdString, kCmdCStringChangeRemoteDirectory)==0&&argc==3){
		//change remote directory
		return SBoxChangeRemoteDirectory(argv[2]);
	}else if(strcmp(cmdString, kCmdCStringPutFile)==0&&argc==4){
		//put local file to remote file path
		return SBoxPutFile(argv[2], argv[3]);
	}else if(strcmp(cmdString, kCmdCStringGetFile)==0&&argc==4){
		//get remote file to local file path
		return SBoxGetFile(argv[2], argv[3]);
	}
	
	return invalidArguments();
}