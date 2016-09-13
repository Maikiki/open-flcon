#!/bin/bash

# exit 10  =>  路径错误
# exit 15  =>  参数错误
# exit 16  =>  组件启动脚本不存在
# exit 20  =>  启动失败

ServerModule=(transfer query portal hbs graph fe dashboard aggregator)
AgentModule=(agent)

FALCON_HOME=$(cd $(dirname ${0})>/dev/null;pwd)

Usage(){
    echo """

        ${0} ${ServerModule[$(($RANDOM%${#ServerModule[@]}))]} start|stop|status|restart

        Use like this:
            ${0} ${ServerModule[$(($RANDOM%${#ServerModule[@]}))]} start       #<= this will be start service.
            ${0} ${ServerModule[$(($RANDOM%${#ServerModule[@]}))]} stop        #<= this will be stop service.
            ${0} ${ServerModule[$(($RANDOM%${#ServerModule[@]}))]} restart     #<= this will be restart service.
            ${0} ${ServerModule[$(($RANDOM%${#ServerModule[@]}))]} status      #<= this will be check service status.

        ModuleName:
            ${ServerModule[*]} ${AgentModule[*]}

    """
    exit 15
}

FalconCMD(){

    local service=$1
    local opt=$2

    if [[ -e "${FALCON_HOME}/${service}/control" ]]; then
        cd ${FALCON_HOME}/${service} || exit 10
        bash control ${opt}
        if [[ "${?}" != "0" ]];then
            exit 20
        fi
    else
        echo "${FALCON_HOME}/${service}/control not exist "
        exit 16
    fi
}

FalconOPT(){

    local service=$1
    local opt=$2

    if [[ "${service}" == "server" ]];then
        for i in ${ServerModule[*]}; do
            FalconCMD ${i} ${opt}
        done
    else
        FalconCMD ${service} ${opt}
    fi
}



if [[ "${#}" == "2" ]]; then
    case ${2} in
        start ) FalconOPT ${1} ${2} ;;
        stop ) FalconOPT ${1} ${2} ;;
        restart ) FalconOPT ${1} ${2} ;;
        status ) FalconOPT ${1} ${2} ;;
        * )  Usage ;;
    esac
else
    Usage
fi