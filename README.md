# Getting started

## Build Setup
``` bash
# Make sure you have ruby 3.1.0 installed
$ bundle i

# Create, migrate and seed DB
$ rails db:prepare

# Start server
$ rails s
```

*This project cannot run properly without other project that triggers actions using websockets*


# Description

## Project
Backend project to handle virtual queues using websockets.

## Basic schema definition
1. `Place` is the store/magazine itself
2. `Service` one store/magazine could have multiple services to offer
3. `Address` are the place addresses
4. `Category` for categorize places
5. `Promotions` to show store/magazine promotions on the app
6. `Rating` enable user to rate everything (place, worker, ...)
7. `Log` to track all actions that occur in queues
8. `User` could be a store/magazine client, worker or admin
9. `Line` represents a position in a virtual queue

## Functional definition
*A full defined place with worker/s and at least one service available should be created in the system to have a virtual queue.*

When a user wants to join in one place-service queue, the system checks if he/she is already in the queue. If not, the user is added into the queue. This is represented with a new line record in the database associated to this user and a position.

Everytime someone leaves the queue, because he/she has been attended (served line status) or he/she abandon the queue (abandoned line status), all lines associated to this virtual queue moves one position forward.

As a user, your position in the queue (line) could have 5 statusses:
1. waiting (in queue)
2. pending (when the user is the next one and is waiting the worker confirmation)
3. serving (when worker confirms and start the serving)
4. served (when worker finishes the serving)
5. abandoned (user leaves the queue)

As a worker, you are registered into a place-service and you are waiting for clients until someone ask your confirmation. Then you can accept or decline this confirmation. When the serving is finished you just finish the serving. This statusses are represented via:
1. waiting for clients (the worker is not associated to any line that pending neither serving)
2. some client ask for confirmation (worker is associated to a waiting line that becomes to pending)
3. accepts the confirmation (the line changes their status to serving)
4. cancel the confirmation (the line changes their status to abandoned)

This queue management could be also check in [Customer flow chart](https://github.com/adriacarro/api.kolakola.app/blob/master/customer_flow.pdf) and [Worker flow chart](https://github.com/adriacarro/api.kolakola.app/blob/master/worker_flow.pdf).

## Communication
All comunication between the app and the backend is being processed using websockets.

## Deployment
This was deployed into an EB AWS instance.

# Notes
This is just a beta.