#!/bin/usr/env bash

################################################################################
## Webship JS
################################################################################
##
## cd /var/www/html/myproject
## Run the following command.
## bash <(wget -O - https://raw.githubusercontent.com/webship/wbash/v1/webship-js/webship-js.sh)
##------------------------------------------------------------------------------
##
################################################################################

## Package Name.
package_name="Project";

## Cucumber UI package template source.
template_source="https://github.com/webship/webship-js-template/archive/refs/tags";
template_name="webship-js-template";

## Package template version.
version="1.0.3" ;

## Default Selenium host.
default_selenium_host='127.0.0.1:4444/wd/hub';

## Read the IP address, geteway and local iface.
unset local_gateway;
unset local_iface;
unset local_ip;
read -r _{,} local_gateway _ local_iface _ local_ip _ < <(ip r g 1.0.0.0) ;

echo "                                                                            ";
echo "  ###########################################################################";
echo "    Web Interactive Command to setup Webship JS for ${package_name}";
echo "  ###########################################################################";
echo "    ${template_name} version ${version}";
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

  read -p "Project base testing url ( http://$local_ip/${project_name} ) : " project_base_url;

  if [ -z "$project_base_url" ]
  then
    project_base_url="http://$local_ip/${project_name}";
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

## Remove leftover or old downloaded files.
if [[ -f "${local_project_path}/${version}.tar.gz" ]]; then
  rm ${local_project_path}/${version}.tar.gz ;
fi

## Remove leftover or old folder.
if [[ -d "${local_project_path}/${version}" ]]; then
  sudo rm -rf ${local_project_path}/${version} ;
fi

## Remove the old nightwatch.conf.js file.
if [[ -f "${local_project_path}/nightwatch.conf.js" ]]; then
  rm ${local_project_path}/nightwatch.conf.js;
fi

## Remove the old package.json file.
if [[ -f "${local_project_path}/package.json" ]]; then
  rm ${local_project_path}/package.json;
fi

## Remove the old generate-reports.js file.
if [[ -f "${local_project_path}/generate-reports.js" ]]; then
  rm ${local_project_path}/generate-reports.js;
fi

## Remove the old tests folder.
if [[ -d "${local_project_path}/tests" ]]; then
  sudo rm -rf ${local_project_path}/tests ; 
fi

## Download The Cucumber UI template for the package.
wget ${template_source}/${version}.tar.gz;

## Create a temp folder using the same version value.
mkdir ${local_project_path}/${version};

## Extract the package template tar file and place it's content into the target temp version folder.
tar -xzvf ${local_project_path}/${version}.tar.gz --strip 1 --directory=${local_project_path}/${version};

## Change /tests folder to be writable. 
sudo chmod 775 -R .; sudo chown www-data:$USER -R .;

## Place tests folder in its target path.
mv ${local_project_path}/${version}/tests ${local_project_path}/tests;

## Place package.json file in its target path.
mv ${local_project_path}/${version}/package.json ${local_project_path}/package.json;

## Place generate-reports.js file in its target path.
mv ${local_project_path}/${version}/generate-reports.js ${local_project_path}/generate-reports.js;

## Place nightwatch.conf.js file in its target path.
mv ${local_project_path}/${version}/nightwatch.conf.js ${local_project_path}/nightwatch.conf.js;

# Replace PROJECT_BASE_URL with the Project URL.
grep -rl "PROJECT_BASE_URL" ${local_project_path}/nightwatch.conf.js | xargs sed -i "s|PROJECT_BASE_URL|${project_base_url}|g" ;

## Clean up the tar and temp folder.
sudo rm -rf ${local_project_path}/${version}.tar.gz ${local_project_path}/${version} ;

## Clean the wget log files. 
sudo rm -rf ${local_project_path}/wget-log* ;