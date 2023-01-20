# Jobs and Cronjobs with RabbitMQ-Redis and Python

1. Job to calculate pi

```
$ kubectl apply -f 01-job-pi.yaml

$ kubectl get pods

$ kubectl logs pi
```

2. Job to build a RabbitMQ queue with items.
    
- Build the docker image and add to the remote repo
```
$ cd python-rabbitmq

$ docker build -t python-rabbitmq .

$ docker images | grep rabbit

$ docker login

$ docker tag python-rabbitmq:latest wusted/python-rabbitmq:latest

$ docker push wusted/python-rabbitmq:latest
```

- 


3. Job to build a Redis queue with items.

- Build the docker image and add to the remote repo
```
$ cd python-redis

$ docker build -t python-redis .

$ docker images | grep redis

$ docker login

$ docker tag python-redis:latest wusted/python-redis:latest

$ docker push wusted/python-redis:latest

```