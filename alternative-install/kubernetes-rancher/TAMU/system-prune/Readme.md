# scheduled-docker-system-prune

Runs docker system prune on an interval

## How it works
Runs the command `docker system prune --all --force` via the hosts docker.sock on an interval.

## How to use

`docker run -d -v /var/run/docker.sock:/var/run/docker.sock -e "DELAY_TIME=1600" scheduled-docker-system-prune`