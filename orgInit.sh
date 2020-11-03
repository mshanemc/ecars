sfdx force:org:create -f config/project-scratch-def.json -d 1 -s
# set password because it's used as an env var for heroku apps
sfdx shane:user:password:set -g User -l User -p sfdx1234

# mqtt
sfdx shane:heroku:repo:deploy -g mshanemc -r ecars -b main -n `basename "${PWD/mshanemc-/}"`-mqtt -o APP_BASE=apps/ecars-mqtt-broker

# streaming app
sfdx shane:heroku:repo:deploy -g mshanemc -r ecars -b main -n `basename "${PWD/mshanemc-/}"`-str -o APP_BASE=apps/ecars-realtime,MQTT_BROKER_URL=wss://`basename "${PWD/mshanemc-/}"`-mqtt.herokuapp.com
heroku addons:create heroku-postgresql:hobby-dev --app=`basename "${PWD/mshanemc-/}"`-str --wait
heroku run 'cd packages/ecars-db && npx sequelize db:migrate' --app=`basename "${PWD/mshanemc-/}"`-str
heroku ps:scale web=1:free sensor-simulator=1:free sensor-persistence=0:free sensor-connector=0:free --app=`basename "${PWD/mshanemc-/}"`-str

# pwa
sfdx shane:heroku:repo:deploy -g mshanemc -r ecars -b main -n `basename "${PWD/mshanemc-/}"`-pwa -o APP_BASE=apps/ecars-pwa,VAPID_PUBLIC_KEY=BEuf8eLfYtMMN8cge4IIoKjt4U8kn3fKyD_EDsQhe7gLqg0ZfcmthdJKvgz6po68yalkyzbvvrDs_r1qm9JHjPU,VAPID_PRIVATE_KEY=t80B5ZObGfsdQSQzYQqjLXl9Y4iIW1kLuzbPeAOGMDg --envpassword=SF_PASSWORD --envuser=SF_USERNAME
heroku addons:attach `basename "${PWD/mshanemc-/}"`-str::DATABASE --as=DATABASE --app=`basename "${PWD/mshanemc-/}"`-pwa
heroku config:set --app=`basename "${PWD/mshanemc-/}"`-pwa SF_TOKEN= 

# microservices
sfdx shane:heroku:repo:deploy -g mshanemc -r ecars -b main -n `basename "${PWD/mshanemc-/}"`-srv -o APP_BASE=apps/ecars-services,VAPID_PUBLIC_KEY=BEuf8eLfYtMMN8cge4IIoKjt4U8kn3fKyD_EDsQhe7gLqg0ZfcmthdJKvgz6po68yalkyzbvvrDs_r1qm9JHjPU,VAPID_PRIVATE_KEY=t80B5ZObGfsdQSQzYQqjLXl9Y4iIW1kLuzbPeAOGMDg,SF_LOGIN_URL=https://test.salesforce.com, --envpassword=SF_PASSWORD --envuser=SF_USERNAME
heroku addons:attach `basename "${PWD/mshanemc-/}"`-str::DATABASE --as=DATABASE --app=`basename "${PWD/mshanemc-/}"`-srv
heroku config:set --app=`basename "${PWD/mshanemc-/}"`-srv SF_TOKEN= 

# local file substitutions
sfdx shane:source:replace -f force-app/main/default/cspTrustedSites/WebSockets.cspTrustedSite-meta.xml -o example.herokuapp -n `basename "${PWD/mshanemc-/}"`-str.herokuapp
sfdx shane:source:replace -f force-app/main/default/lwc/liveData/liveData.js -o example.herokuapp -n `basename "${PWD/mshanemc-/}"`-str.herokuapp
sfdx shane:source:replace -f force-app/main/default/namedCredentials/Heroku_App.namedCredential-meta.xml -o example.herokuapp -n `basename "${PWD/mshanemc-/}"`-srv.herokuapp

sfdx force:source:push

sfdx force:user:permset:assign -n ecars
sfdx force:user:permset:assign -n Walkthroughs
sfdx force:data:tree:import --plan ./data/data-plan.json
sfdx shane:theme:activate --name Pulsar_Bold
sfdx force:org:open
