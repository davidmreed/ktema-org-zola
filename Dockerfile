FROM jekyll/jekyll

WORKDIR /srv/jekyll
COPY Gemfile Gemfile.lock _config.yml ./
RUN bundle install

CMD [ "jekyll", "serve" ]
