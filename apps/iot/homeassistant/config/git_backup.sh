#!/bin/bash

# syncs with local priority, backups local files found remotely to git
# - file found locally, will commit to git if changed
# - file not found locally, will copy from git
# - will NOT commit file if not found in repository, keeping secrets etc. locally (unless you commit them)

orig_path=$(pwd)
sync_branch="${GITSYNC_BRANCH:-main}"
sync_source="${GITSYNC_SOURCE:-/config}"
root_dir="${GITSYNC_ROOT:-/config/gitsync}"
sparse_checkout_path="${SPARSE_CHECKOUT_PATH:-/apps/iot/homeassistant/config}"
repo_url="${REPO_URL:-git@github.com:wahooli/homelab.git}"
commit_author="${AUTHOR:-HomeAssistant}"
commit_author_email="${AUTHOR_EMAIL:-homeassistantbot@users.noreply.github.com}"
commit_message="${COMMIT_MESSAGE:-chore: \"update home-assistant configs\"}"
pre_commit_check="${PRE_COMMIT_CHECK:-/usr/local/bin/hass -c /config --script check_config}"

homedir=$(realpath ~/)

if [ ! -f "${homedir}/.ssh/known_hosts" ]; then
	mkdir -p ~/.ssh/
	touch ~/.ssh/known_hosts
	ssh-keyscan -H github.com >> ~/.ssh/known_hosts
	cp -Lr /ssh-keys/* ~/.ssh/
	chmod -R 600 ~/.ssh
fi

# do sparse checkout logic if directory not found
if [ ! -d "${root_dir}" ]; then
	echo "sync path not found, cloning"
	if ! git clone ${repo_url} --quiet --branch $sync_branch --single-branch --no-checkout ${root_dir} --depth 1
	then
		echo >&2 message
		exit 1
	fi
	cd ${root_dir}
	git sparse-checkout init
	git sparse-checkout set ${sparse_checkout_path}
	git checkout --quiet
	cd ".${sparse_checkout_path}" || { echo "no directory \"${sparse_checkout_path}\" in repo!"; exit 1; }
else
	cd $root_dir
	# if for some reason there's not commited changes, erase them
	git fetch --quiet origin $sync_branch
	git reset --quiet --hard origin/$sync_branch
	git clean -f -d
	git pull --quiet --ff-only
	cd ".${sparse_checkout_path}" || { echo "no directory \"${sparse_checkout_path}\" in repo!"; exit 1; }
fi

if [[ ! $($pre_commit_check) ]]; then
	echo "Pre commit check failed, won't commit"
	exit 1
fi

find_dir=$(realpath "${root_dir}/${sparse_checkout_path}")

find ${find_dir} -type f -print0 | while IFS= read -r -d $'\0' file; do
	filename=${file#${find_dir}/}
	
	local_file="${sync_source}/${filename}"
	if [ -f "${local_file}" ]; then
		if [ ! -z "$(cmp $local_file $file)" ]; then
			cp -f $local_file $file
			echo "modified $filename"
		fi
	else
		install -D $file $local_file
		echo "Copied ${filename} from git repo"
	fi
done

# detect changes
if [[ $(git status --porcelain --untracked-files=no) ]]; then
	# adds modified and deleted files, not new/untracked
	git add -u
	git commit --quiet --author="${commit_author} <${commit_author_email}>" -m "${commit_message}"
	git push --quiet
	echo "Pushed changes to git"
else
	echo "No changes"
fi

cd $orig_path