# tmbgodt

An application that is used to learn Gleam.  Based off of the https://github.com/gleam-wisp/wisp project.


## Infrastructure
- FlyIO
- LiteFS / Sqlite Database
- GitHub Actions For Deployment
- Auth0 For Identity Management

## Enviornment Variables (Defined As Secrets)
- AUTH0_CALLBACK - Url to redirect after login
- AUTH0_CLIENTID - Client id for Auth0 Application
- AUTH0_DOMAIN - Url for Auth0 Tenant
- SECRET_KEY - Secret key used by Wisp
- USER_ID - User id used for authentication

## Config Fly.IO
https://fly.io/docs/litefs/speedrun/