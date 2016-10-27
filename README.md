# NASA Solutions Mechanism Guide


## Application Technologies

- Node.js 4.6.1
- Nginx 1.10.2
- MySQL 5.7
- Git
- Postman

&nbsp;

## Application Setup
Log in to the the AWS server and change to the root user.
```
sudo su -
```

Install the prerequisites for setup.

```
yum install -y gcc git wget
```

Install Node.js 4.6.1 for Red Hat Enterprise Linux following the instructions at https://nodejs.org/en/download/package-manager/#enterprise-linux-and-fedora. To summarise, run
```
curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
```
then install Node.js 4.6.1 using

```
yum install -y nodejs
```

### Install MySQL
Add the MySQL YUM repository
```
wget http://repo.mysql.com//mysql57-community-release-el7-9.noarch.rpm
sudo yum localinstall mysql57-community-release-el7-9.noarch.rpm
```

Next, install MySQL server.
```
yum install -y mysql-community-server
```

Once the server is installed successfully, start the service using `service mysqld start`. Obtain the auto-generated temporary password for the root account using `grep 'temporary password' /var/log/mysqld.log`.

Log in to mysql using the temporary password and change the password for the account.
```
mysql -uroot -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'T0pcoder!';
```

### Install GraphicsMagick
GraphicsMagick will be compiled from source. Download the latest source from ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-LATEST.tar.bz2
```
wget ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-LATEST.tar.bz2
```

Install bzip2 and other dependencies required to compile from source.
```
yum install -y bzip2 freetype-devel libpng-devel libjpeg-devel libtiff-devel libxml2-devel
```

Extract the GraphicsMagick source archive using `tar -jxvf GraphicsMagick-LATEST.tar.bz2` and change the current directory to the extracted folder. Run the following commands to configure and build GraphicsMagick.
```
./configure --prefix=/usr
make
make install
```

Run `gm` in the shell to verify that the installation was successful.

&nbsp;

## Configurations

You can edit env-sample.sh to configure the application for your environment. You can set the following options:

- DB_HOST :	The host for MySQL server.	(i.e. localhost)
- DB_NAME :	The MySQL database name. 	(i.e. nasa-smg)
- DB_PORT	: The port for MySQL server.	(default 3306)
- DB_USER	: The username to login to MySQL.	(default root)
- DB_PASSWORD : The password to mysql server.	(default empty password )
- RESET_TABLES : The flag which indicates if the database tables should be created afresh. It will drop and create again all tables. Test data is not inserted. Tables will be reset each time you run node app. (default false)
- DOWNLOADS_DIR	: The path to directory where files are downloaded. Default to `<app folder>/downloads`.

In order to apply the environment variables, run `. env-sample.sh`

&nbsp;

## Database setup

You must create only empty database in MySQL server. Default database name is `nasa-smg`. Application will create all required tables.

To create the MySQL database, follow these steps.

1. Run `mysql -uroot -p` at the shell and enter the password that you configured for the root user after installing MySQL.
2. Execute ``CREATE DATABASE `nasa-smg`;`` after successful login with the MySQL client.

&nbsp;

## Deployment Instructions

### Github code

1. Clone the Github repository to your desired destination folder. For example, `git clone https://github.com/NASA-Tournament-Lab/NTL-Solution-Mechanism-Guide www`.
2. Change the working directory to the cloned folder in your terminal.
3. Run `npm install`.
4. If you wish to generate some sample data, run `node generateRealFrontendData.js`.

### Starting the app

Run `node app` in the working directory to start the application. You should now be able to access `http://<url-to-aws-instance>:3000/` where `<url-to-aws-instance>` is the URL or IP address of the AWS instance the application was deployed to, and 3000 is the configured port.

Please make sure to enable access to the configured port by updating the instance's security policy (http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/authorizing-access-to-an-instance.html).

### Nginx configuration (optional)
1. Install nginx following the instructions at https://www.nginx.com/resources/wiki/start/topics/tutorials/install/. Use `http://nginx.org/packages/rhel/7/x86_64/` as the configuration value for the repository `baseurl`.

2. Replace the contents of `/etc/nginx/conf.d/default.conf` with the following configuration. Replace `<ec2-host-name>` with the host name of your EC2 instance, and replace `3000` (if required) with the configured application port.
    ````
    server {
        listen 80;
    
        server_name <ec2-host-name>;
    
        location / {
            proxy_pass http://127.0.0.1:3000;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarder-For $proxy_add_x_forwarded_for;
    
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }
    }
    ```

3. Verify that the nginx configuration is valid by running `nginx -t`.

4. Start nginx using service `nginx start`.

5. If you encounter a 502 bad gateway error while trying to access the application using nginx, you may need to adjust the SELinux permissions for nginx. Run the following commands to set the required permissions.
    ```
    sudo cat /var/log/audit/audit.log | grep nginx | grep denied | audit2allow -M nginx
    semodule -i nginx.pp
    ```

&nbsp;

## Mapping between $ legend and SMG cost characteristics values

Since cost characteristics values might change in database, we added a new configuration section under Admin portal (Configuration tab) i.e. http://<url>:<port>/admin/help#configuration . The section will list current cost characterstics values, and next to each value there is a drop down that contains three values $, $$ and $$$. By default all values are mapped to single dollar sign legend. When you are done with mapping, make sure to save changes.

&nbsp;

## Mapping between time legend and SMG cost characteristics values

Similar to $ mapping. You can map characteristic value to Low, Med or High. By default all values are mapped to Low.
