#!/bin/bash

set -o errexit
set -o nounset

config_dir="${HOME}/.microtool"
profiles_dir="${config_dir}/profiles"
shared_dir="${config_dir}/shared"
help="\
Usage: microtool [OPTION...] PROFILE_NAME

microtool is a test tool that helps administrating your machine using different rsync
configurations in named profiles, for each user.

Options:
    -c, --create-profile PROFILE_NAME   create new profile (profile data
                            are stored in ${config_dir}/PROFILE_NAME).
                            Profile name can contain alphanumeric
                            characters only. You can start from a shared 
                            one, if exists.
    -d, --delete-profile PROFILE_NAME delete a profile and it's data    
    -s, --show-profile-config PROFILE_NAME  show content of profile
                            configuration file (stored in
                            ${config_dir}/PROFILE_NAME)
    -l, --list-profiles     list all available profiles
    -h, --help              show this help

Steps to use:
    Create new profile by typing
    microtool -c PROFILE_NAME

    edit its configuration files stored by default in
    ${profiles_dir}/PROFILE_NAME

    run it by typing
    microtool PROFILE_NAME
"


create_profile() {
    # Create directory with given profile name and with default content.
    # Creating files: conf, exclude
    # $1 -- profile name
    
    

    local profile_name="${1}"
    local profile_dir="${profiles_dir}/${profile_name}"
    
    # create default dirs if missing
    if [[ ! -d "${profiles_dir}" ]]; then
        echo "Creating ${profiles_dir}"
        mkdir -p "${profiles_dir}"
    fi
    if [[ ! -d "${shared_dir}" ]]; then
        echo "Creating ${shared_dir}"
        mkdir -p "${shared_dir}"
    fi

    if [[ -d "${profile_dir}" ]]; then
        echo "microtool: error: profile already exists."
        exit 1
    fi

    echo "Creating ${profile_dir}"
    mkdir "${profile_dir}"

    local conf="${profile_dir}/conf"
    
    read -p "Do you want to use a shared config(y/n)? " input  
    if [[ "$input" == "y" ]]; then 
       
	    temp=$(find $HOME/.microtool/shared -type f -printf "%f\n")
	    while [[ -n "$temp" ]]; do
	    	    echo $temp
		    read -p "Choose one by name: " name
		    if [[ -z "$(find $HOME/.microtool/shared -type f -name $name)" ]]; then 
			echo "$name was not found!"
		    else
		    	temp=""
		    	echo "Creating ${conf}"
			cp $HOME/.microtool/shared/$name $conf
	    	    fi
    	    done
    elif [[ "$input" == "n" ]]; then
      echo "Creating ${conf}"
      cat << EOF > "${conf}"
# rsync configuration
#
# Write each rsync option on separate line. 
# 
# Config files shared between different profiles should be saved in
# ${shared_dir}
#
# Default configuration
#
--verbose
--archive
--human-readable
--exclude-from="${profile_dir}/exclude"
--relative
--recursive
--dry-run
# source
#de modif
${HOME}/Documents      
# destination
${HOME}/my_backup
EOF
    else
      printf "Wrong input!\nCreating default config..."
      cat << EOF > "${conf}"
# rsync configuration
#
# Write each rsync option on separate line. 
# 
# Config files shared between different profiles should be saved in
# ${shared_dir}
#
# Default configuration
#
--verbose
--archive
--human-readable
--exclude-from="${profile_dir}/exclude"
--relative
--recursive
--dry-run
# source
#de modif
${HOME}/Documents      
# destination
${HOME}/my_backup
EOF
    fi
            
    exclude="${profile_dir}/exclude"
    echo "Creating ${exclude}"
    cat << EOF > "${exclude}"
# 'exclude' template
# Patterns of files and directories you want to exclude from the transfer.
#
# To exclude use:
#- /path/to/file
# To include use:
#+ /path/to/file
#
# For more pattern configurations, see the FILTER RULES section of man rsync
EOF

    echo "Profile created"
    echo "Edit profile configuration file in ${profile_dir}/conf "
}

delete_profile() {

    rm -r ${profiles_dir}/${1}
    echo "Profile deleted"
}


list_profiles() {

    for item in "${profiles_dir}"/*; do
        if [[ -d "${item}" ]]; then
            basename "${item}"
        fi
    done
}


show_help() { >&2 echo "${help}"; }


show_profile_config() {
    # $1 -- profile name
    

    local profile_name="${1}"
    less "${profiles_dir}/${profile_name}/conf"
}


check_profile_name() {
    # Check that name is not empty and contains alphanumeric characters only.

    if [[ -z "${1}" ]]; then
        >&2 echo "microtool: error: empty profile name."
        exit 1
    elif [[ "${1}" =~ [^a-zA-Z0-9] ]]; then
        >&2 echo "microtool: error: non-alphanumeric characters in profile name."
        exit 1
    fi
}


check_profile_exists() {
    # Check that $profile_name exists and is a directory.

    local profile_name="${1}"
    if [[ ! -d "${profiles_dir}/${profile_name}" ]]; then
        >&2 echo "microtool: error: profile ${profile_name} does not exist."
        exit 1
    fi
}


check_num_args() {
    # Check that value of $1 = number of arguments 
   

    local num_args=$(( ${#} - 1 ))  # do not count $1 in total num of args
    if [[ "${1}" -ne "${num_args}" ]]; then
        >&2 echo "microtool: error: expected num args: ${1}, received: $num_args"
        exit 1
    fi
}


run_rsync() {
    # Run rsync with configuration coresponding to given profile name.
    # $1 -- profile name
    

    local profile_name="${1}"
    local visual_div="=============================="
   
    local parsed_args=$(grep -v '^#' "${profiles_dir}/${profile_name}/conf" \
                    | tr '\n' ' ')

    # Print debug info
    echo "${visual_div}"
    echo "microtool"
    echo "args: ${parsed_args}"
    echo "${visual_div}"

    # $parsed_args - each item from conf file becomes rsync argument
   
    rsync ${parsed_args}
}


if [[ "${#}" == 0 ]]; then
    show_help
    exit 1
fi
while [[ "${#}" -gt 0 ]]; do
    case "${1}" in
        -c | --create-profile)
            check_num_args 2 "${@}"
            shift
            check_profile_name "${1:-}" # if $1 is not declared, set it empty.
            create_profile "${1}"
            exit 0;;
    	-d | --delete-profile)
            check_num_args 2 "${@}"
            shift
            check_profile_name "${1:-}" 
            check_profile_exists "${1}"
            delete_profile "${1}"
            exit 0;;
        -s | --show-profile-config)
            check_num_args 2 "${@}"
            shift
            check_profile_name "${1:-}"
            check_profile_exists "${1}"
            show_profile_config "${1}"
            exit 0;;
        -l | --list-profiles)
            check_num_args 1 "${@}"
            list_profiles
            exit 0;;
        -h | --help)
            check_num_args 1 "${@}"
            show_help
            exit 0;;
        -*)
            echo >&2 "microtool: error: unknown option '${1}'"
            exit 1;;
        *)
            check_num_args 1 "${@}"
            check_profile_name "${1:-}"
            check_profile_exists "${1}"
            run_rsync "${1}"
            exit 0;;
    esac
    shift
done
