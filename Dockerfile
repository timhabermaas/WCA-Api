FROM ruby:2.1.3

RUN apt-get update -qq && apt-get install -y unzip

RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
ADD . /myapp
