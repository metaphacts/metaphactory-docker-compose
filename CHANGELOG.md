# Changelog

All notable changes to the docker-compose setup are documented in this file.

Note: when updating to a newer release of metaphactory, also regard the information from the respective [Changelog](https://help.metaphacts.com/resource/Help:Start?tab=Changelog). Updates to the application content may be required as specified in the upgrade notes.

If not mentioned otherwise, the docker-compose definitions are backwards compatible to the previous released version.

## 2021-03-16

- Robustness for GraphDB compose setup w.r.t. configuration container


## 2021-03-02

- Fix Stardog compose setup to execute as "root" user for proper volume permissions


## 2021-02-15 (Release 4.0.0)

The docker tags have been updated to the 4.0.0 release of metaphactory.

The docker-compose setup for Nginx has been revised (particularly w.r.t security aspects).

Users are encouraged to migrate existing environments. Note that this is a **breaking** change as the folder and compose structure for Nginx has changed. It is easiest to re-setup nginx following the instructions of the [readme](README.md).

- improved nginx docker compose setup with integrated security best practices
- use latest "named" version of nginx and letsencrypt images

See also [here](nginx/readme.md) for details on the Nginx security configuration.

Other changes:

- GraphDB version in docker-compose template updated to 9.5.0
- GraphDB example repository configuration for enabling SHACL validation
- update Blazegraph image to use a newer base image (Jetty 9.4.35 + Java 8u275)



## 2020-09-29 (Release 3.6.0)

The docker tags have been updated to the 3.6.0 release of metaphactory.

- add docker-compose template and instructions for GraphDB
- add docker-compose instructions on how to expose a https connector
- updated Blazegraph image to use a newer base image (Jetty 9.4.31 + Java 8u265)


## 2020-07-10 (Release 3.5.0)

The docker tags have been updated to the 3.5.0 release of metaphactory.

- updated GIT links to point to the new repository location at GitHub
- updated Blazegraph image to use a newer base image (Jetty 9.4.27 + Java 8u252)
- improved documentation for the Nginx network setup
- introduced a changelog for the docker-compose setup


## 2020-03-31 (Release 3.4.0)

The docker tags have been updated to the 3.4.0 release of metaphactory.

Additional improvements

- activate Stardog specific optimization strategy in GraphScope configuration
- improved documentation of Nginx setup (e.g. proxy timeout)



## 2020-01-17 (Release 3.3.0.1)

The docker tags have been updated to the 3.3.0.1 patch release of metaphactory.


## 2019-12-13 (Release 3.3.0)

The docker tags have been updated to the 3.3.0 release of metaphactory.

Additional improvements

- upgrade Blazegraph docker image to Jetty 9.4.18 / Java 8u212
- improved setup instructions GraphScope
- added instructions on how to connect to Stardog


## 2019-10-09 (Release 3.2.0)

In metaphactory 3.2.0 the Docker container has been optimized:

- **Breaking**: Don't create and attach external nginx network by default (c.f. Optional Nginx Setup, Step 8)
- **Breaking**: New folder and service-template structure. New logic for composing docker-compose files in the .env file.
- The Jetty web server does not run as root and no longer changes file ownership in volumes so the (existing) file permissions matter

The docker-compose definition is not compatible to previous releases.