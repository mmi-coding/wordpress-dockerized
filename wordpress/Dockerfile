FROM wordpress:latest

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install mysql client
RUN apt-get update \
    && apt-get install -y default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy the setup script
COPY setup-wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-wordpress.sh
