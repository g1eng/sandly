#!/bin/sh -x

[ -d home ] && rm -rf home
mkdir -vp home
ids="$(seq 1000 3000)"
(
	cd home
	mkdir $(seq 1000 3000 | awk '{printf "u%d ", $1}')
)
cat << EOT > passwd
root:x:0:0:System user; root:/root:/bin/sh
flatpak:x:313:313:System user; flatpak:/dev/null:/sbin/nologin
EOT
for i in $ids; do 
echo u$i:x:$i:$i::/home/u$i:/bin/sh
done >> passwd
docker run --rm -it --name busybox-owner-modifier -v $PWD/home:/target busybox sh -c "
cd /target
for i in $(seq 1000 3000 | tr \\\n  \\\ ); do
	chown \$i:\$i u\$i
done
"
