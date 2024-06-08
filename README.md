# They Might Be Giants Song of the Day
[![Deploy TMBG Song Of The Day](https://github.com/zmaillard/tmbgodt/actions/workflows/deploy.yml/badge.svg)](https://github.com/zmaillard/tmbgodt/actions/workflows/deploy.yml)

An application that is used to learn Gleam.  Based off of the https://github.com/gleam-wisp/wisp project.  The premise of this site is to also showcase a gift given to me by my son for Christmas, in which he prepared be a container full tiny pieces of paper.  Each piece of paper has a They Might Be Giants song written on it.  Every day, I pull a new song out of the container and queue it up to listen.  One a day for all 366 days of 2024.  To quote Cousin Eddie from Christmas Vacation: "Clark, That's The Gift That Keeps On Giving The Whole Year."

## Other Technologies Used
- [Tailwind](https://tailwindcss.com)
- [Matcha Templates](https://github.com/michaeljones/matcha)
- [htmx](HTTPS://HTMX.ORG)

## Infrastructure
- [FlyIO](https://fly.io)
- PostgreSQL (Hosted using [Neon Serverless](https://neon.tech))
- GitHub Actions For Deployment
- [Auth0](https://auth0.com) For Identity Management

## Enviornment Variables (Defined As Secrets)
- AUTH0_CALLBACK - Url to redirect after login
- AUTH0_CLIENTID - Client id for Auth0 Application
- AUTH0_DOMAIN - Url for Auth0 Tenant
- SECRET_KEY - Secret key used by Wisp
- USER_ID - User id used for authentication
- POSTGRES_USER - Database user
- POSTGRES_HOST - Database host
- POSTGRES_PASS - Database password
- POSTGRES_DB - Database name
