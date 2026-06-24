# Too Many Open files

## The error

```txt
failed to create fsnotify watcher: too many open files
```

## Why?

One of the [inotify limit](#limits) has been reached
by the k3s user (ie `root`)

## Concept

### Watch descriptors (WD)

A `watch descriptor (WD)` is an unique integer handle returned by the inotify
when a process asks the kernel to watch a file or directory for changes.

This is required for each directory:

* 1 watched directory = 1 watch descriptor
* 10,000 watched directories = 10,000 watch descriptors

### Limits

#### inotify.max_user_watches

`fs.inotify.max_user_watches`: the maximum number of [watch descriptors](#watch-descriptors-wd) a user can create (not
per process)

Default value (1% memory): `inotify.max_user_watches` is calculated to make use no more
than `1%` of addressable memory within the range `8192, 1048576`.
https://github.com/torvalds/linux/commit/92890123749bafc317bbfacbe0a62ce08d78efb7

#### inotify.max_user_instances

`inotify.max_user_instances` Maximum number of inotify instances a user can create.

Each program that wants to watch files creates one instance first, then adds watches to it.

## Steps

### Check the log

If you can't watch, you can't follow a file, so you cannot also follow the journal
of `k3s`

Executing the below command should output as first line: `Insufficient watch descriptors available. Reverting to -n.`

```bash
journalctl --unit=k3s --follow
```

If this is the case, we need to [check the limits](#check-the-limits)

If not, check the `fsnotify` message

```bash
journalctl --unit=k3s --since "10 minutes ago" | grep -A5 -B5 fsnotify
```

### Check the Limits

* Check the max_user_watches current limit:

```bash
cat /proc/sys/fs/inotify/max_user_watches
# 60123
sudo sysctl fs.inotify.max_user_watches
#fs.inotify.max_user_watches = 60123
```

Check the max_user_instances current limit

```bash
cat /proc/sys/fs/inotify/max_user_instances
# 128
sudo sysctl fs.inotify.max_user_instances
# fs.inotify.max_user_instances = 128
```

### Check the actual value

https://github.com/fatso83/dotfiles/blob/master/utils/scripts/inotify-consumers

```bash
curl -s https://raw.githubusercontent.com/fatso83/dotfiles/713ea5547903ee49428f8130af5ab2c956471914/utils/scripts/inotify-consumers | bash
 
```

Example of output, showing a `max_user_instances` reached:

```txt
INotify instances per user (e.g. limits specified by fs.inotify.max_user_instances):
INSTANCES    USER
-----------  ------------------
126          root
```

### Increase the limit and test

If `max_user_instances` was reached, double it

```bash
# temporally
sysctl -w fs.inotify.max_user_instances=256
```

Check that you don't get any error with a journal follow:

```bash
journalctl --unit=k3s --follow
# no more: Insufficient watch descriptors available. Reverting to -n. 
```

```bash
cat >> /etc/sysctl.d/99-k3s-inotify.conf << 'EOF'
fs.inotify.max_user_instances = 256
EOF
```

### Save them permanentyly, if successfully

If successful, you can set them in your `cluster values file`.
They will be set when running the `kubee cluster play` command

Example:
```yaml
k3s_ansible:
  hosts:
    servers:
      - fqdn: 'sub.domain.com'
        ip: 'x.x.x.x'
        inotify_max_user_instances: '256'
        inotify_max_user_watches: '120246'
```