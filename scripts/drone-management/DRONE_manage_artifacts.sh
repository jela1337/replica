#!/bin/bash
remoteRepo="https://github.com/jela1337/replica.git"
artifactDirPath="/mnt/replica.one"
numberOfPipelines="3";

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && containsElementOutput=0 && return 0; done
  containsElementOutput=1
  return 1
}

# get and slugify branch names
branchesArray=($(git ls-remote --heads ${remoteRepo} | xargs -n 2 echo | sed 's,.*refs/heads/,,' \
| iconv -t ascii//TRANSLIT | sed -r s/[~\^]+//g | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z))
if [[ "${#branchesArray[@]}" -eq "0" ]]; then
    echo "Array is empty. Could not get information on branches. Network?"
    exit 1
fi

# remove deleted branches and more than N pipelines
for branch in ${artifactDirPath}/*
do
    containsElement "${branch##*/}" "${branchesArray[@]}"
    if [[ "$containsElementOutput" -eq "1" ]]; then
        rm -rf "${artifactDirPath}/${branch##*/}"
    else
        if [ ${numberOfPipelines} -lt  $(ls -t "${artifactDirPath}/${branch##*/}/" 2>/dev/null | wc -l) ]; then
            ls -t "${artifactDirPath}/${branch##*/}/" | sed -e "1,${numberOfPipelines}d" | xargs -d '\n' -n 1 echo \
            | sed -e "s,^,${artifactDirPath}/${branch##*/}/," | xargs -n 1 rm -rf
        fi
    fi
done
