#!/bin/bash

#~/ is default directory for projects
homepath=$HOME

# An error exit function
error_exit()
{
	echo "$1" 1>&2
	exit 1
}

echo "This script help you to build, test, and deploy React, Vue or Angular web apps."
echo "We'll use github repos and docker containers to do it. You can deploy multy apps"
echo "on this host. All apps have the same IP. You need different URL for each project."

#Create directory for projects
if [ ! -d $homepath"/projects" ]; then mkdir -p $homepath/projects; fi

while true;
do
    read -r -p "Would you like to add new project. (Yes or no?) " response
    if [[ ! $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        echo "Thank you"
        exit 0
    fi

cd $homepath/projects

#Show projects, if any
ls -d */ 1>/dev/null 2>&1
if [ $? -ne 2 ]; then
	echo "You projects:"
	for i in $(ls -d */); do echo ${i}; done
fi

#Add new projects
read -p "Enter github url (https://github.com/your/app): "  giturl

#Get app, after last /
gitname=${giturl##*/}
if [ ! -d "$gitname" ]; then
	git clone $giturl || error_exit "Cannot clone $giturl!  Aborting."
#else git pull origin master
fi
cd $gitname  || error_exit "Cannot find project $gitname!  Aborting."

#Get public IP and URL for project
myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
echo "Public IP of this host is ${myip}"
echo "Edit zone of your domen. Add host IP and project URL"
proj_url=''
while [[ $proj_url == '' ]] # While string is different or empty...
do
    read -p "Enter project URL (yourproject.domen.site): "  proj_url
done

#Build project. For angular project probably need add node-sass
sudo yarn install && sudo yarn build || sudo yarn add node-sass fibers -D && sudo yarn build || error_exit "Cannot find $homepath/projects/nginx.conf!  Aborting."

cp -u $homepath/nginx.conf ./ || error_exit "Cannot find $homepath/projects/nginx.conf!  Aborting."
cp -u $homepath/.dockerignore ./ || error_exit "Cannot find .dockerignore!  Aborting."
cp -u $homepath/Dockerfile ./ || error_exit "Cannot find Dockerfile!  Aborting."

#Customize Dockerfile for project
sed -i "s/GITNAME/$gitname/g" Dockerfile
if [ -d "dist" ]; then
	index_path=/$gitname/$(dirname $(find dist -name index.html))
        sed -i "s|HTML|$index_path|g" Dockerfile
elif [ -d "build" ]; then
	index_path=/$gitname/$(dirname $(find build -name index.html))
        sed -i "s|HTML|$index_path|g" Dockerfile
fi

#Convert var to lowercase
cont_name=${gitname,,}

#Create container image, before stop and remove it if any.
docker stop $cont_name >/dev/null 2>&1
docker rm $cont_name >/dev/null 2>&1
docker build -t $cont_name . || error_exit "Cannot can't build container $cont_name!  Aborting."

#Run container
docker run -d --name $cont_name -e VIRTUAL_HOST=$proj_url $cont_name

# Check if proxy is running, if not then start
docker container inspect nginx-proxy > /dev/null 2>&1 || docker run -d -p 80:80 --name nginx-proxy -v /var/run/docker.sock:/tmp/docker.sock jwilder/nginx-proxy || error_exit "Can't run proxy!  Aborting."

# Show running containers
docker ps -a

done
