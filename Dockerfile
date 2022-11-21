FROM openjdk:11.0.12-jdk
LABEL maintainer="Iterators Mobile <mobile@iterato.rs>"

ENV DEBIAN_FRONTEND noninteractive
ENV HOME "/root"

#node
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - \
    && apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

#tools
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

#android
ENV ANDROID_COMPILE_SDK "31"
ENV ANDROID_BUILD_TOOLS "31.0.0"
ENV ANDROID_SDK_TOOLS "8092744"

ENV ANDROID_SDK_ROOT=/android-sdk-linux
ENV ANDROID_HOME=/android-sdk-linux

RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip -O android-commandline-tools.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip -q android-commandline-tools.zip -d /tmp/ \
    && mv /tmp/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm android-commandline-tools.zip

ENV PATH ${PATH}:${ANDROID_SDK_ROOT}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin

RUN yes | sdkmanager --update
RUN yes | sdkmanager --licenses
RUN yes | sdkmanager \
    "patcher;v4" \
    "platforms;android-${ANDROID_COMPILE_SDK}" \
    "emulator" \
    "build-tools;${ANDROID_BUILD_TOOLS}" \
    "tools" \
    "platform-tools" 

# fastlane
RUN apt-get --quiet install --yes rubygems
## nokogiri, rake, rubocop (Failed to build gem native extension while installing fastlane fix)
RUN gem install nokogiri
RUN gem install rake
RUN gem install rubocop
RUN gem install bundler
RUN gem install fastlane --version 2.183.2 --no-document

ENV GRADLE_USER_HOME=$PWD/.gradle
RUN yarn global add firebase-tools

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
