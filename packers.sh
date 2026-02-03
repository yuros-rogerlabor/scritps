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
    rm -fr $hoster/themes/${skins}/content/blog
    rm -fr $hoster/themes/${skins}/content/mans
    rm -f $hoster/themes/${skins}/content/_index.md
}


function packers_prepar_content() {
    echo "--[2] prepare content"
    test -d $hoster/content && rm -fr $hoster/content
    cp -fr ./doc $hoster/content
}


function packer_prepare() {
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

function packers_docsgen_takers() {
    test -d ./temp && rm -fr ./temp
    git clone "https://github.com/$github_upstream.wiki.git" ./temp
}



function packers_docsgen_deploy() {

    local list=$( ls ./temp/ )
    local sums=1

    if [[ -z list ]];then
        return
    fi

    test -d $conten/docs && rm -fr $conten/docs
    mkdir -p $conten/docs

    for article in $list
    do

        if [[ $sums == 1 ]]; then
            local title=$(echo "$article" | sed 's/.md//g')
            local file="$conten/docs/_index.md"
        else
            local title=$(echo "$article" | sed 's/.md//g')
            local file="$conten/docs/${title,,}.md"
        fi
        
        echo "---" > "$file"
        echo "title : ${title,,}" >> "$file"
        echo "---" >> "$file"
        cat ./temp/$article >> "$file"

        ((sums++))

    done

    ls -la $conten/docs
}


function packers_docsgen_finish() {

    rm -fr ./temp
}


function packer_docsgen() {
    packers_docsgen_takers &&
    packers_docsgen_deploy &&
    packers_docsgen_finish
}


## SITE
function packers_mansgen_takers() {

    local file="$conten/mans/_index.md"

    mkdir -p $conten/mans


    curl -o $conten/mans/file.txt $source_linuxman.txt

    echo "---" > "$file"
    echo "title : manual" >> "$file"
    echo "links : file.txt" >> "$file"
    echo "---" >> "$file"
    echo "" >> "$file"

}


function packer_mansgen() {

    echo "man: $source_linuxman"

    if [[ -z $source_linuxman ]];then
        return
    fi

    packers_mansgen_takers
}


## SITE
function packer_sitegen_packcon() {
    test -d $hoster/config && rm -fr $hoster/config
    ls -la $hoster/themes/${skins}
    cp -fr $hoster/themes/${skins}/config $hoster/config
}


function packer_sitegen_sitecon() {

    test -f $hoster/hugo.toml && rm $hoster/hugo.toml

    echo "title: $title"        >  $hoster/hugo.yaml
    echo "baseURL: $hosts"      >> $hoster/hugo.yaml
    echo "languageCode: $langs" >> $hoster/hugo.yaml
    echo "theme: $skins"        >> $hoster/hugo.yaml

    cat $hoster/hugo.yaml
}


function packer_sitegen() {
    packer_sitegen_packcon
    packer_sitegen_sitecon
}


## INIT
function packer() {
    packer_prepare
    packer_apisgen
    packer_docsgen
    packer_mansgen
    packer_sitegen
}

packer
