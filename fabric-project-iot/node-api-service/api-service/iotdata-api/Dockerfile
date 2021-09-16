FROM node:8.16.0

WORKDIR /src/iotdata-api
COPY . /src/iotdata-api
RUN npm install --production \
	&& npm install pm2 -g --no-optional --production
