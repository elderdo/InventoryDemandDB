s/^ *\([a-zA-Z][a-zA-Z0-9_]*\)()/function \1/
s/uname -n/hostname -s/
s/JRE=.* *$/JRE=\/usr\/java\/jdk1.7.0_72\/jre/
s/ORACLE_HOME=.* *$/ORACLE_HOME=\/opt\/oracle\/app\/oracle\/product\/12.1.0\/client_1/
