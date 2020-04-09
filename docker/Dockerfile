FROM alpine:3.11.5

RUN apk add --no-cache \
      ca-certificates \
      chromium \
      chromium-chromedriver \
      curl \
      ruby \
      ruby-json \
      ruby-webrick \
      ttf-freefont \
      unzip \
      x11vnc \
      xvfb \
    && gem install bundler

WORKDIR /app

COPY Gemfile Gemfile.lock all-tests /app/

RUN apk add --no-cache --virtual build-deps \
      build-base \
      ca-certificates \
      curl \
      libxml2-dev \
      libxslt-dev \
      ruby-dev \
      zlib-dev \
    && BUNDLE_SILENCE_ROOT_WARNING=1 bundle config build.nokogiri --use-system-libraries \
    && BUNDLE_SILENCE_ROOT_WARNING=1 bundle install \
    && apk del build-deps

# Expose remote debugging port. Browse to http://docker-container-ip:9222
# to see what's going on inside Chromium.
EXPOSE 9222

# Expose VNC port. The user can run tests using Chromium through VNC to debug
# tests.
EXPOSE 5901

RUN adduser --disabled-password --shell /bin/sh chromium
USER chromium

VOLUME /app/files
VOLUME /app/spec
VOLUME /app/helpers
VOLUME /app/reports

CMD ./all-tests
