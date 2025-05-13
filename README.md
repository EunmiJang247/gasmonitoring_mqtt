# meditation_friend

명상친구구

# 전체 소통 구조

[View]
↓
[Controller]
↓
[Service]
↓
[AppRepository]
↓
[AppRestAPI] / [LocalDataService]

# 폴더 구조

constant : 앱 전체에서 자주 재사용되는 값들(상수, 설정, 스타일 등)을 한 곳에 모아서 관리하는 폴더

data - api - app_api.dart : Dio 기반의 HTTP 클라이언트를 설정하고, 서버와의 통신, 쿠키 관리, 세션 유지, 인터셉터 구성 등을 담당하는 API 요청 엔진 서비스

data - api - app_rest_api.dart : AppRestAPI(client)를 통해 실제 HTTP 요청. Dio + Retrofit 기반으로, 서버의 REST API 엔드포인트들을 메서드 형태로 정의하는 API 인터페이스 클래스야. 이 파일은 자동 생성된 코드(app_rest_api.g.dart)와 연결되어 실제 HTTP 요청을 실행할 수 있게 해준다.

data - models : 데이터 구조(모델 클래스)를 정의하는 공간으로 서버 응답, 로컬 저장, UI 바인딩 등 다양한 곳에서 데이터를 구조화된 형태로 안전하게 관리할 수 있게 도와준다.

data - repository - app_repository.dart : API 통신, 로컬 데이터 접근 등 데이터 소스와의 중계 역할을 담당하며, 상위 계층인 Service나 Controller가 데이터 출처에 의존하지 않고 비즈니스 로직을 수행할 수 있도록 추상화해주는 계층. 실제 데이터를 가져오는 건 API 또는 Hive인데 그 중간에서 추상화된 메서드를 제공하는 게 Repository이다.

services - app_service.dart : 앱 전역에서 사용되는 핵심 서비스 클래스입니다. 로그인, 로그아웃, 프로젝트/도면 관리, 결함 처리, 오프라인 모드 전환 등과 같은 주요 비즈니스 로직을 담당하며, 앱 상태를 중앙에서 관리합니다. AppRepository, LocalAppDataService, LocalGalleryDataService 등과 협력하여 서버 및 로컬 데이터를 통합적으로 다루며, 사용자 인터랙션의 결과를 기반으로 앱의 흐름을 제어하는 컨트롤 타워 역할을 수행합니다.

┌────────────┐
│ AppService │ ← 비즈니스 로직 (로그인, 업로드 등)
└──────┬─────┘
↓
┌────────────────────┐
│ LocalAppDataService│ ← 로컬 데이터 접근 추상화 (캐시 역할)
└──────┬─────────────┘
↓
┌────────────┐
│ Hive │ ← 로컬 NoSQL DB (Key-Value)
└────────────┘

services - local_app_data_service.dart : 로그인 유저 정보, 프로젝트 목록, 마커, 결함, 설정값 등 다양한 데이터를 로컬 DB(Hive)에 저장하여, 오프라인 모드에서도 원활하게 앱을 사용할 수 있도록 지원합니다. Hive Box를 각 데이터 타입별로 분리하여 관리하며, 앱 구동 시 `onInit()`에서 Hive를 초기화하고 필요한 Adapter를 등록합니다. AppService 또는 Controller에서 이 서비스를 통해 로컬 데이터를 읽고 쓰게 되며, 특히 오프라인 로그인, 자동 로그인, 프로젝트 캐시, 상태 복원 등에 중요한 역할을 합니다.

AppService는 비즈니스 로직과 앱 전역 상태 관리
AppRepository는 데이터 소스와 직접 통신하는 역할

# 네이게이션

Get.toNamed('/home') 현재 페이지 위에 새로운 페이지 push
Get.offNamed('/home') 현재 페이지 pop하고 새로운 페이지 push
Get.offAllNamed('/home') 모든 페이지 제거하고 새로운 페이지 push
Get.back() 이전 페이지로 pop

<!-- view 단에 있는 코드 컴포넌트로 -->

getPicture 는 hive에서 pid로 사진 가져옴
fetchGalleryPictures 는 api에서 서버로 요청해서 픽터 가지고 오는것.
loadGallery 결함 id를 던지면 결함의 갤러리를 가지고 오는 역할 hive에서 가져옴.
getPicture 를 여기저기서 사용하는데 이거는 한번 가져올 때만 쓰면 되는 것이다.
api를 가지고 사진 가지고 온 다음에 저장하면서
searchResult.map(
(e) => gallery_box.put(e.pid, e),
);
이부분에서 hive 에 사진을 넣고있다.
이거를 한 다음부터는 hive에서만 가져왔으면 좋겠다

서버에서 가져올때와 하이브에서 가져올 때로 분리해야함!!
요구사항: fetchGalleryPictures 가 딱 한번만 쓰였으면 좋겠다.

1. onTapSendDataToServer 에서 쓰이고 있음(app_serivce.dart) : 사진과 관련된 변경사항을 서버에 업로드 하는 기능 -> 필요하다고 판단됨!

2. changePictureKind 에서 쓰이고 있음 사진의 종류(kind)를 바꾸고, 필요하면 프로젝트 썸네일(대표사진)도 갱신.
   이거는 그냥 fetchGalleryPictures();를 삭제해도 될것으로 보임.
   changeKind과중복이니까.

3. changeKind 에서 쓰이고 있음. 사진의 종류(kind)를 변경하는 사용자 액션을 처리하는 함수(사진의 종류를 "현황" / "기타" / "전경" 중 하나로 변경할 때)

4. changeLocation 에서 쓰이고 있음. 위치를 변경하는 콘트롤러.

5. deletePicture 에서 쓰이고 있음. 사진을 삭제하는 콘트롤러.

6. takePicture 에서 쓰이고 있음. drawingDetailController.loadGallery 가 있으므로 삭제 필요.

7. takeMemoPicture 에서 쓰이고 있음. 불필요 하므로 삭제.

8. project_info_controller.dart의 takeProjectPicture 에서 쓰이고 있음. 불필요하므로 삭제.

하이브에서 변경사항 꺼내서 보는 방법???

에러:
지금 앱이 사진 찍고 나서 강제 종료되는 증상이 생기고 있는데,
로그를 보면 Flutter 앱의 SurfaceView가 사라지면서 연결이 끊기고 종료되는 상황이야.
surfaceDestroyed
이건 사진 찍는 도중 또는 직후에 Flutter 뷰가 파괴되면서 앱이 비정상 종료됐다는 의미야.

# 깃풀받고 할것

1. org.gradle.java.home=C:\\Program Files\\Java\\jdk-17 -> 이거 주석 처리

아디: test@eleng.co.kr
비번: test12345
