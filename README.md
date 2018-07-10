# Ruby on Rails Hello World Sample

This application demonstrates a simple, reusable Ruby web application based on the Rails framework.

The command `rails new <app name>` is used to create the files and folders that make up the structure of a Rails application. They are described in the [Getting Started with Rails][] guide.

[![Deploy to Bluemix](https://bluemix.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/IBM-Bluemix/ruby-rails-helloworld)

## Run the app locally

1. [Install Ruby][]
+ cd into this project's root directory
+ Run `gem install bundler` to install bundler
+ Run `bundle install` to install app dependencies
+ Run `rails server`
+ Access the running app in a browser at <http://localhost:3000>

[Install Ruby]: https://www.ruby-lang.org/en/documentation/installation
[Getting Started with Rails]: http://guides.rubyonrails.org/v3.2.8/getting_started.html#creating-the-blog-application

2. [Connect to Cloud Foundry console app - Bluemix]
+ cf ssh esasar -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails c' ''"
+ or connect only into ssh app terminal - cf ssh esasar

3. [deploy]
+ cf push esasar -f web-manifest.yml

4. [deploy workers]
+ cf push esasar-worker-tiv -f worker-tiv-manifest.yml
+ cf push esasar-worker-ds -f worker-ds-manifest.yml

5. cf login
+ cf login -sso -a https://api.w3ibm.bluemix.net