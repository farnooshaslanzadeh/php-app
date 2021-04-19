# DEVELOPMENT ENVIRONMENT WITH DOCKER-COMPOSE FOR A PHP APPLICATION

In this exercise we will create a development environment for a php application. So a developer can use it to work on its php application. The example php application we use here is a "TODO List" app and its source code already included in this repository. 

PHP application also needs an nginx to serve pages and a postgres database to persist its data. We will use ready images for these 2 components.

The application flow is in this order:

`User/Client -> nginx -> php app -> postgres`

## Dockerfile for php app

1. Use `php:5.6.30-fpm-alpine` as base image
2. Using package manager(of the base image's OS) first do update then install following packages:
- build-base
- postgresql 
- postgresql-dev
3. To update php configuration execute the following command:
`docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql`
4. Install php extensions with following command: `docker-php-ext-install pdo pdo_pgsql pgsql`
5. Using package manager again, install following packages:
- zlib-dev 
- git 
- zip
6. Then again using `docker-php-ext-install zip` install php zip extension.
7. By using curl, download composer from `https://getcomposer.org/installer`. You must not save the output of curl command to a file, but pass it to `php` command with a pipe. If you don't know how to pass output of a command to another command with pipe(|) search it on google.
8. Move file `composer.phar` to `/usr/local/bin/` (file is already inside container, no need to do COPY)
9. Create a symbolic link from `/usr/local/bin/composer.phar` to `/usr/local/bin/composer`. If you don't know how to create symbolic link, google it.
10. Copy everything from your context to `/app` directory in container
11. Change working dir to `/app`
12. Install packages required by composer with: `composer install --prefer-source --no-interaction`
13. To add paths of composer binaries, set environment variable `PATH` to: "~/.composer/vendor/bin:./vendor/bin:${PATH}"

## docker-compose
### postgres
1. Use `postgres:9.6.2-alpine` as base image 
2. Use postgres environment variables to create a database called `todos` and a user called `todoapp`, don't set password for this user.
3. Evaluate if you should expose its port.

### nginx
1. Use `nginx:1.11.10-alpine` as base image
2. Expose nginx port to port 3000 of the host
3. Nginx must be configured to use php container as upstream, so it can serve dynamic pages generated by our php application. Nginx talks with the php application from inside the docker-compose network. Open `./nginx/nginx.conf` file in the repo and replace `<container_name>:<port>` with your php app container's values.
4. Mount `./nginx/nginx.conf` file to `/etc/nginx/conf.d/default.conf` file in container.

### php-app
1. Build php application with dockerfile you created above.
2. Find out which port applications listens on (it uses php-fpm standard port) and evaluate if you should expose it.
3. Mount your current directory, "${pwd}", to the `/app` dir of container
4. Mount a docker volume to `/app/vendor/` directory of container
5. Set environment variable `DATABASE_URL` to `postgres://todoapp@<postgres_container_name>/todos`. It is necessary to connect application to postgres database 

## Verification
1. Launch containers with docker-compose. 
2. Check if all applications are up and running. 
3. Check each application's logs to verify there is no error.
4. Execute following command from php app container for schema migration for the database. It prepares tables in the database for the application:
`php artisan migrate`
5. If everything works correctly, application must respond at endpoint: `127.0.0.1:3000/todos` with an empty list as `[]`. To verify it, make a HTTP request to the endpoint with curl command.