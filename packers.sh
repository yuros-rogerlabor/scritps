#!/bin/env bash

set -e

hoster=./server
conten=./server/content
ghapis=./server/assets/api/github

## PREP

function packers_prepar_engines() {
    echo "--[1] prepare content"
    hugo new site $hoster
    echo $skins
    git clone "https://github.com/almuhdilkarim/${skins}.git" "$hoster/themes/${skins}"
    ls -la &&
    ls -la $hoster/
    ls -la $hoster/themes
}

function packers_prepar_content() {
    echo "--[2] prepare content"
    test -d $hoster/content && rm -fr $hoster/content
    cp -fr ./doc $hoster/content
}




function packers_prepar() {
    packers_prepar_engines
    packers_prepar_content
}



## APIS

function packers_apisgen_prepar() {
    test -d $hoster/assets/api/github/ && rm -fr $hoster/assets/api/github/
    mkdir -p $hoster/assets/api/github
}


function packers_apisgen_reposi() {
    curl -o $ghapis/repo.json https://api.github.com/repos/$github_upstream 
    echo "repo api : $ghapis/repo.json"

}


function packers_apisgen_releas() {
    curl -o $ghapis/rels.json https://api.github.com/repos/$github_upstream/releases 
    echo "rels api : $ghapis/rels.json"
}


function packers_apisgen_contri() {
    curl -o $ghapis/cont.json https://api.github.com/repos/$github_upstream/contributors
    echo "cont api : $ghapis/cont.json"
}


function packers_apisgen_versio() {
    curl -o $ghapis/vers.json https://api.github.com/repos/$github_upstream/releases/latest
    echo "vers api : $ghapis/vers.json"
}


function packers_apisgen_devels() {
    curl -o $ghapis/devs.json https://api.github.com/users/$github_publishe
    echo "devs api : $ghapis/devs.json"
}


function packers_apisgen_packer() {
    curl -o $ghapis/pkgs.json https://api.github.com/repos/$github_packager/contributors
    echo "pkgs api : $ghapis/pkgs.json"
}


function packer_apisgen() {
    packers_apisgen_prepar
    packers_apisgen_reposi
    packers_apisgen_releas
    packers_apisgen_contri
    packers_apisgen_versio
    packers_apisgen_devels
    packers_apisgen_packer
}

## WIKI

function packers_wikigen_takers() {
    test -d ./temp && rm -fr ./temp
    git clone "https://github.com/$github_upstream.wiki.git" ./temp
}



function packers_wikigen_deploy() {

    local list=$( ls ./temp/ )
    local sums=1

    if [[ -z list ]];then
        return
    fi

    mkdir -p $conten/docs

    for article in $list
    do

        if [[ counter == 1 ]]; then
            local file="$conten/docs/_index.md"
        else
            local title=$(echo "$article" | sed 's/.md//g')
            local file="$conten/docs/${title,,}.md"
        fi
        
        echo "---" > "$file"
        echo "title : ${title,,}" >> "$file"
        echo "---" >> "$file"
        cat ./temp/$article >> "$file"

        ((counter++))

    done
}


function packers_wikigen_finish() {

    rm -fr ./temp
}


function packer_wikigen() {
    packers_wikigen_takers &&
    packers_wikigen_deploy &&
    packers_wikigen_finish
}


## BASE
function packer_sitegen_configs() {

    echo "title: $title"        >  $server/hugo.yaml
    echo "baseURL: $hosts"      >> $server/hugo.yaml
    echo "languageCode: $langs" >> $server/hugo.yaml
    echo "theme: $skins"        >> $server/hugo.yaml
}


function packer_sitegen() {
    packer_sitegen_configs
}


## INIT
function packer() {
    packers_prepar
    packer_apisgen
    packer_wikigen
    packer_sitegen
}

packer
