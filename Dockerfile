FROM ruby:3.1.2

ENV LANG=en_GB.UTF-8
ENV DATABASE_URL=postgresql://epb:superSecret30CharacterPassword@epb-auth-server-db/epb
ENV JWT_ISSUER=epb-auth-server
ENV JWT_SECRET=test-jwt-secret
ENV URL_PREFIX=/auth
ENV EPB_UNLEASH_URI=http://epb-feature-flag/api
ENV RACK_ENV=development
ENV STAGE=development


SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -; \
    apt-get update -qq && apt-get install -qq --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v '2.3.22' && \
    gem install rerun

COPY . /app

RUN cd /app && bundle install

EXPOSE 80

ENTRYPOINT bash -c 'cd /app && bundle exec rackup -p 80 -o 0.0.0.0'
