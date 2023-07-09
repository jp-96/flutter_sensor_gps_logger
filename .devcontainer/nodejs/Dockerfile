# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.195.0/containers/javascript-node/.devcontainer/base.Dockerfile
# [Choice] Node.js version (use -bullseye variants on local arm64/Apple Silicon): 16, 14, 12, 16-bullseye, 14-bullseye, 12-bullseye, 16-buster, 14-buster, 12-buster
ARG VARIANT=16-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment if you want to install an additional version of node using nvm
# ARG EXTRA_NODE_VERSION=10
# RUN su node -c "umask 0002 && ./usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION}"

# [Optional] Uncomment if you want to install more global node modules
# RUN su node -c "npm install -g <your-package-list-here>"

# OpenJDK
ARG OPENJDK_VERSION="11-jdk"
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends openjdk-${OPENJDK_VERSION}

# node user
ARG INSTALL_USER_HOME=/home/node
WORKDIR ${INSTALL_USER_HOME}
USER node

# Android SDK
# https://developer.android.com/tools
# https://developer.android.com/studio
ARG ANDROID_SDK_TOOLS_VERSION=9477386

ENV ANDROID_HOME=${INSTALL_USER_HOME}/android-sdk
ENV ANDROID_SDK_ROOT="${ANDROID_HOME}"
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

RUN curl -C - --output android-sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip \
    && mkdir -p ${ANDROID_HOME}/ \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/ \
    && rm android-sdk-tools.zip \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest
RUN yes | sdkmanager --licenses
RUN touch ${INSTALL_USER_HOME}/.android/repositories.cfg
RUN sdkmanager platform-tools

# Flutter SDK
# https://docs.flutter.dev/release/archive?tab=linux
ARG FLUTTER_CHANNEL="stable"
ARG FLUTTER_VERSION="3.10.0"

ENV FLUTTER_HOME=${INSTALL_USER_HOME}/flutter-sdk
ENV PATH=${PATH}:${FLUTTER_HOME}/bin

RUN curl -C - --output flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz
RUN tar -xf flutter.tar.xz \
    && mv flutter ${FLUTTER_HOME} \
    && rm flutter.tar.xz
RUN flutter config --android-sdk "${ANDROID_SDK_ROOT}"
RUN yes | flutter doctor --android-licenses
RUN flutter config --no-analytics
RUN flutter update-packages

USER root