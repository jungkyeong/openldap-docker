#!/bin/bash
# 부서 조회 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/read/organizationalUnit.sh [부서명(선택)]
# 예시: docker exec -it ldap-server bash /tmp/script/read/organizationalUnit.sh team1

OU_NAME="${1}"

if [ -z "$OU_NAME" ]; then
    # 전체 부서 조회
    ldapsearch -x -b "dc=master,dc=com" "(objectClass=organizationalUnit)"
else
    # 특정 부서 조회
    ldapsearch -x -b "ou=${OU_NAME},dc=master,dc=com"
fi
