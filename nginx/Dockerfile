# Use the official Nginx Alpine image as a base
FROM nginx:alpine

# Define environment variable for Nginx version (used in the build process)
ENV NGINX_VERSION nginx-1.25.2

# Install necessary dependencies for building
RUN apk add --no-cache \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    git \
    brotli-dev

# Clone the Brotli Nginx module and initialize submodules in /usr/src
WORKDIR /usr/src
RUN git clone https://github.com/google/ngx_brotli.git && \
    cd ngx_brotli && git submodule update --init

# Create the directory
RUN mkdir -p /usr/src

# Download Nginx source (required to compile the Brotli module)
RUN curl -v -fSL https://nginx.org/download/${NGINX_VERSION}.tar.gz -o nginx.tar.gz && \
    tar -zxC /usr/src -f nginx.tar.gz && \
    rm nginx.tar.gz

# Build the Brotli Nginx module
WORKDIR /usr/src/${NGINX_VERSION}
RUN ./configure --with-compat --add-dynamic-module=../ngx_brotli && \
    make modules

# Copy the compiled Brotli module to the Nginx modules directory
RUN cp /usr/src/${NGINX_VERSION}/objs/ngx_http_brotli_filter_module.so /usr/lib/nginx/modules/ && \
    cp /usr/src/${NGINX_VERSION}/objs/ngx_http_brotli_static_module.so /usr/lib/nginx/modules/

# Add the Brotli module loading directive to the top of the Nginx configuration
RUN echo "load_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;" > /etc/nginx/nginx.conf.new && \
    echo "load_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;" >> /etc/nginx/nginx.conf.new && \
    cat /etc/nginx/nginx.conf >> /etc/nginx/nginx.conf.new && \
    mv /etc/nginx/nginx.conf.new /etc/nginx/nginx.conf

# Clean up
RUN apk del gcc libc-dev make openssl-dev pcre-dev zlib-dev linux-headers curl gnupg libxslt-dev gd-dev geoip-dev git && \
    rm -rf /usr/src/${NGINX_VERSION} ngx_brotli
