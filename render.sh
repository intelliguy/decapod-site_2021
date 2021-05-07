#!/bin/bash
DECAPOD_BASE_URL=https://github.com/openinfradev/decapod-base-yaml.git
BRANCH="main"

if [ $# -eq 1 ]; then
  BRANCH=$1
fi

site_list=$(ls -d */ | sed 's/\///g' | grep -v 'docs')
echo "Fetch base with $BRANCH branch/tag........"
git clone -b $BRANCH $DECAPOD_BASE_URL
if [ $? -ne 0 ]; then
  exit $?
fi

# for i in ${site_list}
# do
#   echo "Starting build manifests for '$2' site"

  for app in `ls $2`
  do
    output="$2/$app/$app-manifest.yaml"
    cp -r decapod-base-yaml/$app/base $2/
    echo "Rendering $app-manifest.yaml for $2 site"
    docker run --rm -i -v $(pwd)/$2:/$2 --name kustomize-build sktdev/decapod-kustomize:latest kustomize build --enable_alpha_plugins /$2/$app -o /$2/$app/$app-manifest.yaml
    build_result=$?

    if [ $build_result != 0 ]; then
      exit $build_result
    fi

    if [ -f "$output" ]; then
      echo "[$2] Successfully Completed!"
    else
      echo "[$2] Failed to render $app-manifest.yaml"
      rm -rf $2/base decapod-yaml
      exit 1
    fi
    rm -rf $2/base
  done
# done

rm -rf decapod-base-yaml
