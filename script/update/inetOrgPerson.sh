#!/bin/bash
# 사용자 수정 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/update/inetOrgPerson.sh [ID] [부서] [속성] [새값]
# 예시: docker exec -it ldap-server bash /tmp/script/update/inetOrgPerson.sh testid team1 mail newemail@master.com

LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"
CN="${1}"
OU="${2}"
ATTR="${3}"
VALUE="${4}"

if [ -z "$CN" ] || [ -z "$OU" ] || [ -z "$ATTR" ]; then
    echo "사용법: $0 [ID] [부서] [속성] [새값]"
    echo "예시: $0 testid team1 mail newemail@master.com"
    echo "속성: mail, sn, givenName, userPassword 등"
    exit 1
fi

# userPassword 속성인 경우 slappasswd로 해시 처리
if [ "$ATTR" = "userPassword" ]; then
    if [ -z "$VALUE" ]; then
        echo "새 비밀번호를 입력하세요:"
        read -s PASSWORD1
        echo ""
        echo "비밀번호를 다시 입력하세요:"
        read -s PASSWORD2
        echo ""

        if [ "$PASSWORD1" != "$PASSWORD2" ]; then
            echo "오류: 비밀번호가 일치하지 않습니다."
            exit 1
        fi

        if [ -z "$PASSWORD1" ]; then
            echo "오류: 비밀번호가 비어있습니다."
            exit 1
        fi

        VALUE=$(slappasswd -s "$PASSWORD1")
    else
        VALUE=$(slappasswd -s "$VALUE")
    fi
fi

if [ -z "$VALUE" ]; then
    echo "오류: 값이 비어있습니다."
    exit 1
fi

ldapmodify -x -D "$LDAP_ADMIN_DN" -W <<EOF
dn: cn=${CN},ou=${OU},dc=master,dc=com
changetype: modify
replace: ${ATTR}
${ATTR}: ${VALUE}
EOF

if [ $? -eq 0 ]; then
    echo "=== 사용자 '${CN}' 수정 성공 ==="
else
    echo "=== 사용자 '${CN}' 수정 실패 ==="
fi
