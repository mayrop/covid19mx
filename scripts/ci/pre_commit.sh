# adding meta for generated times
# doesn't work with github actions...

DIRECTORY=$(cd `dirname $0` && pwd)
ROOT=$(dirname $DIRECTORY)
ROOT=$(dirname $ROOT)

cd $ROOT

git ls-tree -r --name-only HEAD | while read filename; do echo "$(git log -1 --no-merges --format="%ci" -- $filename),$filename" >> "./cache/meta/files.txt"; done
