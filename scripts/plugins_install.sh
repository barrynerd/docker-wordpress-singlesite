#!/bin/bash

# pick up the environment variables from the .env file
# and export them to the current shell
# This is necessary for the docker compose command to work
# without having to pass them as arguments
set -a
source .env
set +a

set -e


# Read the input file line by line
mapfile -t plugins < ${INSTALL_PLUGINS_FILE}

for plugin in "${plugins[@]}"
do
    if [[ ${plugin:0:1} == "#" ]] ; then
        if [ "$INSTALL_PLUGINS_SHOW_COMMENTS" == "true" ] ; then
            echo "🚫 Skipping $plugin"
        fi
    else
        echo $plugin
        if docker compose run --rm wpcli plugin is-installed $plugin; then
            echo "✅ $plugin is already installed."
        else
            echo "🚀 Installing $plugin..."
            docker compose run --user 33:33 --rm wpcli plugin install $plugin --activate
        fi
    fi
done
echo "✅ Plugin installation completed."