// 의존성 주입(Dependency Injection)을 설정하는 코드
import 'package:get/get.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/data/services/local_app_data_service.dart';
// AppService와 LocalAppDataService라는 두 개의 서비스 클래스를 임포트.
// 이 서비스들은 API 호출, 로컬 데이터 저장 등 비즈니스 로직을 담당.

import '../controllers/login_controller.dart';
// 로그인 관련 로직이 있는 LoginController를 임포트.

class LoginBinding extends Bindings {
  // Bindings: GetX의 기능 중 하나로, 특정 페이지에 진입할 때 컨트롤러나 서비스 등을 자동으로 메모리에 등록(put)하는 역할.
  // GetX에서 특정 페이지에 들어가기 전에 필요한 의존성을 등록할 때 사용
  @override
  void dependencies() {
    // dependencies() 함수는 페이지가 로드될 때 호출
    Get.lazyPut<LoginController>(
      // lazyPut은 필요할 때만 인스턴스를 생성해
      () => LoginController(
          // LoginController 생성 시, AppService와 LocalAppDataService를 주입한다
          appService: Get.find<AppService>(),
          // 이미 등록된 AppService 인스턴스를 찾아서 사용
          // 이미 등록된 인스턴스를 가져오겠다는 뜻
          localAppDataService: Get.find<LocalAppDataService>()),
      //
    );
  }
}
// LoginBinding은 로그인 페이지 진입 시 필요한 LoginController를 등록하고,
// 그 컨트롤러 안에 필요한 서비스(AppService, LocalAppDataService)도 주입해서 사용 가능하게 만들어줘.
