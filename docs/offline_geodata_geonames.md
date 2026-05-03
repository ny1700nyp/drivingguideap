# 오프라인 지명 데이터 (GeoNames) — 번들·라이선스·출처 정리

앱에 포함된 **오프라인 역지오코딩용 행정 구역·도시 데이터**가 무엇인지, 라이선스상 무엇을 지켜야 하는지 한곳에 적어 둡니다. 나중에 스토어 제출·법무 검토·데이터 갱신 시 이 문서만 보면 됩니다.

---

## 1. 번들에 포함된 파일

| 파일 | 경로 | 용도 |
|------|------|------|
| 인구 15k 이상 도시 목록 | `assets/geodata/cities15000.txt` | GPS 좌표 기준 최근접 도시 후보 (위도·경도·국가·**admin1/admin2 코드**) |
| 1차 행정구역 영문 명칭 | `assets/geodata/admin1CodesASCII.txt` | `KR.11` → Seoul, `US.CA` → California 등 주·도·광역 이름 |
| 2차 행정구역 영문 명칭 | `assets/geodata/admin2Codes.txt` | `US.CA.067` → Sacramento County 등 카운티·상위 시 등 (국가마다 의미 상이) |

구현은 `lib/features/location/offline_city_lookup.dart`에서 `package:kdtree`로 최근접 도시를 찾고,  
`국가코드.admin1코드` · **`국가코드.admin1코드.admin2코드`** 로 이름을 조회합니다.

로컬 참고: `assets/geodata/README.txt`

---

## 2. 라이선스 (무료 사용 가능 여부)

GeoNames 덤프 데이터는 **Creative Commons Attribution 4.0 International (CC BY 4.0)** 로 배포되는 것이 일반적입니다.

- **상업적 이용·수정·재배포**가 허용되는 편입니다.
- 대신 **적절한 저작자 표시(attribution)** 와 **라이선스 안내**를 해야 합니다.  
  (= “아무 조건 없이 공짜”가 아니라 **출처를 남겨야 하는 무료**에 가깝습니다.)

공식 라이선스·안내는 아래에서 확인합니다.

- GeoNames: https://www.geonames.org/
- CC BY 4.0 전문: https://creativecommons.org/licenses/by/4.0/

법적 최종 해석은 변호사에게 맡기고, 이 문서는 **운영 시 체크리스트** 용도입니다.

---

## 3. 우리가 해야 할 일 (출처 표기)

다음을 **사용자나 검토자가 볼 수 있는 곳**에 두면 안전합니다.

- 데이터 출처가 **GeoNames**임을 명시
- **CC BY 4.0** 적용을 명시하고, 가능하면 라이선스 링크 포함

**예시 문구 (영문, 스토어·크레딧용)**

> Geographic reference data (city and administrative region names) includes data from [GeoNames](https://www.geonames.org/), used under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

**예시 문구 (국문)**

> 일부 지명·행정구역 참조 데이터에 GeoNames(https://www.geonames.org/) 데이터가 포함되어 있으며, CC BY 4.0(https://creativecommons.org/licenses/by/4.0/) 조건에 따라 사용합니다.

---

## 4. 어디에 넣으면 좋은지 (권장)

| 위치 | 비고 |
|------|------|
| 앱 내 **About / Acknowledgments / 데이터 출처** 화면 | 가장 흔한 방식 |
| **앱 스토어 설명** 하단 | 심사·투명성에 유리 |
| **웹용 Privacy / Terms** | 필수는 아님. 다만 회사 정책상 “제3자 데이터” 절을 두고 싶다면 여기 한 줄 넣어도 됨 |

**Privacy Policy**에 꼭 넣어야 하는 성격의 데이터는 아님: 이 파일들은 **사용자 정보를 GeoNames 서버로 보내서 받아오는 형태가 아니라**, 앱 패키지에 **미리 넣어 둔 참조 DB**이기 때문입니다. (위치 권한·온디바이스 처리 등은 기존 개인정보 문서에서 따로 설명.)

---

## 5. 데이터 갱신할 때

공식 덤프 예시 (버전은 배포 페이지 기준):

- https://download.geonames.org/export/dump/cities15000.zip  
- https://download.geonames.org/export/dump/admin1CodesASCII.txt  
- https://download.geonames.org/export/dump/admin2Codes.txt  

갱신 후에도 **출처·CC BY 4.0 표기 의무는 동일**합니다. 형식이 바뀌면 `offline_city_lookup.dart`의 파서·컬럼명과 맞는지 확인합니다.

---

## 6. 변경 이력 (수동으로 적어두기)

| 날짜 | 내용 |
|------|------|
| (초안) | 문서 작성 — cities15000 + admin1CodesASCII 번들, CC BY 4.0 출처 표기 안내 |
