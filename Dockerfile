FROM instructure/ruby-passenger:2.7

ENV RAILS_ENV "production"

USER root

RUN apt-get update -qq \
  && apt-get install -qqy \
       git \
  && rm -rf /var/lib/apt/lists/*

USER docker

COPY --chown=docker:docker . .

RUN bundle install --jobs 8

CMD ["tail", "-f", "/dev/null"]
