# Usage

Build the docker project:  
`docker-compose build`

Boot the app:  
`docker-compose up`

POST to `localhost:3000/trajets` to create a new trajet  
Its code will be returned, you can then use the following routes to update its state:  
- `localhost:3000/trajets/:code/start`  
- `localhost:3000/trajets/:code/cancel`
