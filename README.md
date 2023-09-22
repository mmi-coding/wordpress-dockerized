# Application Documentation: Dockerized WordPress with Nginx

## Overview

This application provides a Dockerized WordPress environment, complete with an Nginx reverse proxy, automatic SSL certificate generation via Let's Encrypt, and Brotli compression. Docker Compose orchestrates the multi-container setup.

## Table of Contents

1. [Directory Structure](#directory-structure)
2. [Docker Compose Configuration](#docker-compose-configuration)
3. [WordPress Setup Script](#wordpress-setup-script)
4. [Environment Variables](#environment-variables)
5. [Nginx Compression Configuration](#nginx-compression-configuration)
6. [Nginx Dockerfile](#nginx-dockerfile)
7. [WordPress Dockerfile](#wordpress-dockerfile)

---

## 1. Directory Structure

The application is organized into several directories and files. Here's a breakdown:

```
.
├── README.md
├── docker-compose.yml
├── nginx
│   ├── Dockerfile
│   ├── certs
│   ├── compression.conf
│   ├── conf.d
│   ├── html
│   ├── templates
│   │   └── nginx.tmpl
│   └── vhost.d
├── setup-wordpress.sh
└── wordpress
    └── Dockerfile
```

---

## 2. Docker Compose Configuration

The `docker-compose.yml` file orchestrates the application's services. Here's a step-by-step breakdown:

### 2.1 Nginx Service

This is the main Nginx reverse proxy container. It's built from a custom Dockerfile located in the `nginx` directory.

```yaml
nginx:
  build:
    context: .
    dockerfile: nginx/Dockerfile
  ...
```

### 2.2 Nginx-gen Service

Generates Nginx configurations dynamically. It uses the `jwilder/docker-gen` image.

```yaml
nginx-gen:
  image: jwilder/docker-gen
  ...
```

### 2.3 Letsencrypt-companion Service

This service manages SSL certificates for your domains.

```yaml
letsencrypt-companion:
  image: jrcs/letsencrypt-nginx-proxy-companion
  ...
```

### 2.4 Database Service

The MySQL database service for WordPress.

```yaml
db:
  image: mysql:5.7
  ...
```

### 2.5 WordPress Service

The main WordPress container, built from a custom Dockerfile.

```yaml
wordpress:
  build:
    context: .
    dockerfile: wordpress/Dockerfile
  ...
```

### 2.6 Watchtower Service

Watchtower is a unique tool in the Docker ecosystem. At its core, Watchtower is like a guardian for your Docker containers. It keeps an eye on them and ensures they are always running the latest version of their respective images.

#### What does Watchtower do?

Imagine you have several containers running applications or services. Over time, the software inside these containers (known as images in Docker terminology) might receive updates. These updates can be for new features, bug fixes, or crucial security patches. Normally, you'd have to manually update each container, which can be time-consuming and error-prone.

Watchtower automates this process. It periodically checks if there's a newer version of the image for your running containers. If it finds one, it gracefully updates the container to use the new image.

#### Configuration in our setup:

In the provided `docker-compose.yml`, Watchtower is set up as follows:

```yaml
watchtower:
    image: containrrr/watchtower
    container_name: watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 43200 # 12 hours
```

Here's a breakdown:

- `image: containrrr/watchtower`: This tells Docker to use the official Watchtower image.
  
- `container_name: watchtower`: This names our Watchtower container as "watchtower".
  
- `volumes: - /var/run/docker.sock:/var/run/docker.sock`: This line is crucial. It allows Watchtower to communicate with the Docker daemon, which is necessary for it to check and update other containers.
  
- `command: --interval 43200`: This instructs Watchtower to check for updates every 12 hours (43200 seconds).

#### Recommendations for using Watchtower:

- **Monitor Logs**: Just like any other service, it's essential to keep an eye on Watchtower's logs. They can provide insights into which containers were updated, when, and if there were any issues.
   
- **Staging Environment**: Before letting Watchtower update containers in a production environment, test its behavior in a staging or development environment. This helps you understand its update process and ensures that automatic updates don't disrupt your services.
   
- **Notifications**: Watchtower can be set up to notify you when it updates a container. This is especially useful in production environments to keep track of changes.
   
- **Rollback Strategy**: Always have a plan to rollback updates if something goes wrong. While Watchtower makes updates easy, not all updates go smoothly. It's essential to have backups and a strategy to revert to a previous state if needed.

- **Selective Updates**: If you have critical containers where you want to control updates manually, you can configure Watchtower to exclude them from automatic updates.

With Watchtower in your toolkit, managing Docker containers becomes a lot more streamlined. However, like all tools, it's essential to understand its behavior and use it judiciously.


[Full docker-compose.yml](./docker-compose.yml)

---

## 3. WordPress Setup Script

The `setup-wordpress.sh` script automates the WordPress setup:

1. **Wait for MySQL**: The script first ensures the MySQL server is ready.
2. **Download and Install WordPress**: If WordPress isn't already installed, it's downloaded and set up.
3. **Theme and Plugin Management**: The script installs the specified theme and plugins.

```bash
# Wait for MySQL to be ready
while ! mysqladmin ping -h"db" --silent; do
    sleep 1
done
...
```

[Full setup-wordpress.sh](./setup-wordpress.sh)

---

## 4. Environment Variables

The `.env` file contains environment variables:

```plaintext
MYSQL_ROOT_PASSWORD=wordpress
VIRTUAL_HOST=example.com 
...
```

**Security Note**: Always keep `.env` secure. Avoid committing sensitive data to public repositories.

---

## 5. Nginx Compression Configuration

The `compression.conf` file sets up Brotli and Gzip compression:

```nginx
# Brotli settings
brotli on;
...
# Gzip settings
gzip on;
...
```

This ensures efficient content delivery.

---

## 6. Nginx Dockerfile

This Dockerfile builds the Nginx image with Brotli compression support:

```Dockerfile
FROM nginx:alpine
...
RUN git clone https://github.com/google/ngx_brotli.git
...
```

[Full Nginx Dockerfile](./nginx/Dockerfile)

---

## 7. WordPress Dockerfile

This Dockerfile sets up the WordPress environment:

```Dockerfile
FROM wordpress:latest
...
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
...
```

[Full WordPress Dockerfile](./wordpress/Dockerfile)

---

## Conclusion

This documentation provides a comprehensive overview of the Dockerized WordPress setup. Before deploying, adjust the `.env` file settings to match your environment. Always ensure the security of sensitive data.

## Recommendations

1. **Backup Regularly**: Always maintain regular backups of your WordPress site, including both the database and the files. This ensures that you can quickly recover in case of any issues.

2. **Update Frequently**: Keep your WordPress core, plugins, and themes updated. This not only provides new features but also ensures security vulnerabilities are patched.

3. **Use Strong Passwords**: Ensure that all passwords, especially the database and WordPress admin passwords, are strong and unique. Consider using a password manager to generate and store these passwords.

4. **Limit Plugin Use**: Only install and activate plugins that are absolutely necessary. Each plugin can introduce potential vulnerabilities and can slow down your site.

5. **Monitor Traffic**: Consider setting up monitoring tools to keep an eye on the traffic and any unusual activities on your site. This can help in early detection of any potential threats.

6. **SSL**: As this setup includes Let's Encrypt for SSL, always ensure your site is accessed via HTTPS. This encrypts the data between the server and the users, enhancing security.

7. **Environment Variables**: Never commit your `.env` file or any other files containing sensitive information to public repositories. Consider using secret management tools if working in a team.

8. **Docker Image Updates**: Regularly check for updates to the Docker images you're using. Updated images can contain important security patches.

9. **Network Security**: Ensure that the Docker host and the containers are secured. Limit open ports and use firewalls or security groups to restrict access.

10. **Regular Audits**: Periodically audit your site for vulnerabilities. There are plugins and external services available that can scan your WordPress site and provide security recommendations.

Remember, security and performance are ongoing concerns. Regularly review and update your setup to adapt to new challenges and requirements.
