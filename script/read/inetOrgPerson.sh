#!/bin/bash
# 사용자 조회 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/read/inetOrgPerson.sh [이름(선택)]
# 예시: docker exec -it ldap-server bash /tmp/script/read/inetOrgPerson.sh Alice

CN="${1}"

if [ -z "$CN" ]; then
    # 전체 사용자 조회
    ldapsearch -x -b "dc=master,dc=com" "(objectClass=inetOrgPerson)"
else
    # 특정 사용자 조회
    ldapsearch -x -b "dc=master,dc=com" "(cn=${CN})"
fi
