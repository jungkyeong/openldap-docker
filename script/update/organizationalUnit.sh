#!/bin/bash
# 부서 이동 스크립트 - 하위 사용자 포함
# 사용법: docker exec -it ldap-server bash /tmp/script/update/organizationalUnit.sh [기존부서] [새부서]
# 예시: docker exec -it ldap-server bash /tmp/script/update/organizationalUnit.sh team1 team1-new

LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"
OLD_OU="${1}"
NEW_OU="${2}"

if [ -z "$OLD_OU" ] || [ -z "$NEW_OU" ]; then
    echo "사용법: $0 [기존부서] [새부서]"
    echo "예시: $0 team1 team1-new"
    exit 1
fi

echo "=== 부서 '${OLD_OU}' → '${NEW_OU}' 이동 ==="

# 새 부서가 이미 존재하는지 확인
EXISTS=$(ldapsearch -x -b "dc=master,dc=com" "(ou=${NEW_OU})" dn | grep "^dn:")
if [ -n "$EXISTS" ]; then
    echo "오류: 부서 '${NEW_OU}'가 이미 존재합니다."
    exit 1
fi

# 하위 사용자 목록 조회
USERS=$(ldapsearch -x -b "ou=${OLD_OU},dc=master,dc=com" -LLL "(objectClass=inetOrgPerson)" dn cn givenName sn mail userPassword | grep -E "^(dn:|cn:|givenName:|sn:|mail:|userPassword:)")

echo "admin 비밀번호를 입력하세요:"
read -s LDAP_PASSWORD
echo ""

# 1. 새 부서 생성
echo "새 부서 '${NEW_OU}' 생성 중..."
ldapadd -x -D "$LDAP_ADMIN_DN" -w "$LDAP_PASSWORD" <<EOF
dn: ou=${NEW_OU},dc=master,dc=com
objectClass: organizationalUnit
ou: ${NEW_OU}
EOF

if [ $? -ne 0 ]; then
    echo "=== 새 부서 생성 실패 ==="
    exit 1
fi

# 2. 사용자 이동 (새 부서로 복사 후 기존 삭제)
USER_LIST=$(ldapsearch -x -b "ou=${OLD_OU},dc=master,dc=com" -LLL "(objectClass=inetOrgPerson)" dn | grep "^dn:" | sed 's/dn: //')

for USER_DN in $USER_LIST; do
    # 사용자 정보 추출 (admin 권한으로 조회 - userPassword 포함)
    CN=$(echo "$USER_DN" | sed 's/cn=\([^,]*\).*/\1/')
    USER_INFO=$(ldapsearch -x -D "$LDAP_ADMIN_DN" -w "$LDAP_PASSWORD" -b "$USER_DN" -LLL)
    GIVEN_NAME=$(echo "$USER_INFO" | grep "^givenName:" | sed 's/givenName: //')
    SN=$(echo "$USER_INFO" | grep "^sn:" | sed 's/sn: //')
    MAIL=$(echo "$USER_INFO" | grep "^mail:" | sed 's/mail: //')
    PASSWORD=$(echo "$USER_INFO" | grep "^userPassword:" | sed 's/userPassword: //')

    echo "이동 중: ${CN}"

    # 새 부서에 사용자 생성
    GIVEN_NAME_LINE=""
    MAIL_LINE=""
    PASSWORD_LINE=""

    if [ -n "$GIVEN_NAME" ]; then
        GIVEN_NAME_LINE="givenName: ${GIVEN_NAME}"
    fi
    if [ -n "$MAIL" ]; then
        MAIL_LINE="mail: ${MAIL}"
    fi
    if [ -n "$PASSWORD" ]; then
        PASSWORD_LINE="userPassword: ${PASSWORD}"
    fi

    ldapadd -x -D "$LDAP_ADMIN_DN" -w "$LDAP_PASSWORD" <<EOF
dn: cn=${CN},ou=${NEW_OU},dc=master,dc=com
objectClass: inetOrgPerson
cn: ${CN}
sn: ${SN}
${GIVEN_NAME_LINE}
${MAIL_LINE}
${PASSWORD_LINE}
EOF

    # 기존 사용자 삭제
    ldapdelete -x -D "$LDAP_ADMIN_DN" -w "$LDAP_PASSWORD" "$USER_DN"
done

# 3. 기존 부서 삭제
echo "기존 부서 '${OLD_OU}' 삭제 중..."
ldapdelete -x -D "$LDAP_ADMIN_DN" -w "$LDAP_PASSWORD" "ou=${OLD_OU},dc=master,dc=com"

if [ $? -eq 0 ]; then
    echo "=== 부서 이동 완료: '${OLD_OU}' → '${NEW_OU}' ==="
else
    echo "=== 부서 이동 실패 ==="
fi
