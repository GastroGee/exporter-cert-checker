# exporter-cert-checker
The `check.nomad` job deploys an instance of `blackbox-exporter` on any nomad client in the cluster.

To deploy a job in nomad;
```
export NOMAD_ADDR=https://nomad-cluster.gastro.io
export NOMAD_TOKEN="$NOMAD_TOKEN"
```
```
nomad job plan check.nomad
nomad job apply check.nomad
```

If you have multiple domains to monitor, you can use the template engine `Levant` to iterate over a list of domains.

`levant.config.yml` is the variable file to be consumed by levant while the `levant.tmpl` is the job template to be rendered. 


```
cd levant 
levant render -var-file levant.config.yml -out job.yml
levant plan -log-leve=DEBUG -address=$NOMAD_ADDR -out check.nomad levant.tmpl
levant deploy -log-level=DEBUG -address=$NOMAD_ADDR -force-count=true -ignore-no-changes=true check.nomad
```
