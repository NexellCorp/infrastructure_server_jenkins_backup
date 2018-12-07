#!/bin/bash

set -e

CURRENT_PATH=`dirname $0`
argc=$#
projectName='_none_'
commitID='_none_'
branchName='_none_'
status='open'

function check_usage()
{
    if [ $argc -lt 2 ]; then
        echo "Invalid argument check usage please"
        usage
        exit
    fi
}

function usage()
{
    echo "Usage: $0 -p [projectName] -b [branch name] -c [commit id] -s <status>"
    echo ""
    echo "    ex) $0 -p nexell/linux/kernel/kernel-4.4.19 -b nexell"
    echo "    ex) $0 -p nexell/linux/u-boot/u-boot-2016.01 -b master -c 123456789012345678 -s open"
    echo "    ex) $0 -p nexell/bl1/bl1-s5p4418 -c 123456789012345678 -s Merged"
    echo ""
    echo "    ## status default variable is 'open' "
    echo ""
}

function parse_args()
{
echo $commitID

    ARGS=$(getopt -o hc:p:b:s: -- "$@");
    eval set -- "$ARGS";

    while true; do
        case "$1" in
            -c ) commitID="$2"; shift 2 ;;
            -p ) projectName="$2"; shift 2 ;;
            -b ) branchName="$2"; shift 2 ;;
            -s ) status="$2"; shift 2 ;;
            -h ) usage; exit 1 ;;
            -- ) break ;;
        esac
    done

    if [ ${projectName} == '_none_' ];then
        usage
        exit 1
    fi
}

function getPatchSet()
{
    echo "projectName : ${projectName}"
    echo "commitID    : ${commitID}"
    echo "branchName  : ${branchName}"
    echo "status      : ${status}"
    python ${CURRENT_PATH}/gitJsonParse.py ${projectName} ${commitID} ${branchName} ${status}
}

check_usage
parse_args $@
getPatchSet
