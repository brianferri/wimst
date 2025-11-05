# WIMST

WIMST is a custom SDDM theme based on the [where-is-my-sddm-theme](https://github.com/stepanzubkov/where-is-my-sddm-theme) project, customizing a few animations and default properties

## Setup

You can install it by simply running:

```sh
git clone https://github.com/brianferri/wimst.git && cd wimst

chmod +x install
sudo ./install
```

And modifying your `/etc/sddm.conf.d/default.conf` to hold:

```toml
[Theme]
Current=wimst
```
