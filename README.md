# gitlab-ci-android-fastlane

This Docker image contains the Android SDK and fastlane.

`.gitlab-ci.yml` example:

```
image: iteratorsmobile/gitlab-ci-android-fastlane

stages:
- build
- deploy

cache:
  key: ${CI_PROJECT_ID}
  paths:
  - .gradle/

build_job:
  stage: build
  script:
  - ./gradlew assembleRelease
  artifacts:
    paths:
    - app/build/outputs

deploy_internal:
  stage: deploy
  when: manual
  script:
  - fastlane android staging
```
