# Change the default to set the amount of instances/servers to be deployed.
# For each node-role

variable "worker_count" {
    default = 3
}

variable "controller_count" {
    default = 1
}