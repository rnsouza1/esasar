FROM ruby:2.4.4

RUN apt-get update -qq \
	&& apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    wget \
    libreadline-dev \ 
    zlib1g-dev \ 
    flex \
    bison \
    libxml2-dev \
    libxslt-dev \
    libssl-dev

RUN wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq \
	&& apt-get install -y --no-install-recommends \
  postgresql-client-9.6 \
  && rm -rf /var/lib/apt/lists/*t

RUN mkdir /mnt/esasar
COPY Gemfile /mnt/esasar/
COPY Gemfile.lock /mnt/esasar/
WORKDIR /mnt/esasar

# Bundle install
RUN bundle install
COPY . /mnt/esasar

EXPOSE 5000

