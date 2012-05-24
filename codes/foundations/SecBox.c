
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
#define kCmdCStringRemove					"rm"
#define kCmdCStringMove						"mv"
#define kCmdCStringAddMap					"addmap"
#define kCmdCStringRemoveMap				"rmmap"
#define kCmdCStringSync						"sync"


#pragma mark input suppliemnts

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
					string[i]='\0';
					break;
				}
			}
		}
	}
	return retv;
}

#pragma mark input account info

SBoxRet inputAccountType(SBoxAccountType *accountType) {
	char inputString[10];
	char *prompt = "Set Account Type(" kAccountTypeStringWeibo " or " kAccountTypeStringWeipan "):";
	char *retv = getString(inputString, sizeof(inputString), 0, prompt);
	
	if(retv==NULL)
		return SBoxRetInvalidInput;
	
	if(strcmp(inputString, kAccountTypeStringWeibo)==0){
		*accountType = SBoxAccountTypeWeibo;
	}else if(strcmp(inputString, kAccountTypeStringWeipan)==0){
		*accountType = SBoxAccountTypeWeipan;
	}else{
		return SBoxRetInvalidInput;
	}
	
	return SBoxSuccess;
}

SBoxRet inputAccountUserName(char *userName, int size) {
	char *retv = getString(userName, size, 0, "Set Account User Name:");
	
	if(retv==NULL||retv[0]=='\0')
		return SBoxRetInvalidInput;

	return SBoxSuccess;
}

SBoxRet inputAccountPassword(char *password, int size) {
	char *retv = getString(password, size, 1, "Set Account Password:");
	
	if(retv==NULL||retv[0]=='\0')
		return SBoxRetInvalidInput;
	
	return SBoxSuccess;
}

SBoxRet inputAccountInfo() {
	char userName[40];
	char password[40];
	SBoxAccountType accountType;
	
	SBoxRet retv = inputAccountType(&accountType);
	if(retv!=SBoxSuccess)
		return retv;
	
	retv = inputAccountUserName(userName, sizeof(userName));
	if(retv!=SBoxSuccess)
		return retv;
	
	retv = inputAccountPassword(password, sizeof(password));
	if(retv!=SBoxSuccess)
		return retv;
	
	retv = SBoxSetAccountInfo(accountType, userName, password);
	
	return retv;
}


#pragma mark input encryption info

SBoxRet inputEncryptionUserName(char *userName, int size) {
	char *retv = getString(userName, size, 0, "Set Encryption User Name:");
	
	if(retv==NULL||retv[0]=='\0')
		return SBoxRetInvalidInput;
	
	return SBoxSuccess;
}

SBoxRet inputEncryptionPassword(char *password, int size) {
	char *retv = getString(password, size, 1, "Set Encryption Password:");
	
	if(retv==NULL||retv[0]=='\0')
		return SBoxRetInvalidInput;
	
	return SBoxSuccess;
}

SBoxRet inputEncryptionInfo() {
	char userName[40];
	char password[40];
	
	SBoxRet retv = inputEncryptionUserName(userName, sizeof(userName));
	if(retv!=SBoxSuccess)
		return retv;
	
	retv = inputEncryptionPassword(password, sizeof(password));
	if(retv!=SBoxSuccess)
		return retv;
	
	retv = SBoxSetEncryptionInfo(userName, password);
	
	return retv;
}


#pragma mark show help

SBoxRet SBoxShowHelp() {
	printf("Examples:\n"
		   "\t%s %s : show help \n"
		   "\t%s %s : show status \n"
		   "\t%s %s : set vdisk account \n"
		   "\t%s %s : set encryption\n"
		   "\t%s %s : list current remote directory \n"
		   "\t%s %s <path> : change current remote directory \n"
		   "\t%s %s <local path> <remote path> : put local file to remote\n"
		   "\t%s %s <remote path> <local path> : get remote file to local\n"
		   "\t%s %s <remote path> : remove remote file\n"
		   "\t%s %s <remote path 1> <remote path 2> : move remote file\n"
		   "\t%s %s <local path> <remote path> : map local file with remote\n"
		   "\t%s %s <local path> : remove map\n"
		   "\t%s %s : sync files based on the map\n",
		   kSBoxExecutableName, kCmdCStringHelp,
		   kSBoxExecutableName, kCmdCStringShowStatus,
		   kSBoxExecutableName, kCmdCStringSetAccount, 
		   kSBoxExecutableName, kCmdCStringSetEncryption,
		   kSBoxExecutableName, kCmdCStringListRemoteDirectory,
		   kSBoxExecutableName, kCmdCStringChangeRemoteDirectory,
		   kSBoxExecutableName, kCmdCStringPutFile,
		   kSBoxExecutableName, kCmdCStringGetFile,
		   kSBoxExecutableName, kCmdCStringRemove,
		   kSBoxExecutableName, kCmdCStringMove,
		   kSBoxExecutableName, kCmdCStringAddMap,
		   kSBoxExecutableName, kCmdCStringRemoveMap,
		   kSBoxExecutableName, kCmdCStringSync
		   );
	
	return SBoxSuccess;
}


#pragma mark CLIMain

SBoxRet invalidArguments() {
	SBoxShowHelp();
	
	return SBoxRetInvalidArgument;
}

SBoxRet SBoxCLIMain(int argc, const char *argv[]) {
	
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
		return inputAccountInfo();
	}else if(strcmp(cmdString, kCmdCStringSetEncryption)==0&&argc==2){
		//set encryption info
		return inputEncryptionInfo();
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
	}else if(strcmp(cmdString, kCmdCStringRemove)==0&&argc==3){
		//remove remote file
		return SBoxRemove(argv[2]);
	}else if(strcmp(cmdString, kCmdCStringMove)==0&&argc==4){
		//move remote file
		return SBoxMove(argv[2], argv[3]);
	}else if(strcmp(cmdString, kCmdCStringAddMap)==0&&argc==4){
		//add map
		return SBoxAddMap(argv[2], argv[3]);
	}else if(strcmp(cmdString, kCmdCStringRemoveMap)==0&&argc==3){
		//remove map
		return SBoxRemoveMap(argv[2]);
	}else if(strcmp(cmdString, kCmdCStringSync)==0&&argc==2){
		//sync
		return SBoxSync();
	}
	
	return invalidArguments();
}