#!/bin/bash

# set perms chmod us+x ./scripts/package.sh

### commandline options to:
# 1) -p <package id> This is required


# print message function
printMsg() {
  echo ""
  date +"%T $*"
}

printError() {
  echo "Error:"
  date +"%T $*"
}

clearFolders () {
  printMsg "Removing Packaging Folder"
  find "./packaging/" -exec rm -rf {} \;

  if [ $? -gt 0 ]
  then
    printMsg "Creating Packaging Folder"
    sleep 3s
    mkdir "./packaging/"
  fi
}


copyFolders () {
  printMsg "Copying Files for Packaging"
  DIR="./packaging/"
  ROOT="./force-app/main/default"

  cp -R $ROOT/brandingSets $ROOT/communityTemplateDefinitions $ROOT/communityThemeDefinitions $ROOT/components $ROOT/classes $ROOT/flexipages $ROOT/pages $ROOT/staticresources $DIR

  printMsg "Copying Files has Completed"
}

packageVersion () {
  printMsg "Listing Package Versions"
  sfdx force:package:version:list -p $PACKAGEID

  printMsg "Creating new Package Version"
  RESULT=$(sfdx force:package:version:create -p $PACKAGEID -f config/project-scratch-def.json -c -x --json --wait $WAIT)

  STATUS=$(echo $RESULT | jq .status -r)
  printMsg $RESULT

  if [ $STATUS -eq 0 ]
  then
    printMsg "The Package was Created Successfully: $(echo $RESULT | jq .result.Package2VersionId -r)"
  else
    printMsg "The Package Creation Failed"
  fi
}

PACKAGEID=none
WAIT=15

while [[ $# > 1 ]]
do
    key="$1"

    case $key in
    -p)
        PACKAGEID="$2"
        shift # past argument
        ;;
    *)
        # unknown option
        ;;
    esac
shift # past argument or value
done

clearFolders
copyFolders
packageVersion