#!/bin/bash
# ===========================================
# 컨테이너 시작 시 실행되는 초기화 스크립트
# ===========================================
#
# [문제]
# 볼륨 마운트 시 컨테이너 내부 /etc/ldap/slapd.d가
# 호스트의 빈 폴더로 덮어씌워져 설정이 사라짐
#
# [해결]
# 빌드 시 백업한 slapd.d.orig에서 설정을 복원
#
# [동작]
# 첫 실행: 볼륨 비어있음 → 백업에서 복사
# 재실행: 볼륨에 데이터 있음 → 스킵
# ===========================================

# 설정 파일이 없으면 (= 첫 실행)
if [ ! -f /etc/ldap/slapd.d/cn=config.ldif ]; then
    cp -r /etc/ldap/slapd.d.orig/* /etc/ldap/slapd.d/
    chown -R openldap:openldap /etc/ldap/slapd.d
    chown -R openldap:openldap /var/lib/ldap
fi

exec slapd -h "ldap://0.0.0.0:389" -g openldap -u openldap -F /etc/ldap/slapd.d -d 256
