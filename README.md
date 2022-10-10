# Stream Sharding Experiment

## Instructions

1. You'll first need a local k6 binary built with Loki and Prometheus support.
For that, follow the instructions
[under XK6-Loki](https://github.com/grafana/xk6-loki) but **run from branch
prom-support**, available
[here](https://github.com/grafana/xk6-loki/tree/prom-support). After running
`make k6`, move the created k6 binary to a place that will be merged with your
$PATH. Since I have `~/go/bin/` under my $PATH, I moved the k6 binary there.
1. To monitor what is going on, run the root containers available on this same folder
after clonning this repository. Run `docker-compose up -d` from this folder and three
containers will run: a root Prometheus instance, Grafana, and cAdvisor.
1. Now, import the existing Grafana dashboard available under this folder
(`Experiment Monitoring.json` file). You can do it the following way: after running
the containers (previous step), visit `localhost:3000` on your browser and, in
the left panel, click to Import dashboards and select the `Experiment Monitoring.json`
file under this folder.
1. Final considerations before we run the experiment:
	1. Since we're validating the effects of stream sharding, we run the
	same experiment/environment variables against three different clusters,
	that have the same resources. The clusters are: cluster-a: this cluster
	won't rate limit things and doesn't have stream sharding enabled;
	cluster-b: this cluster won't rate limit things and **has stream
	sharding enabled**; cluster-c: this cluster will rate limit things.
	1. Each cluster has its own local Prometheus instance. This instance will
	be scraped by the root Prometheus so that you can check results later.
1. To run the experiment, execute `run.sh` and pass as parameter/argument the scenario
you'd like to run. Right now we only have one scenario, `scenario_a`. So you can run it
through `./run.sh scenario_a`.
	1. The script will boot `cluster_a` and wait until it is ready. After, it will
	run k6 against this cluster.
	1. After running the k6 experiment against `cluster_a`, the script will sleep for
	30 seconds to give Prometheus enough time to scrape metrics. Then, it will stop
	the containers to free resources. **The containers are just stopped**, so if you want
	to debug or check something, you can just rerun the containers and they will restore
	the state (i.e: the script doesn't call `docker-compose down`).
	1. The script will do the same steps for `cluster_b` and `cluster_c`.
	1. Check results under Grafana. On top left you'll find two variables useful to
	filter data, one for the cluster and another for the experiment scenario.