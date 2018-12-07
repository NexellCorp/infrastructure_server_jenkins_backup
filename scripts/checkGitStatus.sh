#!/bin/bash

dirEmpty="false"
week="86400"

argc=$#
projectName='_none_'
branchName='_none_'
#gerrit='http://git.nexell.co.kr:8081/gerrit'
gerrit='https://review.gerrithub.io'

function checkEmpty()
{
    if [ ! -d '.git' ]; then
        echo "Current Project dir if Empty True"
        dirEmpty="true"
    else
        echo "Current Project dir if Empty False"
        dirEmpty="false"
    fi
}

function usage()
{
    echo "Usage: $0 -p [projectName] -b [branch name]"
    echo ""
    echo "    ex) $0 -p nexell/linux/kernel/kernel-4.4.19 -b nexell"
    echo "    ex) $0 -p nexell/linux/u-boot/u-boot-2016.01 -b master"
    echo ""
}

function parse_args()
{
    ARGS=$(getopt -o hp:b: -- "$@");
    eval set -- "$ARGS";

    while true; do
        case "$1" in
            -p ) projectName="$2"; shift 2 ;;
            -b ) branchName="$2"; shift 2 ;;
            -h ) usage; exit 1 ;;
            -- ) break ;;
        esac
    done

    if [ ${projectName} == '_none_' -o  ${branchName} == '_none_' ];then
        usage
        exit 1
    fi
}

function projectDirCleanUp()
{
    if [ ${dirEmpty} == "true" ];then
        gitClone
    else
        local timeDirY=`stat --format=%Y ./ `
        local curTime=`date +"%s"`
        local diffTime=$((curTime - timeDirY))

        echo "Dir make Time : $timeDirY"
        echo "Now Time is : $curTime"
        echo "Diff Time is : $diffTime"

        if [ $diffTime -gt $week ]; then
            rm -rf *
            rm -rf .*
            gitClone
        else
            echo "#---------------- git pull start --------------------#"
            git clean -f -d
            git checkout -f
            git pull origin ${branchName}
            echo "#---------------- git pull End ----------------------#"
            echo ""
        fi
    fi
}

function gitClone()
{
    echo "#---------------- git Clone start --------------------#"
    echo "git clone -b ${branchName} ${gerrit}/${projectName} ./"
    git clone --depth=50 -b ${branchName} ${gerrit}/${projectName} ./
    echo "#----------------  git Clone End ---------------------#"
    echo ""
}

parse_args $@
checkEmpty
projectDirCleanUp
