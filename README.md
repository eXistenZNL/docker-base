# eXistenZ Base Image

My base image, which holds the user switcher functionality. My other images are based on this.

[![](https://badge.imagelayers.io/existenz/base:latest.svg)](https://imagelayers.io/?images=existenz/base:latest 'Get your own badge on imagelayers.io')

## Why

After playing around with Docker I found one mayor drawback to the whole Docker approach: the software in the container either runs as root or as a predetermined user with a fixed user ID that cannot be changed afterwards. This creates problems when reading from and writing to mounted data volumes, which have a user with a specific user ID on the host.

I created a boot script that solves this, so the end user running my images can decide what user and group the software container should run as. Gone are the problems with access permissions, and all was good again.

## Usage

This is best done by example. Let's create the following Dockerfile:
```
FROM existenz/base
apk -u add apcupsd && rm -rf /var/cache/apk/*
ENTRYPOINT ["runas", "apcupsd"]
```

We then build it as example/example with `docker build -t example/example.`.

In our example, we have a system user on our host with name 'monitoring', user id 1006, belonging to primary group 'services' with group id 1204, and we want to run apcupsd as that user and group.

Because we set the entrypoint to runas instead of the direct command, we can now easily run our docker instance like so:

```
docker run \
  --name=apcupsd \
  -e UID=1006 -e GID=1204 \
  example/example
```

Note that both UID and GID are optional:
* If UID is missing, this will default to 1000 (default id of first user on Linux)
* If GID is missing, this will default to the UID.

## How

I created this image based on the super small [Alpine Linux](https://www.alpinelinux.org/) image which can be found [here](https://hub.docker.com/_/alpine/), which is only 5MB in size. It only holds the runas script, which picks up the provided environment variables, creates a user and group 'app' with the specified ids, and runs the software in the container as this user.

The beauty of this is that users inside the container are mapped by id to users outside on the host. So when viewed from the host, the app is actually running as user apcupcd in our example, and this little mapping solves our permission problems because it's like the app was started by that user.

## Image layout

In the image, a few directories are used for specific purposes:

* /app: this is where the app code can live, if any.
* /cwd: this is directory we switched to by the `WORKINGDIR` directive in the Dockerfile. Is meant for mounting `$(pwd)` on, in case of applications that need access to the current working dir.
* /home: A lot of apps store their config in your home directory. Simply mount (a subfolder of) your homedir on /home to let the app do it's magic.

These directories are not defined as Docker volumes to prevent Docker from creating unneeded directories in /var/lib/docker/volumes, but instead are created by runas if missing, and set to the right owner.

A good example on using /pwd and /home can be found in my [Composer image](https://hub.docker.com/r/existenz/composer/).

## Bugs, questions, and improvements

If you found a bug or have a question, please open an issue on the GitHub Issue tracker. Improvements can be sent by a Pull Request against the develop branch and are greatly appreciated!
