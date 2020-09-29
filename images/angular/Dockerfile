FROM node:12-alpine as build-stage

WORKDIR /app

COPY package*.json ./

COPY .npmrc ./

RUN npm install

RUN rm -f .npmrc

COPY . .

RUN npm run build -- --output-path=./dist/out

# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
FROM nginx:alpine

COPY --from=build-stage /app/dist/out/ /var/www/html

# Copy the default nginx.conf
COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]