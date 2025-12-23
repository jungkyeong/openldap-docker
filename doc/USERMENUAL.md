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

### 스크립트
1. 스크립트 폴더에서 make-organization.sh을 주석 내에 있는 cmd를 참고하여 실행하여 조직 생성
2. 이름에 한국어 등록 가능
3. 부서 수정 시, 하위의 사용자들도 부서 이름이 변경되고 부서가 삭제되면 하위 사용자들도 삭제되도록 제작
4. 조직원 비밀번호는 SSHA으로 저장됨
- SSHA

### KeyCloak 설정 세팅
1. Realm -> User federation
2. 설정 (Connection and authentication settings)
- Connection URL: ldap://192.168.0.16:389
- Bind type: simple
- Bind DN: cn=admin,dc=master,dc=com
- Bind credentials: admin 비밀번호 (Test authentication 클릭하여 테스트 성공 확인)

3. 설정 (LDAP searching and updating)
- Edit mode: READ_ONLY
- Users DN: dc=master,dc=com
- Username LDAP attribute: cn
- RDN LDAP attribute: cn
- UUID LDAP attribute: entryUUID
- User Object Classes: inetOrgPerson
- Search Scope: Subtree
- 후 save

4. 표시되면 해당 realm의 Users에서 openLDAP에서 생성했던 User들이 나옴
- Keycloak에서 user password 변경은 따로 지원되지 않는 듯. LDAP의 user 하나를 삭제하면 해당 LDAP의 user들이 모두 사라지나 동기화로 언제든지 호출 복구 가능
- Keycloak 연동 시 password는 필수 조건임. keycloak에서 openLDAP의 user 비밀번호 변경 및 등록 X
5. User 수동 동기화
- Realm -> User federation -> LDAP 클릭 -> 우측 상단의 Action 드롭 박스 클릭 Sync all users 클릭
- 동기화 시, Keycloak에서 자동으로 판별하여 중복되는 이메일이나 다른 경우는 올리지 않음 
- 가끔 동기화가 잘 안 되는 것 같으면 keycloak 에 있는 ldap user 정보 지운 다음에 다시 시도

6. 자동 동기화
- Realm -> User federation -> Periodic full sync On 선택 -> Full sync period 설정 (ex. 초 단위임. 300 이면 5분)

### LDAP command
- 컨테이너에 접속 후 사용 가능
- 파일에 다수의 사용자들을 적어놓은 뒤 한번에 업로드 가능
- ID 중복 관리 됨 (68 에러 발생)

1. LDAP 검색
- ldapsearch -x -b "dc=master,dc=com"

2. 항목 추가
- ldapadd -x -D "cn=admin,dc=master,dc=com" -W -f upload.ldif

3.  항목 수정
- ldapmodify -x -D "cn=admin,dc=master,dc=com" -W -f modify.ldif

4. 항목 삭제
- ldapdelete -x -D "cn=admin,dc=master,dc=com" -W "cn=alice,ou=team1,dc=master,dc=com"