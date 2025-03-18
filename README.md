# hivemq-tooling
Repository for tools around HiveMQ platform

# Install script OSS
The script provide a menu to select which product of HiveMQ and which version needs to be installed : 
- HiveMQ Community Edition
- HiveMQ Edge

The install script has been test with :
- Debian 11
- Debian 12
- Ubuntu 20
- Ubuntu 22
- Ubuntu 24

Execution has to be done with root permissions in order to manipulate the files in /opt and install the service.

```
wget -qO - https://raw.githubusercontent.com/anthonyolazabal/hivemq-tooling/refs/heads/main/Install-Script-OSS/installer.sh | bash
```

# Install script Enterprise
The script automatically install prerequisites and the latest version of HiveMQ Enterprise broker : 

The install script has been test with :
- Debian 11
- Debian 12
- Ubuntu 20
- Ubuntu 22
- Ubuntu 24

Execution has to be done with root permissions in order to manipulate the files in /opt and install the service.

```
wget -qO - https://raw.githubusercontent.com/anthonyolazabal/hivemq-tooling/refs/heads/main/Install-Script-Enterprise/installer.sh | bash
```

