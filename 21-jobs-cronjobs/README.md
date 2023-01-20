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

- Deploy the RabbitMQ Deployment and Service.
```
$ kubectl apply -f 02-deployment-rabbitmq.yaml,02-service-rabbitmq.yaml

$ kubectl get pods,deploy,svc
```

- Test with Port forward to the Service for accessing the RabbitMQ Queue.
```
# In another terminal.
$ kubectl port-forward svc/rabbitmq-service 5672

# In another terminal.
$ export BROKER_URL=amqp://guest:guest@127.0.0.1:5672
$ brew install rabbitmq-c
$ amqp-declare-queue --url=$BROKER_URL -q foo -d
$ amqp-publish --url=$BROKER_URL -r foo -p -b Hello
$ amqp-consume --url=$BROKER_URL -q foo -c 1 cat && echo
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

