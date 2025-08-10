# 1. 공식 Jenkins 이미지를 기반으로 시작합니다.
FROM jenkins/jenkins:lts-jdk17

# 2. 관리자(root) 권한으로 전환하여 필요한 도구들을 설치합니다.
USER root

# 3. Docker CLI 설치 (Jenkins가 다른 Docker 명령을 내릴 수 있게 함)
#    - 필요한 패키지를 먼저 설치합니다.
RUN apt-get update && apt-get install -y lsb-release curl gnupg
#    - Docker의 공식 GPG 키를 추가합니다.
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#    - Docker 저장소를 설정합니다.
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
#    - Docker CLI를 설치합니다.
RUN apt-get update && apt-get install -y docker-ce-cli

# 4. Homebrew 설치 (비대화형 방식으로 설치)
#    - Homebrew를 설치할 jenkins 사용자로 다시 전환합니다.
USER jenkins
#    - /home/linuxbrew/.linuxbrew 경로에 Homebrew를 설치합니다.
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#    - jenkins 사용자의 환경 설정 파일에 Homebrew 경로를 추가합니다.
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /var/jenkins_home/.bashrc
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# 5. 필수 Jenkins 플러그인 목록을 이미지 안에 미리 포함시킵니다.
COPY --chown=jenkins:jenkins plugins.txt /var/jenkins_home/plugins.txt
ENV JENKINS_OPTS="--plugin-file=/var/jenkins_home/plugins.txt"

# 6. 다시 관리자(root)로 돌아와서 jenkins 사용자에게 sudo 권한을 부여합니다 (선택 사항, 필요시 사용).
USER root
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
#    - 최종적으로 jenkins 사용자로 컨테이너를 실행합니다.
USER jenkins
