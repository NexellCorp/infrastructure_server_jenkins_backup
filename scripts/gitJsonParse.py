# -*- coding: utf-8 -*-
"""
Created on Fri Mar 31 10:10:47 2017
In Jenkins Usage:
  build script :
    python gitJsonParse.py u-boot-2016.01 ${GERRIT_PATCHSET_REVISION}
"""

import subprocess
import sys
import json
import os

"""
--- projectName example ---
 nexell/linux/u-boot/u-boot-2016.01
 nexell/linux/kernel/kernel-4.4.19
 nexell/bl1/bl1-s5p4418
 nexell/bl1/bl1-s5p6818
 jenkins_test/helloworld
"""

_S_ = ' '
_userID = 'nxJenkins@review.gerrithub.io'

# i.e : "ssh -p 29418 jenkins@git.nexell.co.kr gerrit query --format JSON status:open NOT status:DRAFT \
#                  project:nexell/linux/u-boot/u-boot-2016.01 --patch-sets"
gerritQuerySSHCmd = 'ssh -p 29418'
gerritQueryID = _userID
gerritQueryCmd = 'gerrit query'
gerritQueryFormat = 'JSON'
gerritQueryDraftStatus = 'NOT status:DRAFT'
gerritQueryProject = ''
gerritQueryAppendixParam = '--patch-sets'
_gerritQuery = ''

# i.e : git fetch ssh://jenkins@git.nexell.co.kr:29418/nexell/linux/u-boot/u-boot-2016.01 refs/changes/16/2816/1 && git cherry-pick FETCH_HEAD
cherrypickGitFetchCmd = 'git fetch ssh://'
cherrypickGitFetchID = _userID
cherrypickGitFetchPort = '29418'
cherrypickGitFetchProject = ''
cherrypickGitFetchRefs = ''
cherrypickGitFetchCherryParam = '&& git cherry-pick FETCH_HEAD'

_projectInfo = []
_cherrypickInfo = []
_latestPatchsets = []
_indexGroup = []

def makeGerritQueryCmd(projectName,branchName,status):
    global _gerritQuery

    if '_none_'==branchName:
        _gerritQuery = gerritQuerySSHCmd +_S_+\
                       gerritQueryID +_S_+\
                       gerritQueryCmd +_S_+\
                       "--format" +_S_+\
                       gerritQueryFormat +_S_+\
                       "status:"+status +_S_+\
                       gerritQueryDraftStatus +_S_+\
                       "project:"+projectName +_S_+\
                       gerritQueryAppendixParam
    else:
        _gerritQuery = gerritQuerySSHCmd +_S_+\
                       gerritQueryID +_S_+\
                       gerritQueryCmd +_S_+\
                       "--format" +_S_+\
                       gerritQueryFormat +_S_+\
                       "status:"+status +_S_+\
                       gerritQueryDraftStatus +_S_+\
                       "branch:"+branchName +_S_+\
                       "project:"+projectName + _S_+\
                       gerritQueryAppendixParam

    print _gerritQuery

def makeCherryPickCmd(refs, project):
    global cherrypickGitFetchProject
    global cherrypickGitFetchRefs

    cherrypickGitFetchRefs = refs
    cherrypickGitFetchProject = project
    _cherrypickCmd = cherrypickGitFetchCmd + cherrypickGitFetchID + ':' + cherrypickGitFetchPort + '/' + cherrypickGitFetchProject + _S_ + \
                     cherrypickGitFetchRefs + _S_ + cherrypickGitFetchCherryParam
    print "make done cherrypick"
    return _cherrypickCmd

def getLatestPatchset(patchsets):
    number = 0
    latest_index = 0
    index = 0
    for patchset in patchsets :
        temp = int(patchset['number'])
        if number < temp:
            number = temp
            latest_index = index
        index += 1
        
    print "patchset select index = %d, patchsets count = %d, patchset number = %d"%(latest_index,len(patchsets),number)
    return patchsets[latest_index]

def getInfo():
    global _projectInfo

    print "gerritQuery cmd : " +  _gerritQuery
    output=subprocess.check_output(_gerritQuery,shell=True)
    print output
    values = []
    for x in output.split('\n') :
        values.append(x)

    del values[-1]
    del values[-1]

    _projectInfo = [json.loads(y) for y in values]

    for pInfo in _projectInfo:
        _latestPatchsets.append(getLatestPatchset(pInfo['patchSets']))

def debugprint(self) :
    # For debugging
    for i in _latestPatchsets:
        print "----------------------------------------------"
        print "ref : " + i['ref']
        print "revision : " + i['revision']
        for j in i['parents'] :
            print "parents : " + j

def constructCherryPickIndexGroup(revision):
    #Current patchset make cherrypick
    index = searchRevision(revision)
    if index == -1 :
        print "There is no exist revision infomation!"
        return -1

    _indexGroup.append(index)

    parentRevision = _latestPatchsets[index]['parents'][0]
    print " --> %s "%_latestPatchsets[index]['revision'] + " --> parent : " + parentRevision

    constructCherryPickIndexGroup(parentRevision)

def constructCherryPickIndexGroupByRefs(projectName=""):
    setIndexNum()

    for i in _indexGroup :
        print projectName + " commit --> %s "%_latestPatchsets[i]['revision']

def constructCherryPickInfo():
    for index in _indexGroup :
        _cherrypickInfo.append(makeCherryPickCmd(_latestPatchsets[index]['ref'], _projectInfo[index]['project']))
        print _latestPatchsets[index]['ref']

    for i in _cherrypickInfo :
        print i

def searchRevision(revision):
    index = 0
    print "search revision ..."
    for info in _latestPatchsets :
        if info['revision']==revision :
            return index
        else :
            index = index + 1
    return -1

def setIndexNum():
    for i in range(len(_latestPatchsets)) :
        _indexGroup.append(i)

def printInfo(status) :
    print "printInfo : "+status
    if status=='ready' :
        print "==========================================================="
        print " Make CherryPick Info Running..."
        print "===========================================================\n"
    elif status=='cherrypick' :
        print "==========================================================="
        print " Apply CherryPick ..."
        print "===========================================================\n"
    elif status=='not_cherrypick' :
        print "==========================================================="
        print " Have not CherryPick Info..."
        print "===========================================================\n"
    elif status=='end' :
        print "==========================================================="
        print " Success CherryPick..."
        print "===========================================================\n"
    else:
        pass

def doCherryPick() :
    for cmd in _cherrypickInfo[::-1] :
        os.system(cmd)

def main(args):
    print "json parse start"
    projectName=args[0]
    commitID=args[1]
    branchName=args[2]
    status=args[3]
    printInfo('ready')
    makeGerritQueryCmd(projectName,branchName,status)
    getInfo()
    if commitID=='_none_' :
        constructCherryPickIndexGroupByRefs(projectName)
    else :
        constructCherryPickIndexGroup(commitID)

    constructCherryPickInfo()
    if len(_cherrypickInfo) > 0:
        printInfo('cherrypick')
    else:
        printInfo('not_cherrypick')
    doCherryPick()
    printInfo('end')

if __name__ == "__main__":
    try :
        main(sys.argv[1:])
    finally :
        pass
