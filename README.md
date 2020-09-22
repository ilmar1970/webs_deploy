# webs_deploy
Auto deploy web apps
The whole process is automated and run by a single command.
One physical hosting is able to host multi web applications (containers).
I use VM of the simple and cheap VDS provider (for example neoserver.site) and open source software in order to reduce ownership customer’s costs.
I use OS Ubuntu 18.04, Docker containers and npm. To prepare host, I create user, add him to docker group and edit visudo (add line ‘username’ ALL=(ALL) NOPASSWD:ALL).
The Deploy.sh is a bash script. Usually, it runs in the user home directory. The home directory should has template files – Dockerfile, .dockeringnore and ngingx.conf.
In order to provide access to any web app via one public IP and common standard port 80, I use reverse-proxy, native docker’s container. Each web app should have unique URL. Script will ask you to input them.

Briefly script process
-	copy web app from github repo to the personal folder ~/projects/app_name;
-	test and build app;
-	create config files and docker’s image
-	stop the same containers, if it is running, and run new one
-	check revers-proxy process, if it is not running, start it
-	process start again, for next web app.

Monitoring
There are no details about GUI, history of the monitoring parameters and etc, so I choose open source tools for monitoring.
There is native docker utility for monitoring – docker stat. It allows us to monitor CPU, memory and net usage of the containers. There is htop linux utility, it allows us to monitor CPU, memory of the host. It’s local and CLI application, but does not require any development costs.
I add one more dockers monitor utility – Cadvisor. This is open source project which has web interface and GUI. You can look at browser using URL cadvisor.domen.xyz:8080
