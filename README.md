# Dockerized WordPress with Nginx / SSL / Automatic Container Updates

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

**What is Nginx?**  
Nginx (pronounced "engine-x") is a powerful web server software. It can handle tasks like serving static content, acting as a reverse proxy, and load balancing. A reverse proxy is like a middleman that directs web requests to the appropriate service or application. In our setup, Nginx primarily acts as this middleman, directing incoming web traffic to specific containers, such as the WordPress container.

**Why use Nginx in a Dockerized setup?**  
When you have multiple services running, like in our Docker Compose setup, you need a way to direct incoming traffic to the right service. Nginx excels at this. By using Nginx in our Docker setup, we can:

- **Efficiently Serve Content**: Nginx can quickly serve static content like images, stylesheets, and scripts, reducing the load on other services.
  
- **SSL Termination**: Handle the decryption of secure SSL traffic, offloading this task from other services and ensuring secure communication.
  
- **Load Balancing**: Distribute incoming traffic across multiple instances of a service, improving response times and fault tolerance.
  
- **Caching**: Store frequently accessed content in memory, speeding up response times and reducing the load on backend services.

**Configuration in our setup:**  
In our `docker-compose.yml`, the Nginx service is defined as follows:

```yaml
nginx:
  build:
    context: .
    dockerfile: nginx/Dockerfile
  ...
```

Here's a breakdown:

- `build`: This section tells Docker Compose to build a new image using the specified Dockerfile. This custom build allows us to add specific configurations and modules to Nginx, like the Brotli compression module.

- `context: .`: This sets the build context to the current directory. Docker will look for files and directories in the current directory when building the image.

- `dockerfile: nginx/Dockerfile`: This points to the Dockerfile for Nginx, which contains the instructions to build the custom Nginx image.

The rest of the configuration deals with port mappings, volume mounts, and other settings to ensure Nginx works seamlessly with other services in our setup.

By understanding the role of Nginx in our Dockerized setup, you can better appreciate how web requests are handled, routed, and served to users.


### 2.2 Nginx-gen Service

**What is `nginx-gen`?**  
`nginx-gen` stands for Nginx Generator. It's a dynamic configuration generator for Nginx. In the world of Docker, where containers can be started or stopped on-the-fly, the configuration of a reverse proxy like Nginx needs to be equally dynamic. That's where `nginx-gen` comes in. It listens for Docker events like starting or stopping containers and updates the Nginx configuration accordingly.

**Why use `nginx-gen` in a Dockerized setup?**  
In a Docker environment, services (containers) can be ephemeral, meaning they can come up or go down based on demand or updates. This dynamic nature requires the reverse proxy (Nginx in our case) to be aware of these changes and adjust its configuration in real-time. `nginx-gen` automates this process. Key benefits include:

- **Automatic Configuration**: As new services are added or removed, `nginx-gen` automatically updates the Nginx configuration without manual intervention.
  
- **Zero Downtime**: With `nginx-gen`, there's no need to restart Nginx every time its configuration changes. This ensures continuous service availability.
  
- **Simplified Management**: Instead of manually editing Nginx configuration files, you can rely on `nginx-gen` to handle it, making the management of large setups more straightforward.

**Configuration in our setup:**  
In the `docker-compose.yml`, the `nginx-gen` service is defined as:

```yaml
nginx-gen:
  image: jwilder/docker-gen
  ...
```

Here's a breakdown:

- `image: jwilder/docker-gen`: This tells Docker Compose to use the official `docker-gen` image created by Jason Wilder. This image contains the `docker-gen` tool and all its dependencies.

- The rest of the configuration ensures that `nginx-gen` can access the necessary Docker events and has the right templates to generate the Nginx configurations.

By integrating `nginx-gen` into our Dockerized setup, we ensure that our Nginx service is always aware of the state of our application, adjusting in real-time to changes in the environment.



### 2.3 Letsencrypt-companion Service

**What is `letsencrypt-companion`?**  
`letsencrypt-companion` is a helper service designed to simplify the process of creating, renewing, and using Let's Encrypt SSL certificates with Nginx in a Docker environment. SSL (Secure Sockets Layer) certificates are essential for encrypting data between a user's browser and a server, ensuring secure and private communication over the internet.

**Why use `letsencrypt-companion` in a Dockerized setup?**  
Managing SSL certificates can be a complex task, especially in dynamic environments like Docker. The `letsencrypt-companion` automates this process, offering several advantages:

- **Automated Certificate Issuance**: It automatically requests and obtains SSL certificates for your domains from Let's Encrypt.
  
- **Certificate Renewal**: Let's Encrypt certificates are valid for 90 days. `letsencrypt-companion` automates the renewal process, ensuring your sites are always secured with valid certificates.
  
- **Nginx Integration**: The companion service seamlessly integrates with Nginx, automatically updating its configuration to use the obtained certificates.
  
- **Zero Downtime**: With `letsencrypt-companion`, there's no need to restart Nginx when new certificates are obtained or renewed. This ensures continuous service availability.

**Configuration in our setup:**  
In the `docker-compose.yml`, the `letsencrypt-companion` service is defined as:

```yaml
letsencrypt-companion:
  image: jrcs/letsencrypt-nginx-proxy-companion
  ...
```

Here's a breakdown:

- `image: jrcs/letsencrypt-nginx-proxy-companion`: This instructs Docker Compose to use the official `letsencrypt-nginx-proxy-companion` image. This image contains all the necessary tools and scripts to automate the certificate management process with Nginx.

- The rest of the configuration ensures that `letsencrypt-companion` can communicate with the Nginx service, access the necessary Docker events, and store the certificates in the right location.

By incorporating `letsencrypt-companion` into our Dockerized setup, we ensure that our web services are always secured with up-to-date SSL certificates, enhancing the security and trustworthiness of our application.


### 2.4 Database Service (db)

**What is the Database Service?**  
The `db` service in our setup represents a MySQL database. MySQL is one of the world's most popular open-source relational database management systems (RDBMS). It's used to store, retrieve, and manage data in structured tables, making it a crucial component for many web applications, including WordPress.

**Why use MySQL in a Dockerized setup?**  
Dockerizing MySQL offers several advantages:

- **Isolation**: Running MySQL inside a container ensures that it doesn't interfere with other services or applications on the host system.
  
- **Portability**: With Docker, you can easily move your MySQL instance between environments (development, staging, production) while maintaining the same configuration and data.
  
- **Version Management**: Docker makes it straightforward to run different versions of MySQL or switch between versions as needed.
  
- **Scalability**: In more advanced setups, Docker can help scale MySQL instances horizontally, improving database performance and redundancy.

**Configuration in our setup:**  
In the `docker-compose.yml`, the `db` service is defined as:

\```yaml
db:
  image: mysql:5.7
  ...
\```

Here's a breakdown:

- `image: mysql:5.7`: This instructs Docker Compose to use the official MySQL image, version 5.7. This image contains the MySQL server and its dependencies, ensuring a consistent and reliable MySQL setup.

- `environment`: This section defines environment variables that configure the MySQL instance, such as the root password, database name, user, and user password. In our setup, these values are sourced from an `.env` file.

- The rest of the configuration, like `volumes`, ensures data persistence, meaning the data remains intact even if the container is stopped or removed. This is crucial for a database service to prevent data loss.

By integrating a Dockerized MySQL instance into our setup, we ensure a reliable, scalable, and consistent database service that seamlessly integrates with other components, like WordPress.

### 2.5 WordPress Service

**What is the WordPress Service?**  
The `wordpress` service represents a containerized instance of WordPress, one of the most popular content management systems (CMS) in the world. WordPress allows users to create, manage, and publish content on the web with ease, making it a favorite choice for bloggers, businesses, and developers.

**Why use a Dockerized WordPress setup?**  
Running WordPress in a Docker container offers several benefits:

- **Isolation**: The containerized setup ensures that WordPress runs in an isolated environment, preventing potential conflicts with other applications or services.
  
- **Consistency**: Docker ensures that WordPress behaves the same way across different environments, be it development, staging, or production.
  
- **Quick Deployment**: With Docker, setting up a new WordPress instance becomes a matter of minutes, if not seconds.
  
- **Version Management**: Easily switch between different versions of WordPress or run multiple versions simultaneously.

**Custom Image in our setup:**  
In our configuration, the WordPress service uses a custom Docker image. This custom image is built from a Dockerfile, which contains specific instructions to tailor the WordPress environment to our needs.

Here's what the custom image does:

1. **Installs wp-cli**: The `wp-cli` is a command-line tool for managing WordPress installations. It simplifies tasks like downloading, installing, and configuring WordPress without using a web browser.

2. **Installs MySQL client**: This allows the WordPress container to communicate directly with the MySQL database, facilitating tasks like data import/export and direct database queries.

3. **Integrates a setup script**: The `setup-wordpress.sh` script automates the initial setup of WordPress, including downloading WordPress core, creating the configuration file, and initializing the database.

**Configuration in our setup:**  
In the `docker-compose.yml`, the `wordpress` service is defined as:

```yaml
wordpress:
  build:
    context: .
    dockerfile: wordpress/Dockerfile
  ...
```

Here's a breakdown:

- `build`: This section tells Docker Compose to build the WordPress image using the custom Dockerfile. This ensures that our WordPress container has all the tools and configurations specific to our setup.

- `environment`: This section defines various environment variables that WordPress uses for its configuration, such as database connection details, site URL, and admin credentials.

- The rest of the configuration, like `volumes`, ensures data persistence for the WordPress installation and integrates the custom setup script.

By using a custom Dockerized WordPress setup, we ensure a tailored, consistent, and efficient environment for our WordPress application, optimized for our specific requirements.

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
