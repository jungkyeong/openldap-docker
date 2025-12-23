#!/bin/bash
# 사용자(inetOrgPerson) 생성 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/create/inetOrgPerson.sh [ID] [이름] [성] [부서] [이메일(선택)] [비밀번호설정여부(선택)]
# 예시: docker exec -it ldap-server bash /tmp/script/create/inetOrgPerson.sh testid Alice Martinez team1 alice@master.com true

# 입력값 get
LDAP_ADMIN_DN="cn=admin,dc=master,dc=com"
CN="${1}"
GIVEN_NAME="${2}"
SN="${3}"
OU="${4}"
MAIL="${5}"
SET_PASSWORD="${6}"

# cmd 입력값 확인
if [ -z "$CN" ] || [ -z "$GIVEN_NAME" ] || [ -z "$SN" ] || [ -z "$OU" ]; then
    echo "사용법: $0 [ID] [이름] [성] [부서] [이메일(선택)] [비밀번호설정여부(선택)]"
    echo "예시: $0 testid Alice Martinez team1 alice@master.com true"
    exit 1
fi

# 이름(givenName) 설정
GIVEN_NAME_LINE="givenName: ${GIVEN_NAME}"

# 메일 설정 확인 (선택 사항으로 없으면 빈 문자열 출력)
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

    # slappasswd를 사용한 SSHA 해시 생성
    HASHED_PASSWORD=$(slappasswd -s "$PASSWORD1")
    PASSWORD_LINE="userPassword: ${HASHED_PASSWORD}"
fi

# ldapadd 명령어
# -W: 비밀번호 입력 받기
# -D 계정 접속 정보(admin)
# -x: 일반 비밀번호 인증
ldapadd -x -D "$LDAP_ADMIN_DN" -W <<EOF
dn: cn=${CN},ou=${OU},dc=master,dc=com
objectClass: inetOrgPerson
cn: ${CN}
${GIVEN_NAME_LINE}
sn: ${SN}
${MAIL_LINE}
${PASSWORD_LINE}
EOF

# 직전 명령어의 종료값($?)을 확인하여(-eq) 성공, 실패 여부 확인
if [ $? -eq 0 ]; then
    echo "=== 사용자 '${CN}' 생성 성공 ==="
else
    echo "=== 사용자 '${CN}' 생성 실패 ==="
fi
