FROM jekyll/jekyll:3.3.1
MAINTAINER napalm-automation

COPY Gemfile /tmp
RUN cd /tmp && bundle
