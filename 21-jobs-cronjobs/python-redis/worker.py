#!/usr/bin/env python

import time
import rediswq

host="redis"
# Uncomment next lines if you do not have Kube-DNS working.
#import os
#host = os.getenv("REDIS_SERVICE_HOST")

q = rediswq.RedisWQ(name="job2", host="redis")
print("Working with sessionID: " + q.sessionID())
print("Initial q status: empty=" + str(q.empty()))

while not q.empty():
    item = q.lease(lease_secs=10, block=True, timeout=2)
    if item is not None:
        itemstr = item.decode("utf-8")
        print("Working on " + itemstr)
        time.sleep(10) # Put your actual work here instead of sleep.
        q.complete(item)
    else:
        print("Waiting to work")
print("Queue empty, exit..")
