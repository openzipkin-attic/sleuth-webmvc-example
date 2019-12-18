# Running via docker-compose

Note: The below presumes you have Docker and Docker Compose installed. You can [find an installer for your OS here](https://docs.docker.com/compose/install/).

To run a stack with the frontend, backend, and Zipkin server, simply run the following: `docker-compose up`

This will create the following endpoints:

1. Zipkin: http://localhost:3000
2. Frontend: http://localhost:8081
3. Backend: http://localhost:8082
