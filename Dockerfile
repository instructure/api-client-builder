FROM instructure/rvm
MAINTAINER Instructure

COPY Gemfile* *.gemspec /usr/src/app/
COPY lib/api_client_builder/version.rb /usr/src/app/lib/api_client_builder/

USER root
RUN chown -R docker:docker /usr/src/app
USER docker
RUN /bin/bash -l -c "cd /usr/src/app && bundle install"

COPY . /usr/src/app
USER root
RUN chown -R docker:docker /usr/src/app/*
USER docker
CMD /bin/bash -l -c "cd /usr/src/app && pwd && bundle exec wwtd --parallel"
