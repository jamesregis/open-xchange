# Open-xchange containerized version

This project lets you run OpenXchange in containers. The aim was to remove all the configuration, maintenance and updating from a machine.

## Quickstart

For now `podman`  package must be installed before.
Before launching the container, you must first:
 1. Create local folders to store data (it's mandatory if you want to have a persistent configuration)
    `mkdir -p /home/user/open-xchange-data/{etc,share,logs/mariadb}`

 2. Edit [Pod.yml](Pod.yml) and set the correct path for `.spec.containers.volumes`:
```
  volumes:
    - HostPath:
        path: /home/user/open-xchange/etc
        type: Directory
      name: openxchange-etc
    - HostPath:
        path: /home/user/open-xchange/share
        type: Directory
      name: openxchange-share
    - HostPath:
        path: /home/user/open-xchange/logs
        type: Directory
      name: openxchange-logs
    - HostPath:
        path: /home/user/open-xchange/mariadb
        type: Directory
      name: openxchange-mariadb
```

Once done, you should be able to run this command: 

```
podman kube play --publish-all Pod.yml
```

## Example users and context

`create-default-context-and-user.sh` should be run to create an `example context and user` with the following default credentials :

`login: john@example.com` and `password: tototiti001` .


## Screenshots
![image](https://github.com/jamesregis/open-xchange/assets/31738740/80bbf7c8-87d3-4b7b-a4e6-44b4c6d2cf09)


