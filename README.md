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
