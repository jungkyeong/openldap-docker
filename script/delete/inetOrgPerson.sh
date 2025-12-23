#!/bin/bash
# 사용자 삭제 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/delete/inetOrgPerson.sh [ID] [부서]
# 예시: docker exec -it ldap-server bash /tmp/script/delete/inetOrgPerson.sh testid team1

LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"
CN="${1}"
OU="${2}"

if [ -z "$CN" ] || [ -z "$OU" ]; then
    echo "사용법: $0 [ID] [부서]"
    echo "예시: $0 Alice team1"
    exit 1
fi

ldapdelete -x -D "$LDAP_ADMIN_DN" -W "cn=${CN},ou=${OU},dc=master,dc=com"

if [ $? -eq 0 ]; then
    echo "=== 사용자 '${CN}' 삭제 성공 ==="
else
    echo "=== 사용자 '${CN}' 삭제 실패 ==="
fi
