# Readme Nginx

(for installation see [main readme](../README.md))

Run the Nginx compose setup from the instantiated `service-template`, e.g.

```
cp -r nginx/service-template nginx/config
cd nginx/config
docker-compose up -d
```


## Security hardening options

The templating definition allows to define security headers through environment variables in the container definition for `nginx-proxy` (see `docker-compose.overwrite.yml`). Alternatively, the environment variables can be specified on the virtual host, i.e. the metaphactory instance.

```
services:
  metaphactory:
    environment:
      - "SSL_POLICY=Mozilla-Modern"
```

The following environment variables are available:

Note: the value can be set to `off` to disable (i.e. not define the header). 

| Name                                | Description                                | Default                                                                                                                                                             |
|-------------------------------------|--------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| HSTS                                | Strict Transport Security                  | max-age=31536000; includeSubDomains; preload                                                                                                                        |
| X_FRAME_OPTIONS                     | X-Frame-Options header                     | DENY                                                                                                                                                                |
| CONTENT_SECURITY_POLICY             | Content-Security-Policy header             | default-src 'self'; script-src 'self' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; object-src 'none'; img-src 'self' https: data: blob:; font-src 'self' data:; |
| CONTENT_SECURITY_POLICY_REPORT_ONLY | Content-Security-Policy-Report-Only header | off                                                                                                                                                                 |
| X_CONTENT_TYPE_OPTIONS              | X-Content-Type-Option header               | nosniff                                                                                                                                                             |
| X_XSS_Protection                    | X-XSS-Protection header                    | off                                                                                                                                                                 |
| REFERRER_POLICY                     | Referrer-Policy header                     | same-origin                                                                                                                                                         |
| PERMISSIONS_POLICY                  | Permissions-Policy header                  | off                                                                                                                                                                 |


## Activating changed settings

* if environment variables in the container (see above) have been changed run `docker-compose up -d` to re-create the respective containers
* to re-generate and activate changed configuration, run `docker restart nginx-proxy`