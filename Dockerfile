# Use the official Node.js image.
FROM node:14

# Set the working directory in the Docker image.
WORKDIR /usr/src/app

# Copy package.json and package-lock.json.
COPY package*.json ./

# Install dependencies.
RUN npm install

# Copy the rest of the application code.
COPY . .

# Expose the application port.
EXPOSE 3000

# Define the command to run the application.
CMD [ "node", "app.js" ]

