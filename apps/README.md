# Applications

This is just information surrounding applications hosted on local network. All installation and configuration will be found in the [Docker Ecosystem](../docker/) section.

### Anchore

Since docker is heavily utilized, both for development and local services/applications, I need a way to scan images and containers for vulnerabilities. [Anchore's open source offering](https://anchore.com/opensource/) is used to this end, which will also expose the service to the local network allowing my other machiens to utilize the service as well. 

Anchore consumes CVE's from various upstream sources, maintaining a PostgreSQL database as persistent storage for the vulnerability data. Anchore-cli is used to interact with the main engine, which lends itself inherently to scripting (think CI/CD). Once you add an image to the engine, it is dissected and analyzed as documented [here](https://docs.anchore.com/current/docs/overview/concepts/images/analysis/). 

### Plex

Plex is a client-server media player system used to organize and stream video, audio and photos. I've finally started to convert my dvd/blu-ray collection into digital format and needed a way to store/stream them on local network. Plex allows you to simply tell it where your data is stored, so I can utilize mirrored ZFS VDEVs to provide one layer of redundancy.

### TeamCity

TeamCity is a free CI/CD offering from JetBrains, the makers of PyCharm and a myriad of other great IDE's. TeamCity can be deployed and managed easily with `docker-compose` and configured via GUI.
