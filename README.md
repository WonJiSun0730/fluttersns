# 모아 · MOA

오늘의 이야기를 나누는 미니 SNS입니다. Flutter 모바일 앱과 Spring Boot REST API로 구성했어요.

- 닉네임으로 최대 280자의 글을 올리고, 피드를 최신순으로 봐요.
- 좋아요를 누르면 서버에서 횟수를 하나 늘려요. 로그인 없는 시연용 앱이라 반복해서 누를 수 있어요.
- 게시글과 좋아요는 H2 파일 DB에 저장돼요.

## Windows / Android 에뮬레이터에서 실행

JDK 17 이상, Maven, Flutter SDK, Android Studio 및 실행 중인 Android 에뮬레이터가 필요해요.

서버 터미널에서 저장소 루트 기준으로 실행해요.

```powershell
cd server
mvn spring-boot:run
```

앱 터미널에서 저장소 루트 기준으로 실행해요. 초기화 스크립트가 설치된 Flutter SDK로 Android 플랫폼 파일을 생성하고 로컬 HTTP 접속을 설정해요.

```powershell
cd mobile
powershell -ExecutionPolicy Bypass -File .\setup-android.ps1
flutter run
```

기본 서버 주소는 Android 에뮬레이터에서 PC에 접속하는 `http://10.0.2.2:8080`이에요. 같은 네트워크에 연결한 실기기에서는 `flutter run --dart-define=API_URL=http://PC_IP:8080`으로 실행하고, PC에서 포트 8080 접근을 허용해요. HTTP 설정은 과제용 로컬 실행을 위한 것이에요.

## 시연 순서

1. 앱에서 **글 쓰기**를 눌러 닉네임과 내용을 등록해요.
2. 새 글이 피드 맨 위에 뜨는지 확인해요.
3. **좋아요**를 눌러 숫자가 증가하는지 확인해요.
4. 서버를 재시작하고 피드를 새로고침해 데이터가 유지되는지 확인해요.

| 메서드 | 경로 | 기능 |
| --- | --- | --- |
| GET | /api/posts | 피드 조회 |
| POST | /api/posts | 게시글 등록 (author, body) |
| POST | /api/posts/{id}/likes | 좋아요 증가 |

## GitHub 제출

새 저장소를 만든 뒤 압축을 푼 폴더의 내용을 저장소 루트에 올려요. 이미 실행 스크립트를 돌렸다면 Git으로 업로드해 무시 대상인 DB, 빌드 결과물, 로컬 설정을 제외해요. 제출란에는 GitHub 저장소 URL을 입력해요.

## 자동 검증

GitHub Actions에서 Spring Boot 패키징, Flutter 정적 분석, Android APK 빌드와 에뮬레이터의 글 등록·좋아요 연동 테스트를 실행해요.
