### LDAP 원리
1. LDAP은 트리 구조의 DB라 생각하면 편함
2. 

### 구성
1. slapd
- LDAP 서버 프로그램(LDAP 프로토콜을 통해 디렉토리 서비스를 제공하는 데몬(백그라운드 서비스))
- 사용자 계정, 그룹, 조직 정보 등을 저장하고 관리
- 네트워크를 통해 인증 및 디렉토리 조회 서비스 제공
- 역할: LDAP 클라이이언트 요청 처리, 사용자 인증(로그인 검증), 디렉토리 정보 검색 및 수정, DB에 LDAP 데이터 저장

2. ldap-utils
- 클라이언트 도구

3. .ldif 확장자 형태로 ldap 서버 내에서 관리되며 LDAP 내의 DB에 저장하기 위해 포맷을 미리 정해놓은 파일 양식 (저장 X)

### LDIF 등록 파일 구조
1. dn: 고유 주소 식별자
- 엔트리의 전체 경로 (예: `cn=Alice,ou=team1,dc=master,dc=com`)
- dc: 도메인 주소
- ou: 그룹
- cn: 개별 객체의 고유 이름
- sn, mail: 객체 안에 들어가는 Attribute 정보 (미리 정의된 이름 안에서 사용 가능하며 굳이 새로운 항목의 이름을 추가하고 싶다면 스키마를 수정하여 확장 추가)

2. objectClass:
- organization: 최상위 조직
- organizationalUnit: 부서/팀
- inetOrgPerson: 조직원 (사람)

### LDAP 트리 구조 (upload.ldif 기준)
```
                    dc=master,dc=com
                          │
            ┌─────────────┴─────────────┐
            │                           │
      ou=team1                    ou=team2
     (organizationalUnit)        (organizationalUnit)
            │                           │
            │                           │
    cn=Alice                      cn=Lucas
   (inetOrgPerson)              (inetOrgPerson)
   sn: Martinez                  sn: Silva
   mail: alice@master.com        mail: lucas@master.com
```






