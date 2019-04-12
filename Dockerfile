FROM openjdk:8-jdk
LABEL maintainer="Iterators Mobile <mobile@iterato.rs>"

ENV ANDROID_COMPILE_SDK "28"
ENV ANDROID_BUILD_TOOLS "28.0.3"
ENV ANDROID_SDK_TOOLS "4333796"

ENV ANDROID_HOME "/sdk"

ENV PATH "$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

ENV HOME "/root"

RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget \
    tar \
    unzip \
    lib32stdc++6 \
    lib32z1
ADD https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip android-sdk.zip
RUN unzip -d android-sdk-linux android-sdk.zip
RUN echo y | android-sdk-linux/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" >/dev/null
RUN echo y | android-sdk-linux/tools/bin/sdkmanager "platform-tools" >/dev/null
RUN echo y | android-sdk-linux/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null
ENV ANDROID_HOME=$PWD/android-sdk-linux
ENV PATH=$PATH:$PWD/android-sdk-linux/platform-tools/
RUN chmod +x ./gradlew
# temporarily disable checking for EPIPE error and use yes to accept all licenses
RUN set +o pipefail
RUN yes | android-sdk-linux/tools/bin/sdkmanager --licenses
RUN set -o pipefail
# nokogiri (Failed to build gem native extension while installing fastlane fix)
RUN apt-get --quiet install --yes build-essential \
    patch \
    ruby-dev \
    zlib1g-dev \
    liblzma-dev
RUN gem install nokogiri
# fastlane
RUN apt-get --quiet install --yes rubygems
RUN gem install fastlane --version 2.119.0 --no-document
ENV GRADLE_USER_HOME=$(pwd)/.gradle

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*