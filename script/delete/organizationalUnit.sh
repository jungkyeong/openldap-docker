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

# 하위 사용자 목록 조회
USERS=$(ldapsearch -x -b "ou=${OU_NAME},dc=master,dc=com" -LLL "(objectClass=inetOrgPerson)" dn | grep "^dn:" | sed 's/dn: //')

if [ -n "$USERS" ]; then
    echo "하위 사용자 발견:"
    echo "$USERS"
    echo ""
    read -p "모든 하위 사용자를 삭제하시겠습니까? (y/N): " CONFIRM

    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo "취소되었습니다."
        exit 0
    fi

    echo "비밀번호를 입력하세요:"
    read -s LDAP_PASSWORD
    echo ""

    # 하위 사용자 삭제
    for USER_DN in $USERS; do
        echo "삭제 중: ${USER_DN}"
        ldapdelete -x -D "$LDAP_ADMIN_DN" -w "$LDAP_PASSWORD" "$USER_DN"
    done

    # 부서 삭제
    ldapdelete -x -D "$LDAP_ADMIN_DN" -w "$LDAP_PASSWORD" "ou=${OU_NAME},dc=master,dc=com"
else
    # 하위 사용자 없으면 바로 삭제
    ldapdelete -x -D "$LDAP_ADMIN_DN" -W "ou=${OU_NAME},dc=master,dc=com"
fi

if [ $? -eq 0 ]; then
    echo "=== 부서 '${OU_NAME}' 삭제 성공 ==="
else
    echo "=== 부서 '${OU_NAME}' 삭제 실패 ==="
fi
