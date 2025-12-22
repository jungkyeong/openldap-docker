## 사용법

### docker 사용법 (Powershell 해당 Dockerfile 위치에서)
1. 이미지 빌드
- docker build -t openldap-test .

2. 실행
- docker run -d -p 389:389 --name ldap-server openldap-test

3. ID 조회 후 중지
- docker ps 후 
- docker stop [CONTAINER ID]

4. 컨테이터 삭제
- docker rm [CONTAINER ID]

5. 컨테이너 접속
- docker exec -it ldap-server /bin/bash

6. 종료
- exit

### LDAP command
- 컨테이너에 접속 후 사용 가능

1. LDAP 검색
- ldapsearch -x -b "dc=master,dc=com"

2. 항목 추가
- ldapadd -x -D "cn=admin,dc=master,dc=com" -W -f upload.ldif

3.  항목 수정
- ldapmodify -x -D "cn=admin,dc=master,dc=com" -W -f modify.ldif

4. 항목 삭제
- ldapdelete -x -D "cn=admin,dc=master,dc=com" -W "cn=alice,ou=team1,dc=master,dc=com"