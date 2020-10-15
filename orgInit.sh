sfdx force:org:create -f config/project-scratch-def.json -d 1 -s
sfdx force:source:push

sfdx shane:user:password:set -g User -l User -p sfdx1234
sfdx force:user:permset:assign -n ecars
sfdx force:user:permset:assign -n Walkthroughs
# TODO: url updates example.herokuapp.com for CSP,namedCredentials,js 
sfdx force:data:tree:import --plan ./data/data-plan.json