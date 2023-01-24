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

COPY . /app
WORKDIR /app

RUN bundle install

EXPOSE 80 433

ENTRYPOINT ["bundle", "exec", "rackup", "-p", "80", "-o", "0.0.0.0"]

