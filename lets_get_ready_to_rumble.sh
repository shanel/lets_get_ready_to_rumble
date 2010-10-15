#!/bin/bash
#
# <UDF name="ree_file" Label="Ruby Enterprise Edition File" default="http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz" example="http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz" />
# <UDF name="ree_version" Label="Ruby Enterprise Edition Version" default="1.8.7-2010.02" example="1.8.7-2010.02" />
# <UDF name="install_prefix" Label="Install Prefix for REE and Passenger" default="/opt/local" example="/opt/local will install REE to /opt/local/ree" />
# <UDF name="rr_env" Label="Rails/Rack environment to run" default="production" />
# <udf name="ubuntu_mirror" label="ubuntu mirror url" default="http://us.archive.ubuntu.com/ubuntu">
# <udf name="tmpdir" label="tmp dir (to download & compile)" default="/var/tmp">

exec &> /root/stackscript.log

source <ssinclude StackScriptID=1>
source <ssinclude StackScriptID=904>

system_update


  REE_NAME="ruby-enterprise-$REE_VERSION"
  REE_FILENAME="$REE_NAME.tar.gz"

  # Set up Ruby Enterprise Edition
  # Dependencies
  apt-get -y install build-essential zlib1g-dev libssl-dev libreadline5-dev

  echo "REE_FILENAME = $REE_FILENAME"
  echo "REE_DOWNLOAD = $REE_FILE"
  echo "Sleeping for 10" && sleep 10

  # Download
  cd       "$TMPDIR"
  wget     "$REE_FILE" -O "$REE_FILENAME"
  tar xzf  "$REE_FILENAME"
  cd       "$REE_NAME"

  # Install
  ./installer --auto="$INSTALL_PREFIX/$REE_NAME"
  ln -s "$INSTALL_PREFIX/$REE_NAME" "$INSTALL_PREFIX/ree"

  # Add REE to the PATH
  PATH="$INSTALL_PREFIX/ree/bin:$PATH"


# Install Apache and Passenger

#!/bin/bash


# install required apache packages
apt-get install -y apache2 apache2-mpm-prefork apache2-prefork-dev libapache2-mod-passenger


echo "Building apache2 passenger module..."
if [ -n "`passenger-install-apache2-module --auto | grep 'Some required software not installed'`" ]; then
  echo "Failed to install passenger. Skipping the rest... :("
  exit 1
fi

if [ ! -n "`gem search passenger | awk '{ print $1 }'`" ]; then
  echo "Installing passenger gem"
  gem install passenger --no-ri --no-rdoc
  echo "Done!"
fi

PASSENGER_ROOT=`passenger-config --root`


echo "Enabling passenger module..."

echo -e "# Automatically generated configuration for passenger module\n\n\
LoadModule passenger_module $PASSENGER_ROOT/ext/apache2/mod_passenger.so\n\
PassengerRoot $PASSENGER_ROOT" > /etc/apache2/mods-available/passenger.load

a2enmod passenger

apache2ctl restart

echo "All done!"

# # Set up Nginx and Passenger
#   passenger-install-nginx-module --auto --auto-download --prefix="$INSTALL_PREFIX/nginx"
# 
# # Configure nginx to start automatically
#   ln -s "$INSTALL_PREFIX/nginx" "/opt/nginx"
#   wget http://library.linode.com/web-servers/nginx/installation/reference/init-deb.sh
#   mv init-deb.sh /etc/init.d/nginx
#   chmod +x /etc/init.d/nginx
#   /usr/sbin/update-rc.d -f nginx defaults

# Install mongodb-stable
  echo "deb http://downloads.mongodb.org/distros/ubuntu 10.4 10gen" >> /etc/apt/sources.list
  apt-get update
  apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
  # Secure but failing:
  #   echo "MONGO_DB_PUB_KEY" | apt-key add -
  apt-get -y install mongodb-stable
  # Insecure but working:
  # apt-get -y --force-yes install mongodb-stable
  /etc/init.d/apache2 start

# Install git
  apt-get -y install git-core

# Set up environment
  # Global environment variables
  cat > /etc/environment << EOF
PATH="$PATH"
RAILS_ENV="$RR_ENV"
RACK_ENV="$RR_ENV"
EOF

# # Install Rails 3
#   # Update rubygems to (=> 1.3.6 as required by rails3)
#   gem update --system
#   # Install pre-requirements
#   gem install tzinfo builder memcache-client rack rack-test rack-mount erubis mail text-format thor bundler i18n --no-ri --no-rdoc
#   gem uninstall -x rails
#   gem install rails --pre --no-ri --no-rdoc

# Install Rails 3
  # Install pre-requirements
  gem install rails -v '~> 3.0.0'

# # Add rails user
#   echo "rails:rails:1000:1000::/home/deploy:/bin/bash" | newusers
#   cp -a /etc/skel/.[a-z]* /home/rails/
#   chown -R rails /home/rails
#   # Add to sudoers(?)
#   echo "rails    ALL=NOPASSWD: ALL" >> /etc/sudoers



# Add deploy user
  echo "deploy:deploy:1000:1000::/home/deploy:/bin/bash" | newusers
  cp -a /etc/skel/.[a-z]* /home/deploy/
  chown -R deploy /home/deploy
  # Add to sudoers(?)
  echo "deploy    ALL=(ALL) ALL" >> /etc/sudoers

# install integrity

gem install bundler
git clone git://github.com/integrity/integrity
cd integrity
git checkout -b deploy v22
bundle install
bundle lock
rake db
git fetch origin
git merge origin/v22
bundle exec rackup

	# Spit & polish
	  goodstuff
	  restartServices
	  log "StackScript Finished!"
