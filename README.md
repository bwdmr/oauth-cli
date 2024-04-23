## OAuth-Cli


#### About
A demonstration of the usability of [OAuth](https://github.com/bwdmr/oauth) and [OAuthKit](https://github.com/bwdmr/oauth-kit).

###### Notable Mentions
- The service is the only one in question right now, which is google.
- There is already a custom Token defined `email`

#### Usage

- Command:
```shell
swift run oauth-cli --google \                                                           
--clientid YOURCLIENTID \
--clientsecret YOURCLIENTSECRET \
--redirecturi YOURREDIRECTURI \
--scope https://www.googleapis.com/auth/userinfo.email
```

