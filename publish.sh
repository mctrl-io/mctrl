#!/usr/bin/env bash
# Temporarily store uncommited changes
git stash
# Verify correct branch
git checkout hakyll
# replace base url with github
echo "setting base url to github url"
sed -i 's+http://localhost:35730+https://mctrl.io+g' site.hs
# Build new files
stack build
stack exec mctrl rebuild
# replace base url with localhost again
echo "setting base url back to localhost"
sed -i 's+https://mctrl.io+http://localhost:35730+g' site.hs
# Get previous files
git fetch --all
git checkout -b gh-pages --track origin/gh-pages
# check if everything worked and we're on gh-pages
echo "on gh-pages? [y/n]"
read yesno
if [ $yesno == "y" ]; then
    # Overwrite existing files with new files
    rsync -a --filter='P _site/' \
        --filter='P _cache/' \
        --filter='P .git/' \
        --filter='P .gitignore' \
        --filter='P .stack-work' \
        --delete-excluded \
        _site/ .
    # Commit
    git add -A
    git commit -m "Publish."
    # Push
    git push origin gh-pages:gh-pages
    # Restoration
    git checkout hakyll
    git branch -D gh-pages
fi
# now pop the stash
git stash list --date=local
echo "pop stash? [y/n]"
read yesnostash
if [ $yesnostash == "y" ]; then
    git stash pop
fi
echo "publish completed."
