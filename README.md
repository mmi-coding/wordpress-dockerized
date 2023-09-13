# WordPress Docker Setup Guide

ATTENTION : Project Still Under Dev

This guide provides an in-depth overview of setting up a WordPress site using Docker with an NGINX reverse proxy, SSL by Let's Encrypt, and automated container updates via Watchtower.

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Database Configuration](#database-configuration)
- [WordPress Setup](#wordpress-setup)
- [NGINX Reverse Proxy](#nginx-reverse-proxy)
- [SSL with Let's Encrypt](#ssl-with-lets-encrypt)
- [Automated Container Updates with Watchtower](#automated-container-updates-with-watchtower)
- [Usage and Deployment](#usage-and-deployment)
- [Conclusion and Recommendations](#conclusion-and-recommendations)

---

## Introduction

This setup aims to deploy a secure and efficient WordPress environment, utilizing containers for modularity and ease of management.

---

## Prerequisites

- Docker and Docker Compose installed on your server.
- A domain pointing to your server for SSL configuration.

---

## Database Configuration

### MySQL Container

```yaml
db:
  image: mysql:5.7
  ...
```

This section sets up the MySQL container for the WordPress database. Adjust the environment variables like `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, etc., in the `.env` file to match your desired settings.

---

## WordPress Setup

### WordPress Container

```yaml
wordpress:
  image: wordpress:latest
  ...
```

This container runs the latest version of WordPress. The `command` section is responsible for setting up the core WordPress installation and adding the desired plugins and theme. Make sure to update the plugins and theme details in the `.env` file.

---

## NGINX Reverse Proxy

### NGINX Proxy Container

```yaml
nginx-proxy:
  image: jwilder/nginx-proxy
  ...
```

This container serves as a gateway, directing incoming traffic to the appropriate containers. It also references a `custom_cache.conf` file, which provides custom cache configurations for performance improvements.

---

## SSL with Let's Encrypt

### Let's Encrypt Companion Container

```yaml
letsencrypt-companion:
  image: jrcs/letsencrypt-nginx-proxy-companion
  ...
```

This section sets up the SSL for your domain using Let's Encrypt. Ensure that you've set your domain and contact email correctly in the `.env` file for certificate issuance and renewal notifications.

---

## Automated Container Updates with Watchtower

### Watchtower Container

```yaml
watchtower:
  image: containrrr/watchtower
  ...
```

Watchtower will monitor your containers and automatically update them if there's a newer version of their base image available. This ensures your applications stay up-to-date with the latest security and feature updates.

---

## Usage and Deployment

1. Clone the repository.
2. Adjust the `.env` file with your specific configurations such as domain, email, WordPress plugins, and theme.
3. If custom cache settings are desired for NGINX, modify the `custom_cache.conf` and ensure it's placed in the same directory as the `docker-compose.yml`.
4. Start the containers with `docker-compose up -d`.
---

## Conclusion and Recommendations

This setup offers a modular and secure way to deploy WordPress. Regularly back up your database and WordPress files. Also, keep an eye on container logs for any potential issues.