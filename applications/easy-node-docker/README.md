# Harness Developer Hub Sample App

![CI](static/img/icon_ci.svg)
![CD](static/img/icon_cd.svg)
![FF](static/img/icon_ff.svg)
![CCM](static/img/icon_ccm.svg)
![SRM](static/img/icon_srm.svg)
![STO](static/img/icon_sto.svg)
![CE](static/img/icon_ce.svg)

# Easy Node Docker
This example is based of of the NodeJS's Project Example -> https://nodejs.org/en/docs/guides/nodejs-docker-webapp/

## Building the Example
NPM and Docker are needed. 

```
NPM:
choco install nodejs
brew install node

Docker:
choco install docker
brew install docker
```

Local Testing [opional]:

```
npm install
npm test
```

Docker Build.

```
docker build --tag your_user/repo:tag .
docker push your_user/repo:tag
```

### Exposed Port
The app as is, is exposed on port '2121'. 
