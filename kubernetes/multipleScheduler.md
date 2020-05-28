# Scheduler

There can be multiple scheduler in a cluster (name must be different), and we can instruct a pod to use specific scheduler, use the field **spec.schedulerName**.

By default it is always default scheduler.

In case there are multiple scheduler(of same type **--leader-elect=true**) in the cluster, but if there are multiple scheduler of different type then **--leader-elect=false** OR **--lock-object-name=new-scheduler**

Scheduler events can be viewed in *k get events* with REASON: scheduler and SOURCE: new-scheduler.
Scheduler logs can be viewed in *k logs new-scheduler -n kube-system*.

## Name the scheduler

Scheduler name is passed as a CLI argument **--scheduler-name** in the service.
