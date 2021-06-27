FROM jekyll/jekyll:stable

COPY Gemfile /tmp
RUN cd /tmp && bundle
