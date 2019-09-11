# turing
Auto deploy web apps
The whole process should be automated. It should run by a single command.
One physical hosting should be able to host multi web applications (containers).
Given 10 Github web app repositories, you need to host all of them in 1 hosting, and provide separate URL for each app so public users can access.
Build a monitoring tool to monitor the health of containers and the hosting.
It should let us know how much CPU, RAM… each entity consumes.


To solve the tasks, I decided to use VM of the simple and cheap VDS provider and open source software in order to reduce ownership customer’s costs. I don’t use VM and API of the AWS, Azure, Heroke and etc., to have opportunity to deploy web app to any VM or dedicated server using my script Deploy.sh.
I use OS Ubuntu 18.04, Docker containers and npm. To prepare host, I create user, add him to docker group and edit visudo (add line ‘username’ ALL=(ALL) NOPASSWD:ALL).
The Deploy.sh is a bash script. Usually, it runs in the user home directory. The home directory should has template files – Dockerfile, .dockeringnore and ngingx.conf.
In order to provide access to any web app via one public IP and common standard port 80, I use reverse-proxy, native docker’s container. Each web app should have unique URL. Script will ask you to input them. For test, I use my domen ilmar.site and corresponding URLs for web apps - react.ilmar.site, vue.ilmar.site and angular.ilmar.site.
You can try this URLs, they are working.

Briefly script process
-	copy web app from github repo to the personal folder ~/projects/app_name;
-	test and build app;
-	create config files and docker’s image
-	stop the same containers, if it is running, and run new one
-	check revers-proxy process, if it is not running, start it
-	process start again, for next web app.

Errors occur during web app compilation that are not critical, but I’d like to pay attention of the web app developers.

Monitoring
There are no details about GUI, history of the monitoring parameters and etc, so I choose open source tools for monitoring.
There is native docker utility for monitoring – docker stat. It allows us to monitor CPU, memory and net usage of the containers. There is htop linux utility, it allows us to monitor CPU, memory of the host. It’s local and CLI application, but does not require any development costs.
I add one more dockers monitor utility – Cadvisor. This is open source project which has web interface and GUI. You can look at browser using URL cadvisor.ilmar.site:8080
