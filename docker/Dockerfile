# alpine:3.6 doesn't have new-enough Chromium+Node.
# [adam, 2017-11-24] alpine:3.7 should be out any day now!
# [adam, later 2017-11-24] alpine:edge has Chromium 61. That's not enough:
# Chromium 61 headless doesn't let us test `window.alert()`.
#
# Switch to alpine when it has chromium 63. Debian (Chrome 63) makes the build
# super-slow.
FROM debian:stretch

RUN set -x \
      && echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/force-unsafe-io \
      && echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache \
      && apt-get update \
      && apt-get install -y \
        build-essential \
        ca-certificates \
        chromium \
        curl \
        libffi-dev \
        libgconf2.0 \
        ruby \
        ruby-dev \
        unzip \
        zlib1g-dev \
        tigervnc-standalone-server \
        xvfb \
      && gem install bundler \
      && (cd /tmp && curl "http://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip" -o chromedriver_linux64.zip && unzip chromedriver_linux64.zip && rm -f chromedriver_linux64.zip && mv chromedriver /usr/bin/)

# Expose remote debugging port. Browse to http://docker-container-ip:9222
# to see what's going on inside Chromium.
EXPOSE 9222

# Expose VNC port. The user can run tests using Chromium through VNC to debug
# tests.
EXPOSE 5901

RUN useradd -ms /bin/bash chromium

WORKDIR /app

COPY Gemfile Gemfile.lock all-tests /app/
RUN bundle install

VOLUME /app/files
VOLUME /app/spec
VOLUME /app/helpers
VOLUME /app/reports

CMD ./all-tests
