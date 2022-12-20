Use only one pod at a time to bind with the service, otherwise it will load balance across the pods since all have the same label that the service references.

$ curl [NODE]:[nodePORT]

