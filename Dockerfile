FROM i386/ubuntu:latest

# Compile Ruby 1.8.1 from source
RUN apt-get update && \
    apt-get install -y build-essential bison zlib1g-dev wget && \
    wget https://cache.ruby-lang.org/pub/ruby/1.8/ruby-1.8.1.tar.gz && \
    tar xvf ruby-1.8.1.tar.gz && \
    cd ruby-1.8.1 && \
    ./configure && \
    make && \
    make install

# Install necessary (Apache, MySQL) and useful dependencies
RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-fcgid libfcgi-dev mysql-server-5.7 \
                       vim less git

# Enable Apache modules:
# - Rewrite for routing in .htaccess file
# - CGI to pipe stdin and stdout to and from Ruby in development
# - FCGI for faster forking of CGI in production
RUN a2enmod rewrite && \
    a2enmod cgi && \
    a2enmod fcgid

# Name the server for Apache (less warnings)
RUN echo '\
    ServerName rails\n\
    ' >> /etc/apache2/apache2.conf

# Configure vhost allowing CGI and FCGI
RUN echo '\
<VirtualHost *:80>\n\
  DocumentRoot /var/www/rails/public/\n\
  ErrorLog /var/www/rails/log/apache.log\n\
  \n\
  <Directory /var/www/rails/public/>\n\
    Options ExecCGI FollowSymLinks\n\
    AllowOverride all\n\
    AddHandler cgi-script .cgi\n\
    AddHandler fcgid-script .fcgi\n\
  </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Simulate default socket location as of MySQL 4
RUN ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock

# Enable simple password login for MySQL
RUN service mysql start && \
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY ''; FLUSH PRIVILEGES;" && \
    service mysql stop

# Install Ruby libraries
COPY ./vendor/fcgi /var/www/rails/vendor/fcgi
COPY ./vendor/rake /var/www/rails/vendor/rake
COPY ./vendor/rubygems /var/www/rails/vendor/rubygems
RUN cd /var/www/rails/vendor/fcgi && ruby install.rb # To run app with production performance
RUN cd /var/www/rails/vendor/rake && ruby install.rb # To run tests and generators
RUN cd /var/www/rails/vendor/rubygems && ruby install.rb # Rakefile dependency to publish activerecord and actionpack

EXPOSE 80
CMD ["/var/www/rails/bin/startup.sh"]
