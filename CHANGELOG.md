# Changelog

All notable changes to the docker-compose setup are documented in this file.

Note: when updating to a newer release of metaphactory, also regard the information from the respective [Changelog](https://help.metaphacts.com/resource/Help:Start?tab=Changelog). Updates to the application content may be required as specified in the upgrade notes.

If not mentioned otherwise, the docker-compose definitions are backwards compatible to the previous released version.

## (Unreleased)

- update GIT links to point to the new repository location at GitHub
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