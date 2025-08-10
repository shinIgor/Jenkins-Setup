# 1. 공식 Jenkins 이미지를 기반으로 시작합니다.
FROM jenkins/jenkins:lts-jdk17

# 2. 관리자(root) 권한으로 전환하여 모든 설치를 진행합니다.
USER root

# 3. Docker CLI를 먼저 설치합니다.
#    - 필요한 패키지를 설치합니다.
RUN apt-get update && apt-get install -y lsb-release curl gnupg
#    - Docker의 공식 GPG 키를 추가합니다.
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#    - Docker 저장소를 설정합니다.
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
#    - Docker CLI를 설치합니다.
RUN apt-get update && apt-get install -y docker-ce-cli

# 4. 필수 Jenkins 플러그인을 직접 이름을 지정하여 설치합니다.
#    이것이 가장 확실하고 안정적인 방법입니다.
RUN /usr/local/bin/install-plugins.sh kubernetes

# 5. 최종적으로 jenkins 사용자로 컨테이너를 실행합니다.
USER jenkins
