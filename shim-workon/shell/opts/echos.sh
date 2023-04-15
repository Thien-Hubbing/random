#!/bin/bash
function echo_blue() {
    echo -e "\033[1;94m$1"
    echo -e '\e[0m'
}
function echo_green() {
    echo -e "\e[0;32m$1"
    echo -e '\e[0m'
}
function echo_yellow() {
    echo -e "\e[1;33m$1"
    echo -e '\e[0m'
}
function echo_red() {
    echo -e "\e[0;31m$1"
    echo -e '\e[0m'
}
function exit_red() {
    echo_red "$@"
    read -ep "Press [Enter] to exit."
    exit 1
}
function exit_green() {
    echo_green "$@"
    read -ep "Press [Enter] to exit."
    exit 0
}