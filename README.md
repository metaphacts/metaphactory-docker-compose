# metaphactory deployments with docker-compose

**Prerequisites:**

* docker installed (version >= 1.9 , check with `docker --version`)
* docker-compose installed (version >= 1.14, check with `docker-compose --version`)
* outgoing HTTP/HTTPS traffic, allowing to access external docker registries (e.g. docker public or other private/corporate docker registries)

## metaphactory Deployment and Maintenance

**Prerequisites:**

To perform any deployments or updates, you will first need to login to the metaphact's docker registry with your docker hub account, i.e. run `docker login`.
Please request your account to be added via **support@metaphacts.com** if you have not yet done so.

### Initial Deployment
To create a new deployment from scratch chose from these two options:

#### metaphactory Deployment

1. Clone this GIT repository with `git clone https://bitbucket.org/metaphacts/metaphactory-docker-compose.git`
2. Create a copy of the `service-template` folder i.e. `cp -r service-template my-deployment`. The idea is to maintain one subfolder for every deployment.
3. Change into the newly created folder `my-deployment` and choose one option below:
	1. To deploy **metaphactory with Blazegraph** included (recommended for initial tests) run `cp ./database-config/.env_blazegraph .env`.
	2. To deploy **metaphactory standalone** to connect to an external SPARQL endpoint later on run `cp ./database-config/.env_default .env`. If you want to connect to a SPARQL endpoint accessible only via the docker hostmachine, please see the instructions in the section **Accessing docker hostmachine from docker container** below.
	3. To deploy **metaphactory with Stardog** included run `cp ./database-config/.env_stardog .env`. **Please note:** this requires that you own a valid Stardog license file.
4. Open the file `.env` e.g. `vi .env` and perform following changes:
	1. Change the value of the `COMPOSE_PROJECT_NAME` variable to a unique name (default is `my-deployment-1`) i.e. the name will be used to prefix container names as well as `vhost` entry in the nginx proxy (if used).
	2. Please note that the deployment will contain GraphScope (`https://www.metaphacts.com/graphscope`), which runs in its own container and requires additional 2GB of memory. Remove `:./docker-compose.graphscope.yml` from the `COMPOSE_FILE` parameter to deactivate GraphScope.
5. (Only for **metaphactory with Stardog**) Please perform additional steps below to prepare the Stardog configuration:
	1. Add your Stardog license into the `/database-config/stardog-config` folder by replacing the existing file `stardog-license-key.bin`. 
	2. You may want to modify Stardog specific parameters in the `/database-config/stardog-config/docker-compose.stardog.yml` file i.e. changing the default memory settings
	3. You can also modify the `/database-config/stardog-repository-config/myDB.ttl` file, i.e. to use a different Stardog database name or changing the default credentials for the repository connection with stardog. Please note that this also requires modification of the database configuration in `/database-config/stardog-config/database-template.properties`.
	4. Also note that GraphScope has a reference to the database as well, which would need to be updated in `graphscope-config/stardog-config.yml` with the parameter `remoteEndpoint`, in case of changes.
6. Run `docker-compose up -d`. It is **important to run the command in the 'my-deployment' folder (containing the .env file)**, since docker-compose will pick up the `.env` file for parameterization.
7. Please perform additional steps below, in case you chose to deploy **metaphactory with Stardog**:
	1. Run `docker exec -it my-deployment-1-stardog /opt/stardog/bin/stardog-admin db create -c /var/opt/stardog/database-template.properties -n myDB` to create a Stardog database (change the docker container name from `my-deployment-1-stardog` to the correct name). The name of your stardog container was displayed as part of the output of the `docker-compose up -d` command, or you can also run `docker ps -f name=stardog` to look it up again. Also modify the database name from `myDB` to the name you used (e.g. if you modified the `myDB.ttl` file). 
8. Open `http://localhost:10214` and login with user `admin` and password `admin`

**Please note:** For the creation of the stardog database (if chosen above) the `stardog-config/database-template.properties` will be used. This is important, since this property file sets some database configurations (for example, enabling text search/indexing and querying of all named graphs) which are important to make metaphactory seamlessly work with Stardog.

**Troubleshooting**

Please run `docker-compose down` before running `docker-compose up` after failed attempts (for example due to missing license file), especially if you experience errors like `unknown: Are you trying to mount a directory onto a file (or vice-versa)? Check if the specified host path exists and is the expected type`.

**Accessing docker hostmachine from docker container**

* **Linux** If you want to connect to a SPARQL endpoint accessible only on the docker hostmachine, e.g. http://localhost:5828/myDB/query, please identify the IP of your docker0 network using the following command `ip -4 addr show scope global dev docker0 | grep inet | awk '{print $2}' | cut -d "/" -f 1`. In the file `my-deployment/docker-compose.overwrite.yml` uncomment the line `extra_hosts` and the line below and put the IP of your docker0 network behind 'hostmachine:', e.g. - hostmachine:172.17.0.1. Now, the SPARQL endpoint is accessible via http://hostmachine:<port>/<path>, for example http://hostmachine:5820/myDB/query. Use this URL in your repository setup.
* **Mac/Windows** (for development purpose only) The host is accessible via the preconfigured hostname `host.docker.internal` from docker version 18.03 onwards.

## Change users/password of GraphScope
* The `GraphScope service user` can be created or updated using htpasswd (`https://httpd.apache.org/docs/2.4/programs/htpasswd.html`) and is stored in the `users.htpasswd` file in the folder `graphscope-config`
#### For GRAPHSCOPE_CONFIGURATION=default (see in .env file)
* **metaphactory to GraphScope** connection is with the user and password provided in the `proxy.prop` configuration (provided in `graphscope-apps/app-graphscope-default/config`).
* **GraphScope to graphscope-ephedra repository of metaphactory** using the user and password provided in `graphscope-config/default-config.yml` through the parameters `remoteUser` and `remotePassword`. The provided user needs `sparql:graphscope-ephedra:query:*` and `proxy:graphscope` permissions in metaphactory.
#### For GRAPHSCOPE_CONFIGURATION=blazegraph (see in .env file)
* **metaphactory to GraphScope** connection is with the user and password provided in the `proxy.prop` configuration (provided in `graphscope-apps/app-graphscope-blazegraph/config`).
* **GraphScope to Blazegraph** using the user and password provided in `graphscope-config/blazegraph-config.yml` through the parameters `remoteUser: <user-name>` and `remotePassword: <password>`. 
#### For GRAPHSCOPE_CONFIGURATION=stardog (see in .env file)
* **metaphactory to GraphScope** connection is with the user and password provided in the `proxy.prop` configuration (provided in `graphscope-apps/app-graphscope-stardog/config`).
* **GraphScope to Stardog** using the user and password provided in `graphscope-config/stardog-config.yml` through the parameters `remoteUser: <user-name>` and `remotePassword: <password>`, as well as `remoteEndpoint` to specify the Stardog SPARQL endpoint and utilized database name.

## Update of Deployments
The most frequent use-case will be updating the runtime (i.e. software) container, for example, of the metaphactory, GraphScope or blazegraph, but leaving the deployment specific data and configuration assets untouched. 

1. Modify the .env file in the folder of the deployment you want to update and increase/change the docker version tag of the metaphactory, GraphScope or Blazegraph container i.e. `METAPHACTORY_IMAGE`, `GRAPHSCOPE_IMAGE` and/or `BLAZEGRAPH_IMAGE`.
2. Run `docker-compose up -d` will re-create only the containers, that have been changed.

## Deletion of Deployments
Run `docker-compose down` in the folder for deployment you want to purge. Please note, that **all containers and non-external volumes and networks** for the deployment will be removed and deleted. Make sure that you are in the correct folder (where the respective `.env` file for the deployment is located), before executing the down command.

## Optional Setup: NGINX Proxy Container

**Please note:**

* This setup is currently not compatible with Windows hosts

It is recommended to use a proxy container with virtual host mappings to proxy the incoming HTTP traffic to the individual container instances. Reasons are:

* Security
	* Not every container/deployment should expose a port (neither on localhost nor to the outside network). Firewall needs to open only two ports.
	* SSL certificate handling in a single place. Instead of dealing with certificates individually or using self-signed certificates, there will be only one officially signed wildcard certificate. One-time installation, valid for all deployments.
    * Ability to automatically issue certificates with [Let's Encrypt](https://letsencrypt.org/).
	* Easy to .htaccess protect containers/deployments that have no built-in authentication mechanism
* Dealing with hostnames is much easier than dealing with IPs and Ports
	* Changes to the underlying (container) setup/infrastructure can be handled transparently.
* Single place for special HTTP settings i.e. easy to enable CORS, GZIP, HTTP2 or modifying HTTP header for individual or all deployments.
	
**Prerequisites:**

* Wildcard CNAME record for the hostname DNS entry e.g. *.mydocker.example.com
* Inbound rules for Port 80, 443 in firewall
* Wildcard SSL certificate for the DNS entry *.mydocker.example.com placed in `/home/docker/config/nginx/certs`. Obviously, it is not required to use HTTPS. However, while the obvious reason for taking this extra step is security, there is another positive side-effect: Performance i.e. only with HTTPS new HTTP2 features are available, which will greatly speed-up the performance of many client-side applications.

### Setup
1. Create the initial folder structure for nginx config files i.e. so that one can mount the folder when creating the proxy container and place additional config files later if needed: `mkdir -p /home/docker/config/nginx/{certs,htpasswd,vhost.d,conf.d}` and `touch /home/docker/config/nginx/conf.d/proxy.conf`.
2. Copy the content of [nginx.tmpl](https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl) to `/home/docker/config/nginx/nginx.tmpl`
3. Copy SSL certificate to `/home/docker/config/nginx/certs` i.e. the *.key file and *.crt file must be named equivalent to the hostname (e.g. mydocker.example.com.key and mydocker.example.com.crt, if you have a wildcard certificate for *.mydocker.example.com). Set proper permissions to protect the key file (i.e. docker must be able to read it, but no one else). The *.cert file should contain only the certificate body (from `-----BEGIN CERTIFICATE----- ` to `-----END CERTIFICATE----- `) but also all intermediate certificates/root certificate required for the certificate chain. You can simple concatenate these, however, order matters:

		-----BEGIN CERTIFICATE----- 
		(Your Primary SSL certificate: your_domain_name.crt) 
		-----END CERTIFICATE----- 
		-----BEGIN CERTIFICATE----- 
		(Your Intermediate certificate: xCertCA.crt) 
		-----END CERTIFICATE----- 
		-----BEGIN CERTIFICATE----- 
		(Your Root certificate: TrustedRoot.crt) 
		-----END CERTIFICATE----

3. Go into the `cert` folder i.e. `cd /home/docker/config/nginx/certs` and generate [Diffie–Hellman](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange) parameters using `openssl dhparam -dsaparam -out /home/docker/config/nginx/certs/mydocker.example.com.dhparam.pem 4096`. `-dsaparam` [option instructs OpenSSL to produce "DSA-like" DH parameters ](https://wiki.openssl.org/index.php/Manual:Dhparam(1)#OPTIONS) , which is magnitude faster then computing the dhparam 4096 (see explanation [on stackexchange](https://security.stackexchange.com/a/95184))
Go into folder `docker-compose/nginx`
4. Now we are ready to create and start the proxy container. Running `docker-compose up -d` should result in:
		Creating network "nginx_proxy_network" with the default driver
		Creating nginx-proxy ...
		Creating nginx-proxy ... done

5. Verify with `docker ps` that a container `nginx-proxy` is running with two ports exposed: ```80, 443```
6. From now on the `nginx-proxy` will listen to container changes on the docker daemon. As soon as a new docker container instance is started with a environment variable  `-e VIRTUAL_HOST={name}.mydocker.example.com`, nginx will automatically create a vhost entry to proxy incoming HTPP(S) request on `{name}.mydocker.example.com` to the respective container. The environment variable is automatically set when using the metaphactory `docker-compose.yml` as described below. It uses the `COMPOSE_PROJECT_NAME` from the `.env` file as `vhost` name and as such the `vhost` name is equal to the prefix of metaphactory container.
7. Some final fine-tuning: Enable gzip and increase body size in nginx-proxy. Copy the following configuration into `touch /home/docker/config/nginx/conf.d/proxy.conf`
	
		client_max_body_size 100m;
		gzip on;
		gzip_proxied any;
		gzip_vary on;
		gzip_disable "MSIE [1-6]\.(?!.*SV1)";
		gzip_types application/sparql-results+json;

	and restart the `nginx-proxy` with `docker restart nginx-proxy` to load the configuration. The body size can be increased as needed e.g. by other front- or backend-containers and depending on the use-cases (nginx's default is usually 2MB for security reasons, whereas the metaphactory platform uses usually 100MB as a default).

**Please Note:** 

* If you do not want to use HTTPS, simple modify the nginx `docker-compose/nginx/docker-compose.yml` file i.e. remove/comment the line where the 443 is exposed and where the path to the `/home/docker/config/nginx/certs` folder is mounted as volume. The volumes section is also the place to be modified, in case you want to use a different location to place your configuration files including specific vhost configs or certificates. For details, please refer to the official [jwilder/nginx-proxy documentation](https://github.com/jwilder/nginx-proxy).<br><br>
* If you do not want to or are not able to use the nginx proxy at all (for example, you do not have a DNS entry for your host), you can still use the `docker-compose/metaphactory-blazegraph/docker-compose.yml` script to maintain your deployments.  However, you will need to map/expose the metaphactory docker container port `8080` to a free host port (you basically need one port / deployment). Simply uncomment and modify the port section in the `docker-compose.yml` file and parameterize the exposed port for every deployment trough a environment variable from your .env files.

### Optional: Setup with Let's Encrypt
For Let's Encrypt the system should be accessible from the outside world. Otherwise the setup is exactly the same as for default nginx, but one need to use docker-compose file from the `docker-compose/nginx-letsencrypt`.