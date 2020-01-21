#!/bin/bash

# Dev: Jose l. Azagra
# Date: 11/12/2019
# Copyright: AzagraMac 2019
VERSION="RC1"
#
# Changelog:
#
# OS Ubuntu 16.04 LTS
#

colorred="\033[31m"
colorpowder_blue="\033[1;36m" #with bold
colorblue="\033[34m"
colornormal="\033[0m"
colorwhite="\033[97m"
colorlightgrey="\033[90m"
coloryellow="\033[33m"
colorgreen="\033[32m"
CONTADOR=0

clear
echo ""
printf "                   ${colorred} ##       ${colorlightgrey} .         \n"
printf "             ${colorred} ## ## ##      ${colorlightgrey} ==         \n"
printf "           ${colorred}## ## ## ##      ${colorlightgrey}===         \n"
printf "       /\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\\\___/ ===       \n"
printf "  ${colorblue}~~~ ${colorlightgrey}{${colorblue}~~ ~~~~ ~~~ ~~~~ ~~ ~ ${colorlightgrey}/  ===- ${colorblue}~~~${colorlightgrey}\n"
printf "       \\\______${colorwhite} o ${colorlightgrey}         __/           \n"
printf "         \\\    \\\        __/            \n"
printf "          \\\____\\\______/               \n"
printf "${colorpowder_blue}                                          \n"
printf "          |          |                    \n"
printf "       __ |  __   __ | _  __   _          \n"
printf "      /  \\\| /  \\\ /   |/  / _\\\ |     \n"
printf "      \\\__/| \\\__/ \\\__ |\\\_ \\\__  | \n"
printf " ${colornormal}                                         \n"
printf "\t\tv. $VERSION\n"

function showhelp()
{
	printf "command: $0\t\t\t\tUser Commands

NAME
       Create the namespace / organization and add the namespace administrator user

DESCRIPTION
       This  manual page documents the GNU version of $0.

OPTIONS
       Show information about the file system on which each FILE resides, or all file systems by default.
       Mandatory arguments to long options are mandatory for short options too.

       -a, --adminUser
              Specifies the administrator user of the DTR 

       -p, --adminPassword
              The credentials of the DTR administrator user

       -n, --namespace
              We define the name of the 'NameSpace / Organization' that we are going to create. Important, each department must have its own namespace 

       -u, --user
              We write a user with permissions 'Owner' of the namespace, if you want to include more, the user can do the namespace administrator, as long as the user is registered in Active Directory of the company, only one user.

       -h --help
              Show the help menu

${colorwhite}USAGE:${colornormal} ${colorpowder_blue}$0${colornormal} ${coloryellow}-a userAdmin -p passUserAdmin -n NameSpace -u userNameSpace${colornormal}
${colorwhite}USAGE from Kubernetes: ssh root@IP_ADDRESS -t -p PORT_TCP "'"createNameSpace.sh -a userAdmin -p passUserAdmin -n NameSpace -u userNameSpace"'"
\t${colorwhite}Example Kubernetes:${colornormal} ssh root@192.168.1.10 -t -p 22 "'"createNameSpace.sh -a userAdmin -p YourPassUserAdmin -n helloworld -u user1"'"

AUTHOR
       Written by Jose l. Azagra, (C) 2019

COPYRIGHT
       Copyright © 2013 Free Software Foundation, Inc.  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
       This is free software: you are free to change and redistribute it.  There is NO WARRANTY, to the extent permitted by law.

GNU coreutils 8.22\t\t\t\t\tNovember 2019\n"
	exit 1
}

showusage() {
        printf "${colorred}Error: faltan paramentros.\n\n${colornormal}"
        printf "Para obtener ayuda escriba: $0 -h\n"
        exit 1
}

if [ $# -eq 0 ]
then
	showusage
fi

## Menu
while [ $# -ne 0 ]
do
	case "$1" in
	-h|--help)
        	showhelp
        	;;
	-a|--adminUser)
		UNAME="$2"
        	shift
        	;;
	-p|--adminPassword)
        	UPASS="$2"
		shift
		;;
	-n|--namespace)
		NAMESPACE="$2"
		shift
		;;
	-u|--user)
		USER_NAMESPACE="$2"
		shift
		;;
	*)
		printf "${colorred}Error: Argumento no valido.\n\n${colornormal}"
		exit 1
		;;
	esac
shift
done

## Comprueba que las variables no esten vacias
if [ -z "$UNAME" ]
then
    printf "${colorred} El usuario administrador no puede estar vacio.\n"
fi

if [ -z "$UPASS" ]
then
    printf "${colorred} No se ha especificado la contraseña de administrador.\n"
fi

if [ -z "$NAMESPACE" ]
then
    printf "${colorred} No se ha especificado el nombre del NameSpace.\n"
fi

if [ -z "$USER_NAMESPACE" ]
then
    printf "${colorred} No se ha indicado el usuario del NameSpace\n"
fi

## Si hay alguna variable vacia, sale del programa
if [ -z "$UNAME" ] || [ -z "$UPASS" ] || [ -z "$NAMESPACE" ] || [ -z "$USER_NAMESPACE" ]
then
	exit 1
fi

## Resumen
sleep 3
printf "${colorblue}>> NameSpace: ${colorgreen}$NAMESPACE\n"
printf "${colorblue}>> User for NameSpace: ${colorgreen}$USER_NAMESPACE\n"
printf "${colornormal}\n"

## Servidor DTR
URL_DOMAIN="IP_DOMAIN_DOCKER_DTR"
URL_SERVER="https://$URL_DOMAIN/api/v0/"
URL_TOKEN="${URL_SERVER}api_tokens?username=$UNAME"
URL_ORGS="https://$URL_DOMAIN/enzi/v0/accounts"
URL_CHECK="$URL_ORGS?filter=orgs&limit=10000&pageSize=10000"
DATE=`date +%H%M_%d%m%Y`
FILE_LOG=/tmp/createNameSpace_DTR.log

## Guardamos el token en la variable
TOKEN=$(curl -u $UNAME:$UPASS -s -H "accept: application/json" -H "Content-Type: application/json" -X POST -d "{ \"tokenLabel\": \"string\"}" $URL_TOKEN | jq -r .token)

if [ $TOKEN != "null" ]
then
	printf "${colorwhite}>> Get token:${colornormal}${colorgreen} OK${colornormal}\n"
	echo "##### New NameSpace:" >> $FILE_LOG
	echo "Date: $DATE" >> $FILE_LOG
	echo "Namespace: $NAMESPACE" >> $FILE_LOG
	echo "User: $USER_NAMESPACE" >> $FILE_LOG
	echo "[INFO] Login OK in DTR" >> $FILE_LOG
else
	printf ">> Get token:${colorred} ERROR${colornormal}\n"
	printf "${colorred}Error de autenticacion en DTR.\n"
	printf "${colorred}El usuario administrador introducido es ${colorgreen}$UNAME${colornormal}${colorred}, y su contraseña ${colorgreen}$UPASS${colornormal}${colorred}.\n"
	printf "${colorred}en caso contrario, revisar usuario y contraseña en directorio activo. podria haber caducado la contraseña.\n"
        echo "##### New NameSpace:" >> $FILE_LOG
	echo "Date: $DATE" >> $FILE_LOG
	echo "Namespace: $NAMESPACE" >> $FILE_LOG
	echo "User: $USER_NAMESPACE" >> $FILE_LOG
	echo "[ERROR] Auth en DTR, check user $UNAME and passwrd $UPASS" >> $FILE_LOG
	printf "\n\n" >> $FILE_LOG
	exit 1
fi


## Comprobamos si la organizacion ya existe, si es asi, mostramos un mensaje y salimos del programa, en caso contrario, continua.
if checkNameSpace=$(curl -u $UNAME:$TOKEN -X GET -H "Content-Type: application/json" $URL_CHECK  2>/dev/null | jq '[.accounts[].name]' | grep $NAMESPACE)
then
	printf ">> Check Namespace:${colorred} ERROR, ${colorwhite}$NAMESPACE${colornormal} ${colorred}already exists.${colornormal}\n"
	echo "[ERROR] Check Namespace $NAMESPACE a already exists." >> $FILE_LOG
	printf "\n" >> $FILE_LOG
	exit 1
else
	printf "${colorwhite}>> Check Namespace:${colornormal}${colorgreen} OK${colornormal}\n"
	echo "[INFO] Check NameSpace $NAMESPACE" >> $FILE_LOG
	echo "$checkNameSpace" >> $FILE_LOG
fi

## Creamos la organizacion
if createNamespace=$(curl -u $UNAME:$TOKEN -X POST $URL_ORGS -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"name\": \"${NAMESPACE}\", \"isOrg\": true, \"membersCount\": 0, \"teamsCount\": 0}" 2>/dev/null);
then
	printf "${colorwhite}>> Create Namespace:${colornormal}${colorgreen} OK${colornormal}\n"
	echo "[INFO] Create NameSpace $NAMESPACE" >> $FILE_LOG
	echo "### Data JSON:" >> $FILE_LOG
	echo "$createNamespace" >> $FILE_LOG
	printf "\n" >> $FILE_LOG
else
	printf ">> Create Namespace:${colorred} ERROR${colornormal}\n"
	echo "[ERROR] create Namespace $NAMESPACE" >> $FILE_LOG
        echo "### Data JSON:" >> $FILE_LOG
        echo "$createNamespace" >> $FILE_LOG
	printf "\n\n" >> $FILE_LOG
	exit 1
fi

## Agregamos el usuario al namespace
if addUsers=$(curl -u $UNAME:$TOKEN -X PUT "${URL_ORGS}/${NAMESPACE}/members/$USER_NAMESPACE" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"name\": \"$USER_NAMESPACE\", \"isOrg\": false, \"isAdmin\": true, \"isImported\": true}" 2>/dev/null);
then
	printf "${colorwhite}>> addUser to NameSpace:${colornormal}${colorgreen} OK${colornormal}\n\n"
	echo "[INFO] Add user $USER_NAMESPACE on Namespace $NAMESPACE" >> $FILE_LOG
        echo "### Data JSON:" >> $FILE_LOG
	echo "$addUsers" >> $FILE_LOG
	printf "\n\n" >> $FILE_LOG
else
    	printf ">> addUser to NameSpace:${colorred} ERROR${colornormal}\n"
        echo "[ERROR] Add user $USER_NAMESPACE on Namespace $NAMESPACE" >> $FILE_LOG
        echo "### Data JSON:" >> $FILE_LOG
	echo "$addUsers" >> $FILE_LOG
	printf "\n\n" >> $FILE_LOG
	exit 1
fi
exit 0
