export name=$1
export tag=$2
heighliner build --no-cache --no-build-cache --chain ${name} --git-ref ${tag}  -r ghcr.io/pfc-developer/heighliner
docker push ghcr.io/pfc-developer/heighliner/${name}:${tag}
