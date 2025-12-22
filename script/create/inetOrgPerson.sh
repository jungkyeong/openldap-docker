#!/bin/bash
# 사용자(inetOrgPerson) 생성 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/create/inetOrgPerson.sh [이름] [성] [부서] [이메일(선택)] [비밀번호설정여부(선택)]
# 예시: docker exec -it ldap-server bash /tmp/script/create/inetOrgPerson.sh Alice Martinez team1 alice@master.com true

LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"
CN="${1}"
SN="${2}"
OU="${3}"
MAIL="${4}"
SET_PASSWORD="${5}"

if [ -z "$CN" ] || [ -z "$SN" ] || [ -z "$OU" ]; then
    echo "사용법: $0 [이름] [성] [부서] [이메일(선택)] [비밀번호설정여부(선택)]"
    echo "예시: $0 Alice Martinez team1 alice@master.com true"
    exit 1
fi

if [ -n "$MAIL" ]; then
    MAIL_LINE="mail: ${MAIL}"
else
    MAIL_LINE=""
fi

# 비밀번호 설정 (true인 경우)
PASSWORD_LINE=""
if [ "$SET_PASSWORD" = "true" ]; then
    echo "사용자 비밀번호를 입력하세요:"
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

    PASSWORD_LINE="userPassword: ${PASSWORD1}"
fi

ldapadd -x -D "$LDAP_ADMIN_DN" -W <<EOF
dn: cn=${CN},ou=${OU},dc=master,dc=com
objectClass: inetOrgPerson
cn: ${CN}
sn: ${SN}
${MAIL_LINE}
${PASSWORD_LINE}
EOF

if [ $? -eq 0 ]; then
    echo "=== 사용자 '${CN}' 생성 성공 ==="
else
    echo "=== 사용자 '${CN}' 생성 실패 ==="
fi
