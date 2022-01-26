FROM node:9.0.0 as build-stage
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY ./ /app/
# ARG configuration=production
# RUN npm run build -- --output-path=./dist/out --configuration $configuration
RUN npm run build -- --output-path=./dist/out

FROM nginx:latest
COPY --from=build-stage /app/dist/out/ /usr/share/nginx/html
COPY --from=build-stage /app/nginx.conf /etc/nginx/conf.d/default.conf