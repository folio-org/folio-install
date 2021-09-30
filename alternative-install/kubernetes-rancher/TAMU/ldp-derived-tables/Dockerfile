FROM debian:buster-slim

#LDP Derived Tables Prerequisites
RUN apt update -y && apt install -y postgresql-client libcurl4-openssl-dev

#Create folders in container
RUN mkdir -p /usr/local/bin/ldp/sql/derived_tables

#Copy in scripts and files
COPY create-derived-tables.sh /usr/local/bin/ldp
COPY ./sql/derived_tables/* /usr/local/bin/ldp/sql/derived_tables

#Set working directory
WORKDIR /usr/local/bin/ldp

#Set environment variables for script
ENV PG_PASSWORD='ldp_db_password'
ENV PG_ROOT_PASSWORD='postgres_password'
ENV PG_DATABASE='ldp'
ENV PG_USER='ldpadmin'
ENV DB_HOST='pg-ldp'
ENV PG_PRIMARY_PORT='5432'

#Execute the script on container runtime
CMD ["/usr/local/bin/ldp/create-derived-tables.sh"]