# OfflineIMAP Docker

An opinionated set of simple docker containers containing OfflineIMAP and Supercronic.


## Usage

Being slightly opinionated there isn't any `ENTRYPOINT` specified, instead only a default `CMD` to run Supercronic with the bundled `/etc/crontab` file that simply echos a short message once a minute. This means you can easily change what the container does without having to override an `ENTRYPOINT`, and if you want to use the Supercronic functionality you only need to mount in your own crontab file at `/etc/crontab` and run the container without any additional args.


## Image variants

Currently the following distributions are included:

 - Alpine 3.10
 - Debian 10.7 (Slim variant)
 - Ubuntu 20.04 (LTS release)


## Supported architectures

Currently the following architectures are built for each image variant:

 - linux/amd64
 - linux/arm64
 - linux/arm/v7


# Why another OfflineIMAP Docker Image

There was already a number of OfflineIMAP images available on the Docker Hub, but unfortunately they all had their various short comings. Most weren't built via a Continuous Integration tool, almost none had any image tags, and all had some completely unnecessary `ENTRYPOINT` script. Thus I decided to make my own set of images for OfflineIMAP, and here we are.
