Setup to start metaphactory and GraphScope

1.) Setup proxy of metaphactory to connect to GraphScope
The admin user for GraphScope is defined in the graphscope app. For metaphactory to connect to GrapScope, you need to setup a proxy.

* Either provide the GraphScope admin user credentials to metaphactory via the $METAPHACTORY_OPTS env variable in the .env file, e.g.
---Example---
METAPHACTORY_OPTS=-Dconfig.proxy.graphscope.targetUri=http://graphscope:9090/graphscope -Dconfig.proxy.graphscope.loginName=admin -Dconfig.proxy.graphscope.loginPassword=<adminpassword> -Dlog4j.configurationFile=file:///var/lib/jetty/webapps/etc/log4j2.xml
---

OR

* Create /config/proxy.prop
---Example---
config.proxy.graphscope.targetUri=http://graphscope:9090/graphscope/api
config.proxy.graphscope.loginName=admin
config.proxy.graphscope.loginPassword=<adminpassword>
---

See help page for details on the proxy setup: https://help.metaphacts.com/resource/Help:AuthenticationProxy


2.) Navigate your browser to http://localhost/login and login

3.) Create a page, e.g. http://localhost/resource/GraphScope and place the GraphScope component in this page:

  <graphscope></graphscope>

4.) Load some data to metaphactory
5.) Start the GraphScope indexing
Either via the admin app: http://localhost/proxy/graphscope/gs/admin/#/?login

OR

via API Call using your metaphactory user

curl -X POST http://user:password@localhost/proxy/graphscope/api/data/stores/dataStore/rebuildIndexes
