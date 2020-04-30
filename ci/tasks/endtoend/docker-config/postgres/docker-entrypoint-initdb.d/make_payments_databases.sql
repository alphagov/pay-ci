CREATE EXTENSION "uuid-ossp";


CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA pg_catalog;

CREATE USER connector WITH password 'mysecretpassword';
CREATE DATABASE connector WITH owner=connector TEMPLATE postgres;
GRANT ALL PRIVILEGES ON DATABASE connector TO connector;

CREATE USER publicauth WITH password 'mysecretpassword';
CREATE DATABASE publicauth WITH owner=publicauth TEMPLATE postgres;
GRANT ALL PRIVILEGES ON DATABASE publicauth TO publicauth;

CREATE USER adminusers WITH password 'mysecretpassword';
CREATE DATABASE adminusers WITH owner=adminusers TEMPLATE postgres;
GRANT ALL PRIVILEGES ON DATABASE adminusers TO adminusers;

CREATE USER products WITH password 'mysecretpassword';
CREATE DATABASE products WITH owner=products TEMPLATE postgres;
GRANT ALL PRIVILEGES ON DATABASE products TO products;

CREATE USER directdebit_connector WITH password 'mysecretpassword';
CREATE DATABASE directdebit_connector WITH owner=directdebit_connector TEMPLATE postgres;
GRANT ALL PRIVILEGES ON DATABASE directdebit_connector TO directdebit_connector;

CREATE USER ledger WITH password 'mysecretpassword';
CREATE DATABASE ledger WITH owner=ledger TEMPLATE postgres;
GRANT ALL PRIVILEGES ON DATABASE ledger TO ledger;

