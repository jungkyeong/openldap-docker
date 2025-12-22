#!/bin/bash
# 조직(organization) 생성 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/create/organization.sh

# admin 접속 정보
LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"

# 생성 요청
# -W: 비밀번호 입력 받기
ldapadd -x -D "$LDAP_ADMIN_DN" -W <<EOF
dn: dc=master,dc=com
objectClass: dcObject
objectClass: organization
dc: master
o: Example Company
EOF

if [ $? -eq 0 ]; then
    echo "=== 조직 생성 성공 ==="
else
    echo "=== 조직 생성 실패 ==="
fi
