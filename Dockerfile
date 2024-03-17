# Specify the base image to use, which is Node.js LTS version on Alpine Linux.
FROM node:lts-alpine3.17

# Set the environment variable NODE_ENV to "production". Practice to optimize Node.js application performance in production environments.
ENV NODE_ENV=production

# Set the working directory inside the container to /app. All subsequent commands will be run from this directory.
WORKDIR /app

#  This copies the package.json and package-lock.json files from the host machine to the /app directory in the container.
COPY package*.json /app/

#  Install dependencies specified in package.json. Since NODE_ENV is set to "production", npm will install only production dependencies.
RUN npm install

# This copies the rest of the application code from the host machine to the /app directory in the container.
COPY . .

# This exposes port 3000 on the container. This doesn't actually publish the port, but it documents the port that the container listens on.
EXPOSE 3000

# This specifies the command to run when the container starts, assuming index.js is the entry point of your Node.js application.
CMD [ "node", "index.js" ]
