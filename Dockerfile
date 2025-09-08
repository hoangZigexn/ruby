FROM datvtr/ruby:2.1.5

# T?o th? m?c app
RUN mkdir /app
WORKDIR /app

# C?i bundler c? ph? h?p v?i Rails 3.2.22
RUN gem install bundler -v '1.17.3'

# Copy Gemfile v?o tr??c ?? cache layer bundle
COPY Gemfile /app/

# C?i gems v?i bundler c? th?
RUN bundle _1.17.3_ install

# Copy to?n b? project
COPY . /app

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
