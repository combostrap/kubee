---
title: Unable to connect/ping to the cluster hosts (via SSH or Ansible connection)?
---

Executing a `ping` command on the cluster is not successful. ie executing:

```bash
kubee --cluster "$KUBEE_CLUSTER_NAME" cluster ping
```

returns:

```txt
serverHostname | UNREACHABLE! => {
    "changed": false,
    "msg": "Task failed: Failed to connect to the host via ssh: xxx",
    "unreachable": true
}
```

The below steps will show you how to debug it.

## Steps

### Conceptually, how it works?

The `KUBEE_INFRA_CONNECTION_PRIVATE_KEY` or `KUBEE_INFRA_CONNECTION_PRIVATE_KEY_FILE`
will pass the key to Ansible by setting
the [ANSIBLE_PRIVATE_KEY_FILE variable](https://docs.ansible.com/projects/ansible/latest/reference_appendices/config.html#default-private-key-file)
if not yet set.

```bash
# /dev/shm for a temporary key
export ANSIBLE_PRIVATE_KEY_FILE="/dev/shm/ssh-key"
```

Then, ansible is creating an SSH command using it as `IdentityFile`
to connect via the IP (not by DNS name).

Below we show you how to get the command.

### Get the ansible ssh connection command with the debug flag

Executing:

```bash
kubee --debug --cluster "$KUBEE_CLUSTER_NAME" cluster ping
```

will show you the ssh connection.

Example:

```
<x.x.x.x> ESTABLISH SSH CONNECTION FOR USER: root
<x.x.x.x> SSH: EXEC ssh -C -o ControlMaster=auto -o ControlPersist=60s -o 'IdentityFile="/dev/shm/ssh-key"' -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="root"' -o ConnectTimeout=10 -o 'ControlPath="/home/admin/.ansible/cp/3d78f1b2a9"' -o NumberOfPasswordPrompts=1 x.x.x.x '/bin/sh -c '"'"'echo ~root && sleep 0'"'"''                                                    
```

### Replace Identity file and execute the command

Replace the generated identity file ie (`IdentityFile="/dev/shm/ssh-key"`) with your own
and execute it:

Example:

```bash
# pass your key
pass kubee/myssh-key >| "/dev/shm/ssh-key"
# then execute
ssh -C -o ControlMaster=auto -o ControlPersist=60s -o 'IdentityFile="/dev/shm/ssh-key"'  \
  -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey  \
  -o PasswordAuthentication=no -o 'User="root"'  \
  -o ConnectTimeout=10 -o 'ControlPath="/home/admin/.ansible/cp/3d78f1b2a9"'  \
  -o NumberOfPasswordPrompts=1 x.x.x.x
# then delete it
rm "/dev/shm/ssh-key"
```

Example of error:

```txt
The authenticity of host 'x.x.x.x (x.x.x.x)' can't be established.
ED25519 key fingerprint is: SHA256:yXEFAx6yZfvnsYmHusP5aECfLba/WxN04DafneUTDIE
This host key is known by the following other names/addresses:
    ::52: cluster-server-hostname.tld
Are you sure you want to continue connecting (yes/no/[fingerprint])? y
Please type 'yes', 'no' or the fingerprint: yes
Warning: Permanently added 'x.x.x.x' (ED25519) to the list of known hosts.
```

