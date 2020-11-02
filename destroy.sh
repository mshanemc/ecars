sfdx shane:org:delete
heroku destroy -a `basename "${PWD/mshanemc-/}"`-mqtt -c `basename "${PWD/mshanemc-/}"`-mqtt
heroku destroy -a `basename "${PWD/mshanemc-/}"`-str -c `basename "${PWD/mshanemc-/}"`-str
heroku destroy -a `basename "${PWD/mshanemc-/}"`-pwa -c `basename "${PWD/mshanemc-/}"`-pwa
heroku destroy -a `basename "${PWD/mshanemc-/}"`-srv -c `basename "${PWD/mshanemc-/}"`-srv