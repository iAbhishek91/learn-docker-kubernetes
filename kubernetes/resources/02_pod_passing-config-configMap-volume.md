# passing configMap to pod via volume

There are **four** steps

- create the dir / or files containing the config (this is dir volume-configMap).
- create the config map (done in 03_configMap-from-dir.sh)
- create the volume of type configMap (done as part of pod yml).
- mount the volume (done as part of the pod yml).
