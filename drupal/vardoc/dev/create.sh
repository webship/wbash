#!/bin/usr/env bash

echo "                                                                        ";
echo "  ######################################################################";
echo "  #                     Vardoc Development                             #";
echo "  ######################################################################";
echo "   

## Grab local development directory path for the project argument.
unset full_local_project_path ;
while [[ ! -d "${full_local_project_path}" ]]; do

  echo "Full local project path:";
  read full_local_project_path;

  if [[ ! -d "${full_local_project_path}" ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   Full local project folder is not a valid path!";
    echo "      This should be the full path for the root project folder";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grab project machine name argument.
unset project_name ;
while [[ ! ${project_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; do

  echo "Project machine name:";
  read project_name;

  if [[ ! ${project_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   Project Machine Name is not a valid project name!";
    echo "---------------------------------------------------------------------------";
  fi
done

# Change directory to the workspace for this full operation.
cd ${full_local_project_path};

# Create project with composer.
composer create-project vardot/vardoc-project:8.4.x-dev ${project_name} --stability dev --no-interaction -vvv
