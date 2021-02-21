docker-compose build
docker-compose run --rm web /bin/sh -c 'bundle install && \
 yarn install --check-files && \
 cp config/database.yml-default config/database.yml && \
 bundle exec rails db:create && \
 bundle exec rails db:migrate && \
 bundle exec rails db:seed && \
 echo "you can login as sample user! user login info is below \n email:a@a.com, password: password"'

