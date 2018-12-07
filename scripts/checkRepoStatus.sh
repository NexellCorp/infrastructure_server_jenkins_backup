#!/bin/bash

dirEmpty="false"
week="86400"

argc=$#
manifest='_none_'

function checkEmpty()
{
    if [ ! -d '.repo' ]; then
        echo "Current Project dir if Empty True"
        dirEmpty="true"
    else
        echo "Current Project dir if Empty False"
        dirEmpty="false"
    fi
}

function usage()
{
    echo "Usage: $0 -p [manifestName]"
    echo ""
    echo "    ex) $0 -m http://git.nexell.co.kr:8081/gerrit/nexell/yocto/manifest"
    echo ""
}

function parse_args()
{
    ARGS=$(getopt -o hm: -- "$@");
    eval set -- "$ARGS";

    while true; do
        case "$1" in
            -m ) manifest="$2"; shift 2 ;;
            -h ) usage; exit 1 ;;
            -- ) break ;;
        esac
    done

    if [ ${manifest} == '_none_' ];then
        usage
        exit 1
    fi
}

function projectDirCleanUp()
{
    if [ ${dirEmpty} == "true" ];then
        repoInitAndSync
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
            repoInitAndSync
        else
            echo "#---------------- repo sync start --------------------#"
            repo forall -c 'git clean -f -d;git checkout -f'
            repo sync
            echo "#---------------- repo sync End ----------------------#"
            echo ""
        fi
    fi
}


function repoInitAndSync()
{
    echo "#---------------- repo init & sync start --------------------#"
    echo "repo init -u ${manifest}"
    echo "--------------------------------------------------------------"
    repo init -u ${manifest}
    repo sync
    echo "#----------------- repo init & sync End ---------------------#"
    echo ""
}

parse_args $@
checkEmpty
projectDirCleanUp
