#!/bin/usr/env bash

################################################################################
## Behat UI Drupal
################################################################################
## Setup Behat UI module and configs for Drupal projects.
##
##
## -----------------------------------------------------------------------------
## cd /var/www/html/myproject
## Run the following command.
## bash <(wget -O - https://raw.githubusercontent.com/webship/wbash/v1/behat_ui/drupal10.sh)
##------------------------------------------------------------------------------
##
##
################################################################################

## Package Name.
package_name="Drupal";
webroot="web";

## Behat UI package template source.
behat_ui_template_source="https://github.com/webship/drupal10-behat_ui-template/archive/refs/tags/1.0.0";
behat_ui_template_name="drupal10-behat_ui-template";

## Package template version.
version="1.0.0" ;

## Default Selenium host.
default_selenium_host='127.0.0.1:4444/wd/hub';

## Read the IP address, geteway and local iface.
unset local_gateway;
unset local_iface;
unset local_ip;
read -r _{,} local_gateway _ local_iface _ local_ip _ < <(ip r g 1.0.0.0) ;

echo "                                                                            ";
echo "  ###########################################################################";
echo "    Web Interactive Command to setup Behat UI for ${package_name}";
echo "  ###########################################################################";
echo "    ${behat_ui_template_name} version ${version}";
echo "  ---------------------------------------------------------------------------";
printf '%-12s %s\n'  gateway $local_gateway iface $local_iface ip $local_ip ;
echo "  ---------------------------------------------------------------------------";

current_path=$(pwd) ;
current_project_name_from_path=${PWD##*/} ;

## Project machine name.
project_machine_name='^[A-Za-z][A-Za-z0-9_]*$';

## Absolute IRIs (internationalized) URL format.
url_format='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]';

## Domain name format with no protocal.
domain_format='[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]';

## Grab local development directory path for the project argument.
unset local_project_path ;
while [[ ! -d "${local_project_path}" ]]; do

  read -p "Full local project path (${current_path}): " local_project_path;

  if [ -z "$local_project_path" ]
  then
    local_project_path=${current_path};
  fi

  if [[ ! -d "${local_project_path}" ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   ${package_name} full local project folder is not a valid path!";
    echo "      This should be the full path for the root project folder";
    echo "---------------------------------------------------------------------------";
  fi
done

## Read the project machine name argument.
unset project_name ;
while [[ ! ${project_name} =~ $project_machine_name ]]; do

  read -p "Project machine name (${current_project_name_from_path}): " project_name;

  if [ -z "$project_name" ]
  then
    project_name=${current_project_name_from_path};
  fi

  if [[ ! ${project_name} =~ $project_machine_name ]]; then
    echo "---------------------------------------------------------------------------";
    echo "  ${package_name} Project Machine Name is not a valid project name!";
    echo "---------------------------------------------------------------------------";
  fi
done

## Read the project base url argument.
unset project_base_url;
while [[ ! ${project_base_url} =~ $url_format ]]; do

  read -p "Project base testing url ( http://$local_ip/${project_name}/${webroot} ) : " project_base_url;

  if [ -z "$project_base_url" ]
  then
    project_base_url="http://$local_ip/${project_name}/${webroot}";
  fi

  if [[ ! ${project_base_url} =~ $url_format ]]; then
    echo "---------------------------------------------------------------------------";
    echo "  The Project base url is not a valid ${package_name} project link !";
    echo "---------------------------------------------------------------------------";
  fi
done

## Read the Selenium host domain argument.
unset selenium_host;
while [[ ! ${selenium_host} =~ $domain_format ]]; do

  read -p "Selenium Host domain ( ${default_selenium_host} ): " selenium_host;

  if [ -z "$selenium_host" ]
  then
    selenium_host=${default_selenium_host};
  fi

  if [[ ! ${selenium_host} =~ $domain_format ]]; then
    echo "---------------------------------------------------------------------------";
    echo "  The Project base url is not a valid ${package_name} project link !";
    echo "---------------------------------------------------------------------------";
  fi
done

## Change directory to the local project path.
cd $local_project_path ;

## Delete the composer.lock file.
rm composer.lock

## Add bin direcoty to the Drupal site.
composer config bin-dir bin

## Add needed testing packages by composer.

composer require --dev drupal/core-dev:~10.0 --with-all-dependencies
composer require --dev drush/drush:~11.0
composer require --dev drupal/drupal-extension:~5.0 --with-all-dependencies
composer require --dev webship/behat-html-formatter:~1.0
composer require --dev drevops/behat-screenshot

## Add Behat UI module by composer.
composer require --dev drupal/behat_ui:~5.0;


## Remove leftover or old downloaded files.
if [[ -f "${local_project_path}/${version}.tar.gz" ]]; then
  rm ${local_project_path}/${version}.tar.gz ;
fi

## Remove leftover or old folder.
if [[ -d "${local_project_path}/${version}" ]]; then
  sudo rm -rf ${local_project_path}/${version} ;
fi

## Remove the old behat.yml file.
if [[ -f "${local_project_path}/behat.yml" ]]; then
  rm ${local_project_path}/behat.yml;
fi

## Remove the old features folder.
if [[ -d "${local_project_path}/features" ]]; then
  sudo rm -rf ${local_project_path}/features ;
fi

## Download The Behat UI template for the package.
wget ${behat_ui_template_source}/${version}.tar.gz;

## Create a temp folder using the same version value.
mkdir ${local_project_path}/${version};

## Extract the package template tar file and place it's content into the target temp version folder.
tar -xzvf ${local_project_path}/${version}.tar.gz --strip 1 --directory=${local_project_path}/${version};

## Place features folder in its target path.
mv ${local_project_path}/${version}/features ${local_project_path}/features;

## Place behat.yml file in its target path.
mv ${local_project_path}/${version}/behat.yml ${local_project_path}/behat.yml;

## Clean up the tar and temp folder.
sudo rm -rf ${local_project_path}/${version}.tar.gz ${local_project_path}/${version} ;

## Clean the wget log files. 
sudo rm -rf ${local_project_path}/wget-log* ;

# Replace DRUPAL_PROJECT_PATH with the project path.
grep -rl "DRUPAL_PROJECT_PATH" ${local_project_path}/features | xargs sed -i "s|DRUPAL_PROJECT_PATH|${local_project_path}|g" ;

# Replace PROJECT_NAME with the machine name of the project folder name.
grep -rl "PROJECT_NAME" ${local_project_path}/features | xargs sed -i "s|PROJECT_NAME|${project_name}|g" ;

# Replace PROJECT_BASE_URL of Project URL.
sed -i "s|PROJECT_BASE_URL|${project_base_url}|g" ${local_project_path}/behat.yml;

# Replace SELENIUM_HOST with the current selected selenium host domain.
sed -i "s|SELENIUM_HOST|${selenium_host}|g" ${local_project_path}/behat.yml;

# Copy the Behat UI settings file to the config install before installing the module.
cp features/behat_ui.settings.yml web/modules/contrib/behat_ui/config/install/

# Make package files writable to export reports
cd $local_project_path ;
sudo chmod 775 -R .; sudo chown www-data:tasneem -R .

# Remove (goutte: ~).
sed -i "s|goutte: ~||g" ${local_project_path}/behat.yml;