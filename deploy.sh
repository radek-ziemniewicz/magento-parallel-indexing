#!/usr/bin/env sh
# abort on errors
set -e
# build
yarn run build
# navigate into the build output directory
rm -rf docs
mv dist docs
# if you are deploying to a custom domain
# echo 'www.example.com' > CNAME
git add .
git commit -m 'Deploy'
git push
