# Temporarily store uncommited changes
git stash
# Verify correct branch
git checkout hakyll
sed -i 's+localhost:8080+https://benedikt-mayer.github.io+g' site.hs
# Build new files
stack build
stack exec CleanMagic-hakyll rebuild
# stash the site changes
 sed -i 's+https://benedikt-mayer.github.io+localhost:8080+g' site.hs
# Get previous files
git fetch --all
git checkout -b master --track origin/master
# Overwrite existing files with new files
rsync -a --filter='P _site/'      \
         --filter='P _cache/'     \
         --filter='P .git/'       \
         --filter='P .gitignore'  \
         --filter='P .stack-work' \
         --delete-excluded        \
         _site/ .
# Commit
git add -A
git commit -m "Publish."
# Push
git push origin master:master
# Restoration
git checkout hakyll
git branch -D master
git stash pop