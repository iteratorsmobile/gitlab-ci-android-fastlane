FROM openjdk:8-jdk
LABEL maintainer="Iterators Mobile <mobile@iterato.rs>"

ENV ANDROID_COMPILE_SDK "28"
ENV ANDROID_BUILD_TOOLS "28.0.3"
ENV ANDROID_SDK_TOOLS "4333796"

ENV DEBIAN_FRONTEND noninteractive

ENV HOME "/root"

RUN curl -sL https://deb.nodesource.com/setup_13.x | bash - \
    && apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget \
    tar \
    unzip \
    lib32stdc++6 \
    lib32z1 \
    build-essential \
    patch \
    ruby-dev \
    zlib1g-dev \
    liblzma-dev \
    yarn
ADD https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip android-sdk.zip
RUN unzip -d android-sdk-linux android-sdk.zip
RUN echo y | android-sdk-linux/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" >/dev/null
RUN echo y | android-sdk-linux/tools/bin/sdkmanager "platform-tools" >/dev/null
RUN echo y | android-sdk-linux/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null
ENV ANDROID_HOME=$PWD/android-sdk-linux
ENV PATH=$PATH:$PWD/android-sdk-linux/platform-tools/
RUN yes | android-sdk-linux/tools/bin/sdkmanager --licenses
# nokogiri (Failed to build gem native extension while installing fastlane fix)
RUN gem install nokogiri
# fastlane
RUN apt-get --quiet install --yes rubygems
RUN gem install fastlane --version 2.141.0 --no-document
ENV GRADLE_USER_HOME=$PWD/.gradle
RUN yarn global add firebase-tools

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
