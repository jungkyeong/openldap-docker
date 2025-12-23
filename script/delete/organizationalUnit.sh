#!/bin/bash
# 부서 삭제 스크립트 (하위 사용자 포함)
# 사용법: docker exec -it ldap-server bash /tmp/script/delete/organizationalUnit.sh [부서명]
# 예시: docker exec -it ldap-server bash /tmp/script/delete/organizationalUnit.sh team1

LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"
OU_NAME="${1}"

if [ -z "$OU_NAME" ]; then
    echo "사용법: $0 [부서명]"
    echo "예시: $0 team1"
    exit 1
fi

echo "=== 부서 '${OU_NAME}' 및 하위 사용자 삭제 ==="

# 하위 사용자 수 조회
USER_COUNT=$(ldapsearch -x -b "ou=${OU_NAME},dc=master,dc=com" -LLL "(objectClass=inetOrgPerson)" dn | grep -c "^dn:")

if [ "$USER_COUNT" -gt 0 ]; then
    echo "하위 사용자 ${USER_COUNT}명 발견"
    read -p "부서와 모든 하위 사용자를 삭제하시겠습니까? (y/N): " CONFIRM

    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo "취소되었습니다."
        exit 0
    fi
fi

# -r: 하위 항목 모두 삭제 (recursive)
ldapdelete -x -D "$LDAP_ADMIN_DN" -W -r "ou=${OU_NAME},dc=master,dc=com"

if [ $? -eq 0 ]; then
    echo "=== 부서 '${OU_NAME}' 삭제 성공 ==="
else
    echo "=== 부서 '${OU_NAME}' 삭제 실패 ==="
fi
