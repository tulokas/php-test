FROM mysql:8.0

# Create secure dir, copy certs, set ownership and permissions
RUN mkdir -p /etc/mysql/certs
COPY certs/ /etc/mysql/certs/
RUN chmod 600 /etc/mysql/certs/*.pem && chown -R mysql:mysql /etc/mysql/certs

# Copy MySQL config
COPY my.cnf /etc/mysql/conf.d/my.cnf
