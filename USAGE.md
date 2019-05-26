# How to use
* Edit `settings.sh` and change the configuration to match your server's directory layout.
* Edit `sites.list` and create an entry for each domain you wish to host a separate website for.
* Run `install.sh` as root.

# Optional
* Issue the commands `a2enmod ssl` and `a2enmod rewrite`

# Updating the SSL certificates alone
* Issue `./update-www-ssl.sh $(./list-www.sh)` as root in the cloned directory.