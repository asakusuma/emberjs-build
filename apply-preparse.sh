#!/bin/bash

# =========================================================== #
# README
# =========================================================== #
#
# The goal of the script is to partially automate the steps
# required to create a performance-enhanced ember.js build.
# There are two main custom piecies to the perf build:
#
# 1.  Preparse. This is an optimization to how ember declares it's
#     internal modules. See https://github.com/asakusuma/broccoli-ember-preparse
# 2.  Removal of glimmer2 and other FEATURE flags. There are several FEATURES
#     in Ember aren't used outside of canary development. Since we don't use them,
#     we don't want their page weight penalty, which can be substantial
#     (~30% increase). See: https://github.com/emberjs/ember.js/blob/master/FEATURES.md
#
# The output to this script is a modification to an existing ember build git repo
# Here is an example of an ember build repo: https://github.com/asakusuma/ember-preparse-patch
# Such a repo can be imported to an ember app via bower.json
#
# Steps to run script:
#
# 1. Setup a parent directory. In this example, ~/my-ember-stuff
# 2. Checkout emberjs/ember.js in the parent repo. ~/my-ember-stuff/ember.js
# 3. Setup an ember build repo. In this example: ~/my-ember-stuff/ember-preparse-patch
# 4. npm link this repo (emberjs-build on the preparse-build branch) from ember.js repo
# 5. Run script: ./ember-canary-upgrade.sh ~/my-ember-stuff/my-ember-stuff/
# 6. You should see changes in /ember-preparse-patch
#
# =========================================================== #

REPOS="../"

if [ ! -z $1 ]
then
    REPOS=$1
fi

if ! [ -d "$REPOS/ember.js/" ]
then
    echo "ember.js repo not found";
    exit
fi

cd "$REPOS/ember.js/"
git fetch upstream
git rebase upstream/master
npm run build

cp dist/ember-template-compiler.js ../ember-preparse-patch/
cp dist/ember-testing.js ../ember-preparse-patch/
cp dist/ember.prod.js ../ember-preparse-patch/
cp dist/ember.debug.js ../ember-preparse-patch/
cp dist/bower.json ../ember-preparse-patch/

cd ../ember-preparse-patch
git add .
git commit -m "Upgrade latest canary"
