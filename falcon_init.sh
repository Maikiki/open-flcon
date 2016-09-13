#!/bin/bash

ID_HOME=$(cd $(dirname ${0})>/dev/null;pwd)
RUN_HOME=${ID_HOME%/*}

openfalcon_home='/opt/idagent/services/open-falcon'
rpm_path="${openfalcon_home}/source/rpm"
db_path="${openfalcon_home}/source/db"
packages_dash_path="${openfalcon_home}/source/dashboard_packages"
packages_portal_path="${openfalcon_home}/source/portal_packages"
dashboard_path="${openfalcon_home}/dashboard"
portal_path="${openfalcon_home}/portal"
lib64_path="/usr/lib64/libmysqlclient.so.18"
ip_addr=$(/sbin/ifconfig|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p' | grep -v '127')



Usage(){
    echo """
        ${0} student|class|statistic start|stop|status

        congfig:
            plz edit conf/worker.conf before use ${0} .

    """
}

LOG_SUCCESS_MSG(){ 
    echo -e "\033[32m--> SUCCESS! \033[0m $@" 
}


LOG_FAILURE_MSG(){ 
    echo -e "\033[31m--> ERROR! \033[0m $@"
    exit 1
}

MYSQL_CHECK(){
    # local cmd=${*}
    # for i in ${cmd}; do
    $(type mysql 2>&1 > /dev/null) || LOG_FAILURE_MSG "cmd not found: mysql"
    $(type mysql_config 2>&1 > /dev/null) || LOG_FAILURE_MSG "cmd not found: mysql_config"
    mysql -uroot -e "show databases;" || LOG_FAILURE_MSG "mysql error"
    # done
}

RPM_INSTALL(){
  #  if [[ -d ${rpm_path} ]];then
  #	     for i in $(ls ${rpm_path}/*); do
  #           a=$(echo ${i#*rpm/}|sed 's/-[0-9].*//')
  #           if [[ -z 'rpm -qa ${a}' ]]; then
	              rpm -Uvh ${rpm_path}/* 2>&1 > /dev/null
  #           fi
  #      done
	     LOG_SUCCESS_MSG 'rpm install done'
  #  else
  #      LOG_FAILURE_MSG "error path: ${rpm_path}"
  #  fi
}

PYTHON_EVN_INSTALL(){
    $(type virtualenv 2>&1 > /dev/null) || LOG_FAILURE_MSG "cmd not found: virtualenv"
    if [[ ! -d ${lib64_path} ]]; then
        ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
    fi
    if [[ ! -d ${dashboard_path} ]]; then
        LOG_FAILURE_MSG "error path: ${dashboard_path}"
    else
        virtualenv "${dashboard_path}/env"
        if [[ ! -d ${packages_dash_path} ]]; then
            LOG_FAILURE_MSG "error path: ${packages_dash_path}"
        else
            cd ${dashboard_path}
            ./env/bin/pip install --no-index --find-links="${packages_dash_path}/" -r pip_requirements.txt 2>&1 > /dev/null
            cd -
            LOG_SUCCESS_MSG 'dashboard_python_env done'
        fi
    fi

    if [[ ! -d ${portal_path} ]]; then
        LOG_FAILURE_MSG "error path: ${portal_path}"
    else    
        virtualenv "${portal_path}/env"
        if [[ ! -d ${packages_portal_path} ]]; then
            LOG_FAILURE_MSG "error path: ${packages_portal_path}"
        else
            cd ${portal_path}
            ./env/bin/pip install --no-index --find-links="${packages_portal_path}/" -r pip_requirements.txt 2>&1 > /dev/null
            cd -
            LOG_SUCCESS_MSG 'portal_python_env done'
        fi
    fi   
}

DB_IMPORT(){
    agent_home=$(cd $(dirname ${0})>/dev/null;cd ../../;pwd)

    #. ${agent_home}/conf/agent-env.sh

    for sql in $(ls ${db_path}/*.sql); do
      mysql -uroot < ${sql}
    done

}

MODIFY_CONF(){
    sed -i "s/\"ip\":.*/\"ip\":\"${ip_addr}\",/g" ${openfalcon_home}/agent/cfg.json

}


init_main(){
    MYSQL_CHECK
    RPM_INSTALL
    PYTHON_EVN_INSTALL
    DB_IMPORT
   # MODIFY_CONF
}



case ${1} in
    init ) init_main ;;
    * )  Usage ;;
esac
