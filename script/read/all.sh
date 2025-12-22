#!/bin/bash
# 전체 조회 스크립트
# 사용법: docker exec -it ldap-server bash /tmp/script/read/all.sh

ldapsearch -x -b "dc=master,dc=com"
