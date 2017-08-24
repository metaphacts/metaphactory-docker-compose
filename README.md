# metaphactory / blazegraph deployments with docker-compose

**Prerequisites:**

* docker installed (version >= 1.9 , check with `docker --version`)
* docker-compose installed (version >= 1.14, check with `docker-compose --version`)
* outgoing HTTP/HTTPS traffic, allowing to access external docker registries (e.g. docker public or other private/corporate docker registries)


## Initial Setup: NGINX Proxy Container
It is recommended to use a proxy container with virtual host mappings to proxy the incoming HTTP traffic to the individual container instances. Reasons are:

* Security
	* Not every container/deployment should expose a port (neither on localhost nor to the outside network). Firewall needs to open only two ports.
	* SSL certificate handling in a single place. Instead of dealing with certificates individually or using self-signed certificates, there will be only one officially signed wildcard certificate. One-time installation, valid for all deployments.
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
2. Copy SSL certificate to `/home/docker/config/nginx/certs` i.e. the *.key file and *.crt file must be named equivalent to the hostname (e.g. mydocker.example.com.key and mydocker.example.com.crt, if you have a wildcard certificate for *.mydocker.example.com). Set proper permissions to protect the key file (i.e. docker must be able to read it, but no one else). The *.cert file should contain only the certificate body (from `-----BEGIN CERTIFICATE----- ` to `-----END CERTIFICATE----- `) but also all intermediate certificates/root certificate required for the certificate chain. You can simple concatenate these, however, order matters:

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


## metaphactory / blazegraph Deployment and Maintenance

**Prerequisites:**

 To perform any deployments or updates, you will first need to login to the metaphact's docker registry with your metaphacts account i.e. run `docker login docker.metaphacts.com`.

### Initial Deployment
To create a new deployment from scratch:

1. Go into the `cd docker-compose/metaphactory-blazegraph` folder and create a copy of the `service-template` folder i.e. `cp -r service-template my-deployment`. The main idea idea is to maintain one subfolder for every deployment.
2. Go into the newly created folder `my-deployment` and open the file `.env` e.g. `vi .env`
3. Change the value of the `COMPOSE_PROJECT_NAME` variable to a unique name i.e. the name will be used to prefix container names as well as `vhost` entry in the nginx proxy.
4. Run `docker-compose up -d`. It is **important to run the command in the my-deployment (containing the .env file)**, since docker-compose will pick up the `.env` file for parameterization.

### Update of Deployments
The most frequent use-case will be updating the runtime (i.e. software) container, for example, of the metaphactory or blazegraph, but leaving the deployment specific data and configuration assets untouched.

1. Modify the `.env` file in the folder of the deployment you want to update and increase/change the docker version tag of the metaphactory or blazegraph container i.e. `METAPHACTORY_IMAGE` and/or `BLAZEGRAPH_IMAGE`. Do not change `METAPHACTORY_DATA_IMAGE` if you want do keep your current configuration.
2. Run `docker-compose up -d` will re-create only the containers, that has been changed.

### Deletion of Deployments
Run `docker-compose down` in the folder for deployment you want to purge. Please note, that **all containers and non-external volumes and networks** for the deployment will be removed and deleted. Make sure that you are in the correct folder (where the respective `.env` file for the deployment is located), before executing the down command.