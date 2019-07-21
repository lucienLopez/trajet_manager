FROM ruby:2.6.3
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
RUN mkdir /trajet_manager
WORKDIR /trajet_manager
COPY Gemfile /trajet_manager/Gemfile
COPY Gemfile.lock /trajet_manager/Gemfile.lock
RUN apt-get install -y build-essential
RUN bundle install
COPY . /trajet_manager
