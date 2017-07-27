*** Settings ***
Documentation    Testing branches and commits
Resource        ../resources.robot

*** Test Cases ***

GetCommitHistoryFromPAOnMasterC0
	[Documentation]		"check get element using commit 0 on master"
	[Tags]				C1
	${result} =			Get		url=${ROOT}/projects/PA/refs/master/elements/test_history_element?commitId=${commit0}		headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	${filter} =			Create List	 _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =		Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetCommitHistoryFromPAOnMasterC2
	[Documentation]		"get element using commit 2 on master"
	[Tags]				C2
	${result} =			Get		url=${ROOT}/projects/PA/refs/master/elements/test_history_element?commitId=${commit2}		headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	${filter} =			Create List	 _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =		Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetCommitHistoryFromPAOnNewBranchC0
	[Documentation]		"get element using commit 0 on new branch"
	[Tags]				C3
	${result} =			Get		url=${ROOT}/projects/PA/refs/newbranch/elements/test_history_element?commitId=${commit0}		headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	${filter} =			Create List	 _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =		Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetCommitHistoryFromPAOnNewBranchC3
	[Documentation]		"get element using commit 3 on new branch"
	[Tags]				C4
	${result} =			Get		url=${ROOT}/projects/PA/refs/newbranch/elements/test_history_element?commitId=${commit3}		headers=&{REQ_HEADER}
	Should Be Equal		${result.status_code}		${200}
	${filter} =			Create List	 _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =		Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetElementAtCommit
    [Documentation]     "Gets an element at a commit -- Should return element"
    [Tags]              C5
    ${element} =        Get    url=${ROOT}/projects/PA/refs/master/elements/300         headers=&{REQ_HEADER}
    ${commitId} =       Get Commit From Json       ${element.json()}
    ${result} =         Get     url=${ROOT}/projects/PA/refs/master/elements/300?commitId=${commitId}       headers=&{REQ_HEADER}
    Should Be Equal     ${result.status_code}       ${200}
    Should Be Equal     ${result.json()["elements"][0]["id"]}       ${element.json()["elements"][0]["id"]}
    Should Be Equal     ${result.json()["elements"][0]["_commitId"]}       ${element.json()["elements"][0]["_commitId"]}
    Should Be Equal     ${result.json()["elements"][0]["_modified"]}       ${element.json()["elements"][0]["_modified"]}

GetElementBeforeCommit
    [Documentation]     "Gets an element that exists before the commit. Grabs a commit that does not contain the element and requests for the element at that time. It should return the element at a previous commit than the one requested."
    [Tags]              C6
    ${element} =        Get    url=${ROOT}/projects/PA/refs/master/elements/300         headers=&{REQ_HEADER}
	${post_json} =		Get File	    ${CURDIR}/../../JsonData/UpdateElementToGetElementBeforeCommit.json
    ${result} =         Post    url=${ROOT}/projects/PA/refs/master/elements      data=${post_json}           headers=&{REQ_HEADER}
    Sleep               2s
    ${commitId} =       Set Variable        ${result.json()["elements"][0]["_commitId"]}
    ${result} =         Get     url=${ROOT}/projects/PA/refs/master/elements/300?commitId=${commitId}       headers=&{REQ_HEADER}
    Should Be Equal     ${result.status_code}       ${200}
    # Tests to see that the element is infact the element at a different point, also verifies that the element is not the same element at the commit
    Should Be Equal     ${result.json()["elements"][0]["_commitId"]}        ${element.json()["elements"][0]["_commitId"]}
	${filter} =			Create List     _commitId		nodeRefId		 versionedRefId		 _created		 read		 lastModified		 _modified		 siteCharacterizationId		 time_total		 _elasticId		 _timestamp		 _inRefIds		 id
	Generate JSON		${TEST_NAME}		${result.json()}		${filter}
	${compare_result} =		Compare JSON		${TEST_NAME}
	Should Match Baseline		${compare_result}

GetElementAfterCommit
    [Documentation]     "Get an element that doesn't exist at the current commit. Should return a 404"
    [Tags]              C7
	${post_json} =		Get File	    ${CURDIR}/../../JsonData/CreateElementAfterCommit.json
	${result} =			Post		    url=${ROOT}/projects/PA/refs/master/elements     data=${post_json}		headers=&{REQ_HEADER}
	Sleep				${2}
	# Grab an element with an older commitId
    ${element} =        Get    url=${ROOT}/projects/PA/refs/master/elements/300         headers=&{REQ_HEADER}
    ${result} =         Get     url=${ROOT}/projects/PA/refs/master/elements/ElementAfterCommit?commitId=${element.json()["elements"][0]["_commitId"]}       headers=&{REQ_HEADER}
    Should be Equal     ${result.status_code}       ${404}

GetElementAtInvalidCommit
    [Documentation]     "Try to get an element at an invalid commit."
    [Tags]              C8
    ${result} =         Get    url=${ROOT}/projects/PA/refs/master/elements/300?commitId=ThisIdShouldNotExistAtAll         headers=&{REQ_HEADER}
    Should be Equal     ${result.status_code}       ${404}

BranchFromBranchAndCheckCommits
    [Documentation]         "Create branch1, create branch 2 immediately from branch 1, getting branch history from branch 1 and branch 2 should be the same."
    [Tags]                  C9
    ${post_json} =		    Get File	    ${CURDIR}/../../JsonData/PostBranch1FromMaster.json
    ${branch_1_json} =		Post		url=${ROOT}/projects/PA/refs		data=${post_json}		headers=&{REQ_HEADER}
    Should Be Equal		    ${branch_1_json.status_code}		${200}
    ${post_json} =          Get File        ${CURDIR}/../../JsonData/PostBranch2FromBranch1.json
    ${branch_2_json} =		Post		url=${ROOT}/projects/PA/refs		data=${post_json}		headers=&{REQ_HEADER}
    Should Be Equal		    ${branch_2_json.status_code}		${200}
    ${branch_1_json} =      Get         url=${ROOT}/projects/PA/refs/pa_branch_1/history
    ${branch_2_json} =      Get         url=${ROOT}/projects/PA/refs/pa_branch_2/history
	${result} =             Compare Json To Json        ${branch_2_json.json()}         ${branch_1_json.json()}
	Should be true          ${result}
