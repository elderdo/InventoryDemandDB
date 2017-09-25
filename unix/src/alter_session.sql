set timing on
set time on
-- this alter session command fixes ora-02085 db link errors
-- see (http://stackoverflow.com/questions/9988954/ora-02085-database-link-dblink-name-connects-to-oracle)

alter session set global_names=false;
