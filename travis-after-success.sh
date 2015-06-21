#!/usr/bin/env bash
set -e ; set -u

echo "after-success script for branch: $TRAVIS_BRANCH"
# Build and deploy documentation, but only for the master branch and for the first job
if [[ $TRAVIS_BRANCH == 'master' && $TRAVIS_JOB_NUMBER == '1' ]]
then
  echo "Building and deploying website"
  SOURCE_DIR="$PWD"
  # Compile the website with roots
  pushd site
  npm install -g roots
  roots compile -e production
  # Commit the updated site to gh-pages
  pushd public
  git init
  git config user.name "Travis CI"
  git config user.email "cspotcode.travis@gmail.com"
  git add -u .
  git commit -m "Deploy to GitHub Pages"

  # Set up ssh access to github
  cat >> ~/.ssh/config <<EOF
Host github
  HostName github.com
  User git
  IdentityFile "$SOURCE_DIR/id_rsa"
  IdentitiesOnly yes
EOF

  # Push to gh-pages.  This destroys all history for the gh-pages branch.
  git push --force --quiet "ssh://github:${GH_REF}" master:gh-pages
else
  echo "Not building or deploying website"
fi

