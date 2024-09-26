# Changelog

All notable changes to the docker-compose setup are documented in this file.

Note: when updating to a newer release of metaphactory, also regard the information from the respective [Changelog](https://help.metaphacts.com/resource/Help:Start?tab=Changelog). Updates to the application content may be required as specified in the upgrade notes.

If not mentioned otherwise, the docker-compose definitions are backwards compatible to the previous released version.

## 2024-09-25 (Release 5.5.0)

The docker tags have been updated to the 5.5.0 release of metaphactory.

Other changes:

- Update GraphDB to 10.7.3
- Update Nginx-proxy to 1.6.1 (Nginx version: 1.27.1)


## 2024-07-05 (Release 5.4.0)

The docker tags have been updated to the 5.4.0 release of metaphactory.

Other changes:

- Update GraphDB to 10.6.4
- Update RDFox to 7.1a
- Update Nginx-proxy to 1.6.0 (Nginx version: 1.27.0)
- Maintain security headers in nginx.tmpl



## 2024-03-28 (Release 5.3.0)

The docker tags have been updated to the 5.3.0 release of metaphactory.

Other changes:

- Update GraphDB to 10.6.2 & increase graceful shutdown timeout
- Update Nginx-proxy to 1.5.1 (Nginx version: 1.25.4)
- Maintain nginx.tmpl from nginx-proxy upstream


## 2024-02-01 (Release 5.2.1)

The docker tags have been updated to the 5.2.1 release of metaphactory.

Other changes:

- Refine RDFox datastore settings


## 2024-01-15 (Release 5.2.0)

The docker tags have been updated to the 5.2.0 release of metaphactory.

Other changes:

- Add RDFox 7.0 integration
- Maintain nginx.tmpl from nginx-proxy upstream
- Update GraphDB to 10.4.3


## 2023-10-06 (Release 5.1.0)

The docker tags have been updated to the 5.1.0 release of metaphactory.

Other changes:

- Update GraphDB to 10.3.2
- Adjust GraphDB repository configuration to throw exception on query timeouts
- Update readme instructions to use `docker compose` as command


## 2023-07-27 (Release 5.0.0)

The docker tags have been updated to the 5.0.0 release of metaphactory.

Other changes:

- Update GraphDB to 10.2.3


## 2023-06-07 (Release 4.8.6)

The docker tags have been updated to the security patch release 4.8.6 of metaphactory.

Other changes:

- The nginx-proxy image has been updated to 1.3.1, acme-companion to 2.2.8
- Update GraphDB to 10.2.1


## 2023-03-03 (Release 4.8.4)

The docker tags have been updated to the security patch release 4.8.4 of metaphactory.

Other changes:

- The nginx-proxy image has been updated to 1.2.2, acme-companion to 2.2.6
- Update GraphDB to 10.1.5


## 2022-12-21 (Release 4.8.0)

The docker tags have been updated to the 4.8.0 release of metaphactory.

Other changes:

- Adjust Content Security Policy configuration in Nginx to define `image-src: blob:` (required for exporting PNGs of Charts)
- Update GraphDB to 10.1.2
- Set `enable-context-index=true` in GraphDB repository configurations 
- Removed GraphScope container configuration

## 2022-11-21 (Release 4.7.2)

The docker tags have been updated to the security patch release 4.7.2 of metaphactory.


## 2022-10-20 (Release 4.7.0)

The docker tags have been updated to the 4.7.0 release of metaphactory.

Other changes

- Update GraphDB to 10.0.2 (incl. repository configuration snippets)
- Adjust license configuration for GraphDB (no longer use volume mounts, instead upload through the GraphDB workbench
- Deprecate and remove docker-compose integration for Blazegraph
- Adjust Content Security Policy configuration in Nginx to define font-src (required for embedded fonts in diagram printing)


## 2022-08-19 (Release 4.6.2)

The docker tags have been updated to the security patch release 4.6.2 of metaphactory.


## 2022-07-22 (Release 4.6.1)

The docker tags have been updated to the bug fix release 4.6.1 of metaphactory.


## 2022-07-11 (Release 4.6.0)

The docker tags have been updated to the 4.6.0 release of metaphactory.

The docker-compose setup for Nginx has been revised (particularly w.r.t new official nginx images).

Users are encouraged to migrate existing environments. Note that this is a **breaking** change as the images and compose structure for Nginx has changed. It is easiest to re-setup nginx following the instructions of the [readme](README.md).

- use latest official images from https://hub.docker.com/r/nginxproxy/nginx-proxy
- revise compose structure: docker-gen is now integrated in nginx-proxy image
- use official nginxproxy ACME companion

See also [here](nginx/readme.md) for details on the Nginx security configuration.

Other changes

- Add compatibility instructions of metaphactory >= 4.6.0 with GraphDB 9.x
- Update GraphDB to 9.11.2-ee


## 2022-04-01 (Release 4.5.0)

The docker tags have been updated to the 4.5.0 release of metaphactory.

As of 4.5.0 metaphactory is shipped as a multi-architecture container image.

Other changes

- Add GraphDB 10 repository configuration examples
- Add compatibility instructions of metaphactory <= 4.5.0 with GraphDB 10
- Updated Nginx to 1.21.4, Letsencrypt Companion to 2.2.0
- Refine Nginx security header documentation (enclose with quotes)


## 2021-12-20 (Release 4.4.1)

The docker tags have been updated to the security patch release 4.4.1 of metaphactory.


## 2021-12-16 (Release 4.4.0)

The docker tags have been updated to the 4.4.0 release of metaphactory.

Other changes:

- Updated Nginx to 1.21.4
- Refined instructions for setting up Nginx with HTTPS
- GraphDB version in docker-compose template updated to 9.10.0
- update Blazegraph image to use a newer base image (Jetty 9.4.44 + Java 8u302)


## 2021-09-30 (Release 4.3.0)

The docker tags have been updated to the 4.3.0 release of metaphactory.

The docker-compose setup for Nginx has been updated to latest versions of the software. Users are encouraged to update their respective service instantiations.

- update Nginx to 1.21.3

Other changes:

- GraphDB version in docker-compose template updated to 9.9.0



## 2021-07-09 (Release 4.2.0)

The docker tags have been updated to the 4.2.0 release of metaphactory.

The docker-compose setup for Nginx has been updated to latest versions of the software. Users are encouraged to update their respective service instantiations.

- update Nginx to 1.21.0
- update Nginx Let's Encrypt companion to 2.1.0 for newer ACME based security standards

Other changes:

- improve Nginx [proxy configuration](nginx/service-template/conf.d/proxy.conf) to enable gzipped transfer of RDF files
- update Blazegraph image to use a newer base image (Jetty 9.4.41 + Java 8u292)
- GraphDB version in docker-compose template updated to 9.8.0
- improve GraphDB memory settings using container configuration



## 2021-04-13 (Release 4.1.0)

The docker tags have been updated to the 4.1.0 release of metaphactory.

Other changes:

- make GraphScope an optional service to start on-demand only
- make `/storage` in metaphactory image a persistent Docker volume
- improve documentation for using a custom keystore


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