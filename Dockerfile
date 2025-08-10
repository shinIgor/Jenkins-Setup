# 1. 공식 Jenkins 이미지를 기반으로 시작합니다.
FROM jenkins/jenkins:lts-jdk17

# 2. 관리자(root) 권한으로 전환하여 필요한 도구들을 설치합니다.
USER root

# 3. Docker CLI 설치 (기존과 동일)
RUN apt-get update && apt-get install -y lsb-release curl gnupg
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce-cli

# 4. Homebrew 설치에 필요한 기본 도구들을 설치합니다.
RUN apt-get install -y build-essential procps file git

# 5. Homebrew 설치 (권한 문제 해결된 버전)
RUN mkdir -p /home/linuxbrew/.linuxbrew && chown -R jenkins:jenkins /home/linuxbrew

#    - jenkins 사용자로 전환합니다.
USER jenkins
WORKDIR /var/jenkins_home
#    - 이제 jenkins 사용자는 권한이 있는 폴더에 Homebrew 저장소를 Git Clone 합니다.
RUN git clone https://github.com/Homebrew/brew /home/linuxbrew/.linuxbrew/Homebrew
#    - Homebrew 실행 파일들을 생성합니다.
RUN mkdir -p /home/linuxbrew/.linuxbrew/bin && \
    ln -s /home/linuxbrew/.linuxbrew/Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew
#    - Homebrew 환경변수를 설정합니다.
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
#    - Homebrew 설치를 완료하고 기본 패키지를 설정합니다.
RUN brew update --force --quiet && \
    chmod -R go-w "$(brew --prefix)/share/zsh"

# --- 이 부분이 완전히 변경되었습니다 ---
# 6. 필수 Jenkins 플러그인 설치
#    - 플러그인 목록 파일을 복사합니다.
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
#    - Jenkins 공식 플러그인 설치 스크립트를 실행합니다.
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
# ------------------------------------

# 7. 다시 관리자(root)로 돌아와서 jenkins 사용자에게 sudo 권한을 부여합니다 (선택 사항, 필요시 사용).
USER root
RUN echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
#    - 최종적으로 jenkins 사용자로 컨테이너를 실행합니다.
USER jenkins
