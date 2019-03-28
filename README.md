# Docker Nao

Executing ChoreGraphe, NaoQi and some other tools (maybe...FluentNAO) inside containers to avoid library requirements problems

This version executes Choregraphe and NaoQI version 2.1.4.13 for compatibility with the NAO robot of my school.

## Running

At first, you need to download and install the `docker-compose` software.

After that, just clone the repo and issue:

  `$ docker-compose start`

and let the Docker magic happens ;-)

## Troubleshooting

I think most problems can happen if the X11 socket directory is not located in `/tmp/.X11-unix/` directory,
in that case you have to change volume binding in `docker-compose.yml`

Another problem can be executing the container with an user id different from 1000 which is the default
and wide used in most GNU/Linux OS. To check your id use the command `id` from a terminal.
If your id is different from 1000 you must change Dockerfile and follow the instructions on rebuilding the image.

## Rebuilding

You don't need this unless you know what you are doing.

To rebuild the image you need to download choregraphe 2.1.4.13 for linux 64bit binaries and NAOqi SDK C++ and SDK Python
[provided by SoftBank Robotics](https://community.ald.softbankrobotics.com/en/resources/software/language/en-gb/robot/nao-2/field_soft_version%253Afield_soft_version_code_version/2%252E1%252E4),
and save them under the `SDK/` directory

Then issue the command:

    `docker-compose build coregraphe`


NOTE: to download Choregraphe and SDK you need to sign in on the SoftBank Robotics website.

