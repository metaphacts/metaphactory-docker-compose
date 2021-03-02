# metaphactory deployments with docker-compose

**Prerequisites:**

* docker installed (version >= 17.x , check with `docker --version`)
* docker-compose installed (version >= 1.14, check with `docker-compose --version`)
* outgoing HTTP/HTTPS traffic, allowing to access external docker registries (e.g. docker public or other private/corporate docker registries)

## metaphactory Deployment and Maintenance

**Prerequisites:**

Please request your personal token to access our private docker hub registry via https://metaphacts.com/get-started (select "Docker - any graph database").

### Initial Deployment

The following instructions are tested and validated on Linux and macOS. If running on Windows, please use the PowerShell UI for maximum compatibility.

To create a new deployment, start as follows:

1. Clone this GIT repository with `git clone https://github.com/metaphacts/metaphactory-docker-compose.git`
2. Create a copy of the `service-template` folder i.e. `cp -r service-template my-deployment`. The idea is to maintain one subfolder for every deployment.

Then, depending on which database backend you want to use, enter the newly created deployment directory, and choose an option:

#### metaphactory with Blazegraph

This is the simplest deployment to choose for local development.

3. Run `cp ./database-config/.env_blazegraph .env`.
4. Open the file `.env` e.g. `vi .env` and perform following changes:
    1. Change the value of the `COMPOSE_PROJECT_NAME` variable to a unique name (default is `my-deployment-1`). The name will be used to prefix container names as well as `vhost` entry in the nginx proxy (if used).
5. Run `docker-compose up -d`. It is **important to run the command in the 'my-deployment' folder (containing the .env file)**, since docker-compose will pick up the `.env` file for parameterization.
6. Open `http://localhost:10214` and login with user `admin` and password `admin`

#### metaphactory only - for use with existing graph databases

3. run `cp ./database-config/.env_default .env`
4. Open the file `.env` e.g. `vi .env` and perform following changes:
    1. Change the value of the `COMPOSE_PROJECT_NAME` variable to a unique name (default is `my-deployment-1`). The name will be used to prefix container names as well as `vhost` entry in the nginx proxy (if used).
5. If you want to connect to a SPARQL endpoint accessible only via the docker hostmachine, please see the instructions in the section [Accessing docker hostmachine from docker container](#accessing-docker-hostmachine-from-docker-container).
6. Run `docker-compose up -d`. It is **important to run the command in the 'my-deployment' folder (containing the .env file)**, since docker-compose will pick up the `.env` file for parameterization.
7. Open `http://localhost:10214` and login with user `admin` and password `admin`

#### metaphactory with Stardog

 **Please note:** use of Stardog requires that you own a valid Stardog license file.

3. run `cp ./database-config/.env_stardog .env`.
4. Open the file `.env` e.g. `vi .env` and perform following changes:
    1. Change the value of the `COMPOSE_PROJECT_NAME` variable to a unique name (default is `my-deployment-1`). The name will be used to prefix container names as well as `vhost` entry in the nginx proxy (if used).
    2. Please note that the deployment will contain GraphScope (`https://www.metaphacts.com/graphscope`), which runs in its own container and requires additional 2GB of memory. Remove `:./docker-compose.graphscope.yml` from the `COMPOSE_FILE` parameter to deactivate GraphScope.
5. (Only for **metaphactory with Stardog**) Please perform additional steps below to prepare the Stardog configuration:
    1. Add your Stardog license into the `/database-config/stardog-config` folder by replacing the existing file `stardog-license-key.bin`. 
    2. You may want to modify Stardog specific parameters in the `/database-config/stardog-config/docker-compose.stardog.yml` file i.e. changing the default memory settings
    3. You can also modify the `/database-config/stardog-repository-config/myDB.ttl` file, i.e. to use a different Stardog database name or changing the default credentials for the repository connection with Stardog. The credentials can optionally be externalized using the keys `repository.default.username` and `repository.default.password`, see https://help.metaphacts.com/resource/Help:ExternalizedSecrets for further details. Please note that changes to the database name require modification of the database configuration in `/database-config/stardog-config/database-template.properties`.
    4. Also note that GraphScope has a reference to the database as well, which would need to be updated in `graphscope-config/stardog-config.yml` with the parameter `remoteEndpoint`, in case of changes.

6. Run `docker-compose up -d`. It is **important to run the command in the 'my-deployment' folder (containing the .env file)**, since docker-compose will pick up the `.env` file for parameterization.
7. Run `docker-compose exec stardog /opt/stardog/bin/stardog-admin db create -c /var/opt/stardog/database-template.properties -n myDB` to create a Stardog database. Also modify the database name from `myDB` to the name you used (e.g. if you modified the `myDB.ttl` file). 

**Please note:** For the creation of the stardog database the `stardog-config/database-template.properties` will be used. This is important, since this property file sets some database configurations (for example, enabling text search/indexing and querying of all named graphs) which are important to make metaphactory seamlessly work with Stardog.

8. Open `http://localhost:10214` and login with user `admin` and password `admin`

**Note:** we are running the Stardog container as `root` user to avoid restricted volume permissions in certain Stardog images (incl. 7.4.5 and 7.5.0), c.f. `database-config/docker-compose.stardog.yml`. 

#### metaphactory with GraphDB

**Please note:** use of GraphDB requires that you own a valid GraphDB license file.

3. run `cp ./database-config/.env_graphdb .env`. 
4. Open the file `.env` e.g. `vi .env` and perform following changes:
    1. Change the value of the `COMPOSE_PROJECT_NAME` variable to a unique name (default is `my-deployment-1`). The name will be used to prefix container names as well as `vhost` entry in the nginx proxy (if used).
    2. Please note that the deployment will contain GraphScope (`https://www.metaphacts.com/graphscope`), which runs in its own container and requires additional 2GB of memory. Remove `:./docker-compose.graphscope.yml` from the `COMPOSE_FILE` parameter to deactivate GraphScope.

5. Please perform additional steps below to prepare the GraphDB configuration:
    1. Add your GraphDB license file into the `/database-config/graphdb-config/license` folder by replacing the existing file `graphdb.license`. 
    2. (Optional) modify GraphDB-specific parameters in the `/database-config/docker-compose.graphdb.yml` file, for example changing the default memory settings, or modifying the location where GraphDB stores its data on the host machine (by default, in the directory `graphdb-data` in the deployment directory). 
    3. (Optional) modify the configuration of the default GraphDB database, which is automatically created on first boot. You can do so by editing `/database-config/graphdb-config/graphdb-repository-config.ttl`. If you wish to enable SHACL validation, a separate example configuration is provided in `/database-config/graphdb-config/graphdb-with-SHACL-config-example.ttl`.
    4. (Optional) you can also modify the `/database-config/graphdb-config/metaphactory.ttl` file, i.e. to use a different GraphDB database name or changing the default credentials for the repository connection with GraphDB. The credentials can optionally be externalized using the keys `repository.default.username` and `repository.default.password`, see https://help.metaphacts.com/resource/Help:ExternalizedSecrets for further details.

6. Run `docker-compose up -d`. It is **important to run the command in the 'my-deployment' folder (containing the .env file)**, since docker-compose will pick up the `.env` file for parameterization.
7. Open `http://localhost:10214` and login with user `admin` and password `admin`

## Troubleshooting

Please run `docker-compose down` before running `docker-compose up` after failed attempts (for example due to missing license file), especially if you experience errors like `unknown: Are you trying to mount a directory onto a file (or vice-versa)? Check if the specified host path exists and is the expected type`.

## Accessing docker hostmachine from docker container

* **Linux** If you want to connect to a SPARQL endpoint accessible only on the docker hostmachine, e.g. http://localhost:5828/myDB/query, please identify the IP of your docker0 network using the following command `ip -4 addr show scope global dev docker0 | grep inet | awk '{print $2}' | cut -d "/" -f 1`. In the file `my-deployment/docker-compose.overwrite.yml` uncomment the line `extra_hosts` and the line below and put the IP of your docker0 network behind 'hostmachine:', e.g. - hostmachine:172.17.0.1. Now, the SPARQL endpoint is accessible via http://hostmachine:<port>/<path>, for example http://hostmachine:5820/myDB/query. Use this URL in your repository setup.
* **Mac/Windows** (for development purposes only) The host is accessible using the pre-configured hostname `host.docker.internal` from docker version 18.03 onwards.

## Change users/password of GraphScope

* The `GraphScope service user` can be created or updated using htpasswd (`https://httpd.apache.org/docs/2.4/programs/htpasswd.html`) and is stored in the `users.htpasswd` file in the folder `graphscope-config`. For further details see https://help.metaphacts.com/resource/Help:GraphScopeSetup.
* Communication between metaphactory and GraphScope is authenticated using the credentials provided in the `proxy.prop` configuration of the respective GRAPHSCOPE_CONFIGURATION (see in .env file), e.g. `graphscope-apps/app-graphscope-default/config` for the default configuration. The defined credentials must match the registered `GraphScope service user` (see above). Note that the credentials can optionally be externalized using the keys `proxy.graphscope.loginName` and `proxy.graphscope.loginPassword`, see https://help.metaphacts.com/resource/Help:ExternalizedSecrets for further details.
* If authentication is required from the GraphScope backend to the remote SPARQL endpoint (e.g. for blazegraph, stardog or the ephedra endpoint in metaphactory) the credentials can be provided in `docker-compose.overwrite.yml` for the `graphscope` service using the environment parameters `REMOTE_USER` and `REMOTE_PWD`. 
    * The actual reference values can also be found in the respective GraphScope configuration file (e.g. `graphscope-config/config-blazegrap.yml`) in the parameters `remoteUser: <user-name>` and `remotePassword: <password>`. 
    * (For `default` only) The metaphactory service user requires `sparql:graphscope-ephedra:query:*` and the `proxy:graphscope` permissions


## Update of Deployments
The most frequent use-case will be updating the runtime (i.e. software) container, for example, of the metaphactory, GraphScope or blazegraph, but leaving the deployment specific data and configuration assets untouched. 

1. Modify the .env file in the folder of the deployment you want to update and increase/change the docker version tag of the metaphactory, GraphScope or Blazegraph container i.e. `METAPHACTORY_IMAGE`, `GRAPHSCOPE_IMAGE` and/or `BLAZEGRAPH_IMAGE`.
2. Run `docker-compose up -d` will re-create only the containers, that have been changed.

## Deletion of Deployments
Run `docker-compose down` in the folder for deployment you want to purge. Please note, that **all containers and non-external volumes and networks** for the deployment will be removed and deleted. Make sure that you are in the correct folder (where the respective `.env` file for the deployment is located), before executing the down command.

## Optional Setup: Activate HTTPS connector in metaphactory

metaphactory is typically run behind a reverse proxy (e.g. nginx or AWS ALB) which takes care of TLS termination and certificate handling. This is the preferred setup as this moves certificate handling etc. to a centrally managed endpoint and avoids having to configure all aspects of HTTPS/TLS communication within the metaphactory container.

When encrypted access to metaphactory is required, e.g. because the container is directly exposed to other services without a reverse proxy  or for encrypted communication within the service network in some environments, the HTTPS connector can be exposed as well.

The container by default runs a https connector on port `8443` with a self-signed certificate. When encrypted access is desired this port needs to be exposed to any port in the outside world, e.g. `10213`. This can be done by un-commenting the corresponding line in `docker-compose.overwrite.yml`.

It is also possible to expose the http port `8080` to a port other than `10214` and use `10214` for https.

The container-internal ports can also be adjusted by specifying the following properties using environment variable `PLATFORM_JETTY_OPTS`:
`PLATFORM_JETTY_OPTS="jetty.http.port=8081 jetty.ssl.port=8444"`

Jetty will use a self-signed certificate by default and the keystore is located in `/var/lib/jetty/etc/keystore`. 
To use a custom certificate this keystore can be replaced, e.g. using a Docker volume (just) for that file, specifying the location  
and keystore password by adding the following setting to environment variable `PLATFORM_JETTY_OPTS`: 
`PLATFORM_JETTY_OPTS="jetty.sslContext.keyStorePath=etc/mykeystore jetty.sslContext.keyStorePassword=storepwd"`

Please note that the keystore path is **always** relative to `/var/lib/jetty/` so any externally injected keystore file must be placed there! 



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
1. Create a copy of the provided `config-template` folder i.e. `cp -r nginx/service-template nginx/config`. The idea is to maintain a deployment specific configuration.
2. Copy the SSL certificate to `config/certs` i.e. the *.key file and *.crt file must be named equivalent to the hostname (e.g. mydocker.example.com.key and mydocker.example.com.crt, if you have a wildcard certificate for *.mydocker.example.com). Set proper permissions to protect the key file (i.e. docker must be able to read it, but no one else). The *.cert file should contain only the certificate body (from `-----BEGIN CERTIFICATE----- ` to `-----END CERTIFICATE----- `) but also all intermediate certificates/root certificate required for the certificate chain. You can simple concatenate these, however, order matters:

		-----BEGIN CERTIFICATE----- 
		(Your Primary SSL certificate: your_domain_name.crt) 
		-----END CERTIFICATE----- 
		-----BEGIN CERTIFICATE----- 
		(Your Intermediate certificate: xCertCA.crt) 
		-----END CERTIFICATE----- 
		-----BEGIN CERTIFICATE----- 
		(Your Root certificate: TrustedRoot.crt) 
		-----END CERTIFICATE----

3. Go into the `certs` folder i.e. `cd ./nginx/config/certs` and generate [Diffie–Hellman](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange) parameters using `openssl dhparam -dsaparam -out mydocker.example.com.dhparam.pem 4096`. `-dsaparam` [option instructs OpenSSL to produce "DSA-like" DH parameters ](https://wiki.openssl.org/index.php/Manual:Dhparam(1)#OPTIONS) , which is magnitude faster then computing the dhparam 4096 (see explanation [on stackexchange](https://security.stackexchange.com/a/95184))
Go into folder `docker-compose/nginx/config`
4. Now we are ready to create and start the proxy container. Running `docker-compose up -d` should result in:
		Creating network "nginx_proxy_network" with the default driver
		Creating nginx-proxy ...
		Creating nginx-proxy ... done

5. Verify with `docker ps` that a container `nginx-proxy` is running with two ports exposed: ```80, 443```
6. From now on the `nginx-proxy` will listen to container changes on the docker daemon. As soon as a new docker container instance is started with a environment variable  `-e VIRTUAL_HOST={name}.mydocker.example.com`, nginx will automatically create a vhost entry to proxy incoming HTPP(S) request on `{name}.mydocker.example.com` to the respective container. The environment variable is automatically set when using the metaphactory `docker-compose.yml` as described above. It uses the `COMPOSE_PROJECT_NAME` from the `.env` file as `vhost` name and as such the `vhost` name is equal to the prefix of metaphactory container.
7. The metaphactory needs to be configured to use the `nginx_proxy_network` as default external network, e.g. by adding the following snippets to the `docker-compose.ovewrite.yml` in the active service instance:

		metaphactory:
		  networks:
		    - default

		networks:
		  default:
		    external:
		      name: nginx_proxy_network

8. Some final fine-tuning of configuration can be done in `nginx/config/conf.d/proxy.conf`. The body size can be increased as needed e.g. by other front- or backend-containers and depending on the use-cases (nginx's default is usually 2MB for security reasons, whereas the metaphactory platform uses usually 100MB as a default). The `proxy_read_timeout` setting can be adjusted to configure the HTTP read timeouts, e.g. for long running queries it may be required to increase the timeout. In order to activate changes restart the `nginx-proxy` with `docker restart nginx-proxy` to load the configuration. 
9. See also [here](nginx/readme.md) for more details on Nginx Security harderning

**Please Note:** 

* If you do not want to use HTTPS, make sure to not have any SSL certificates in the `certs` folder. The volumes section of the `docker-compose` files is also the place to be modified, in case you want to use a different location to place your configuration files including specific vhost configs or certificates. For details, please refer to the official [jwilder/nginx-proxy documentation](https://github.com/jwilder/nginx-proxy).<br><br>
* If you do not want to or are not able to use the nginx proxy at all (for example, you do not have a DNS entry for your host), you can still use the `docker-compose/metaphactory-blazegraph/docker-compose.yml` script to maintain your deployments.  However, you will need to map/expose the metaphactory docker container port `8080` to a free host port (you basically need one port / deployment). Simply uncomment and modify the port section in the `docker-compose.yml` file and parameterize the exposed port for every deployment trough a environment variable from your .env files.

### Optional: Setup with Let's Encrypt
For Let's Encrypt the system should be accessible from the outside world. Otherwise the setup is exactly the same as for default nginx. In order to activate Let's Encrypt uncomment the respective line in the `nginx/config/.env` file (see file comments for details).
