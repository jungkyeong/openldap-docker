## 사용법

### docker 사용법 (Powershell 해당 Dockerfile 위치에서)

1. 빌드 및 실행
- sudo docker compose up -d --build

2. 실행
- sudo docker compose up -d

3. 중지
- sudo docker compose down

4. 삭제
- sudo docker compose down -v

5. 로그 조회
- sudo docker compose logs -f
- sudo docker logs -f ldap-server

6. 컨테이너 접속
- docker exec -it ldap-server /bin/bash

7. 종료
- exit

### 사용 세팅
1. 스크립트 폴더에서 make-organization.sh을 실행하여 조직 생성

### LDAP command
- 컨테이너에 접속 후 사용 가능
- 이름 중복 관리 됨 (68 에러 발생)

1. LDAP 검색
- ldapsearch -x -b "dc=master,dc=com"

2. 항목 추가
- ldapadd -x -D "cn=admin,dc=master,dc=com" -W -f upload.ldif

3.  항목 수정
- ldapmodify -x -D "cn=admin,dc=master,dc=com" -W -f modify.ldif

4. 항목 삭제
- ldapdelete -x -D "cn=admin,dc=master,dc=com" -W "cn=alice,ou=team1,dc=master,dc=com"