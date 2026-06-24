# K3s fatal error

The steps to follow when the k3s service won't start

## Steps

### Check the config

Resolve of fail of a `k3s check-config`

```bash
k3s check-config
# you can ignore modprobe: FATAL: Module configs not found (see above)
```

Example of fail

```bash
Generally Necessary:
- apparmor: enabled, but apparmor_parser missing (fail)
    (use "apt-get install apparmor" to fix this)
```

> Note that
> ```bash
> modprobe: FATAL: Module configs not found in directory /lib/modules/6.1.0-23-amd64
> ```
>
> where: `6.1.0-23-amd64` is the output of `uname -r`
>
> It's not really fatal, this is a red herring. There is no kernel module missing.
> System verification needs to find the kernel configuration file and canot find it.
>
> If:
>
> * the configuration file cannot be found,
> * there is no configs module,
    > system verification check will just error out.
>
> See: https://github.com/kubernetes/kubernetes/issues/41025

### Check the system service unit

Check the validity of the system service unit.

Grab the k3s command issued and execute it on a shell.

```bash
cat /etc/systemd/system/k3s.service
```

Example:

```properties
ExecStart=/usr/local/bin/k3s server '--disable=traefik'
```

### Journal / Status / Log

When running under Systemd, [logs](https://docs.k3s.io/faq#where-are-the-k3s-logs)
are sent to Journald and can be viewed using `journalctl`.

```bash
sudo systemctl status k3s.service
# Last 50
journalctl -u k3s.service -n 50
# tail
journalctl -u k3s.service -f
# log since the last machine boot
journalctl -u k3s.service -b
```

You can generate more detailed logs by using the `--debug` flag when starting K3s
(or debug: true in the configuration file).

### Check the known-issues

If no clue: https://docs.k3s.io/known-issues

## Once resolved

### Check alive / cluster info

```bash
# on server
k3s kubectl cluster-info
# on client
kubee -c kubectl cluster-info
```

