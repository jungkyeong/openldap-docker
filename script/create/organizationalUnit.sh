#!/bin/bash
# 부서(organizationalUnit) 생성 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/create/organizationalUnit.sh [부서명]
# 예시: docker exec -it ldap-server bash /tmp/script/create/organizationalUnit.sh team1

LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"
OU_NAME="${1}"

if [ -z "$OU_NAME" ]; then
    echo "사용법: $0 [부서명]"
    echo "예시: $0 team1"
    exit 1
fi

ldapadd -x -D "$LDAP_ADMIN_DN" -W <<EOF
dn: ou=${OU_NAME},dc=master,dc=com
objectClass: organizationalUnit
ou: ${OU_NAME}
EOF

if [ $? -eq 0 ]; then
    echo "=== 부서 '${OU_NAME}' 생성 성공 ==="
else
    echo "=== 부서 '${OU_NAME}' 생성 실패 ==="
fi
