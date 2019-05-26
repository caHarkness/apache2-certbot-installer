# apache2-certbot-installer

## How to use

1. Edit `settings.sh` and change the configuration to match your server's directory layout.
2. Edit `sites.list` and create an entry for each domain you wish to host a separate website for.
3. Run `install.sh` as root.

The install script will warn when it's about to delete sensitive data. When you add or remove entries from the `sites.list` file, you will need to run `install.sh` again.