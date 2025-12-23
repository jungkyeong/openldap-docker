#!/bin/bash
# 조직(organization) 생성 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/create/organization.sh

# admin 접속 정보
LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"

# ldapadd 명령어
ldapadd -x -D "$LDAP_ADMIN_DN" -W <<EOF
dn: dc=master,dc=com
objectClass: dcObject
objectClass: organization
dc: master
o: Example Company
EOF

# 직전 명령어의 종료값($?)을 확인하여(-eq) 성공, 실패 여부 확인
if [ $? -eq 0 ]; then
    echo "=== 조직 생성 성공 ==="
else
    echo "=== 조직 생성 실패 ==="
fi
