#!/bin/bash
# 사용자 수정 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/update/inetOrgPerson.sh [ID] [부서] [속성] [새값]
# 예시: docker exec -it ldap-server bash /tmp/script/update/inetOrgPerson.sh testid team1 mail newemail@master.com

LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"
CN="${1}"
OU="${2}"
ATTR="${3}"
VALUE="${4}"

if [ -z "$CN" ] || [ -z "$OU" ] || [ -z "$ATTR" ] || [ -z "$VALUE" ]; then
    echo "사용법: $0 [ID] [부서] [속성] [새값]"
    echo "예시: $0 testid team1 mail newemail@master.com"
    echo "속성: mail, sn, givenName 등"
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
