# ========== 사용법  ========== # 
## Powershell 해당 Dockerfile 위치에서
# # 이미지 빌드
# docker build -t openldap-test .
# 
# # 실행
# docker run -d -p 389:389 --name ldap-server openldap-test
# 
# # ID 조회 후 중지
# docker ps 후 
# docker stop [CONTAINER ID]
# 
# # 컨테이터 삭제
# docker rm [CONTAINER ID]

# # 컨테이너 접속
# docker exec -it ldap-server /bin/bash
# # 종료
# exit

# # LDAP 검색
#ldapsearch -x -b "dc=master,dc=com"

# # 항목 추가
#ldapadd -x -D "cn=admin,dc=master,dc=com" -W -f upload.ldif

# #  항목 수정
# ldapmodify -x -D "cn=admin,dc=master,dc=com" -W -f modify.ldif

# # 항목 삭제
# ldapdelete -x -D "cn=admin,dc=master,dc=com" -W "cn=alice,ou=team1,dc=master,dc=com"
# =========================== #

# Ubuntu 22.04 OS 환경
FROM ubuntu:22.04

# 패키지 설치 시 사용자 입력을 요구하지 않도록 요구
ENV DEBIAN_FRONTEND=noninteractive

# LDAP 관리자 및 설정 비밀번호 환경 변수
# 초기 생성할 루트 DN
ENV LDAP_ADMIN_PASSWORD=admin123
ENV LDAP_DOMAIN=master.com
ENV LDAP_ORGANIZATION="My Organization"


# 패키지 업데이트 및 기본 설치 후, 캐시 clean
# slapd: LDAP 서버
# ldap-utils: LDAP용 클라이언트 도구
# vim 에디터
RUN apt-get update && apt-get install -y \
    slapd \
    ldap-utils \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# OpenLDAP 사전 설정 (debconf: 설치 시 질문 미리 답변 등록)
# admin passwird 설정
RUN echo "slapd slapd/internal/generated_adminpw password ${LDAP_ADMIN_PASSWORD}" | debconf-set-selections && \
    echo "slapd slapd/internal/adminpw password ${LDAP_ADMIN_PASSWORD}" | debconf-set-selections && \
    echo "slapd slapd/password2 password ${LDAP_ADMIN_PASSWORD}" | debconf-set-selections && \
    echo "slapd slapd/password1 password ${LDAP_ADMIN_PASSWORD}" | debconf-set-selections && \
    # 도메인 및 조직 등록
    echo "slapd slapd/domain string ${LDAP_DOMAIN}" | debconf-set-selections && \
    echo "slapd shared/organization string ${LDAP_ORGANIZATION}" | debconf-set-selections && \
    # MDB 데이터베이스 사용 및 DB 삭제 및 백업 활성화
    echo "slapd slapd/backend string MDB" | debconf-set-selections && \
    echo "slapd slapd/purge_database boolean true" | debconf-set-selections && \
    echo "slapd slapd/move_old_database boolean true" | debconf-set-selections && \
    # LDAP v2 비활성화
    echo "slapd slapd/allow_ldap_v2 boolean false" | debconf-set-selections && \
    echo "slapd slapd/no_configuration boolean false" | debconf-set-selections && \
    # 최종 적용
    dpkg-reconfigure -f noninteractive slapd

# 생성용, 수정용 LDIF 파일 등록
COPY ldif/upload.ldif /tmp/upload.ldif
COPY ldif/modify.ldif /tmp/modify.ldif

# 초기화 스크립트 등록
## COPY init-ldap.sh /tmp/init-ldap.sh
## RUN chmod +x /tmp/init-ldap.sh

# 포트 open
EXPOSE 389

# openLDAP 서버 실행(openldap이라는 그룹 및 사용자명으로 Debug 레벨을 256(통계 정보 출력)으로 실행)
CMD ["slapd", "-h", "ldap://0.0.0.0:389", "-g", "openldap", "-u", "openldap", "-F", "/etc/ldap/slapd.d", "-d", "256"]