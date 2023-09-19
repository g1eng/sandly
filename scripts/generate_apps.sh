#!/bin/sh -ex
#

generate_app(){
: "${1:?no app specified}"
cat <<EOT
#!/bin/sh
# Sandly wrapper script for sandboxed $1
# usage: ${1##*/}
#
picka_word(){
	echo "\$*" | tr \\\\\\  \\\\\\n | shuf | head -1
}
generate_container_name(){
	{
		picka_word kawamura tanabe sonoda shiomi tajiri kijima toudou andou sagawa ijiri tochio suda iio nemoto miyashita nonaka uzawa ogino 
		picka_word obahan obachan obasan baasan baachan basama ouna ossan ojisan ojiisan jiisan jisama okina
	} | {
		read name
		read role
		echo \$name-\$role
	}
}

select_random_uid(){
	picka_word \$(seq 1000 3000 )
}

{
	generate_container_name
	select_random_uid
} | {
	read cid
	read uid
	container_name=\$cid
	user_id=\$uid

	echo \$container_name uid=\$user_id
	docker run \\
		--rm \\
		-d \\
		--name \${container_name:?no container name} \\
		-v /lib:/lib:ro \\
		-v /lib64:/lib64:ro \\
		-v /usr:/usr:ro \\
		-v /bin:/bin:ro \\
		-v /sbin:/sbin:ro \\
		-v /dev/dri:/dev/dri \\
		-v /tmp/.X11-unix:/tmp/.X11-unix \\
		-v /etc/fonts:/etc/fonts:ro \\
		-v /var/cache/fontconfig:/var/cache/fontconfig:ro \\
		-v /opt:/opt:ro \\
		-v /etc/ld.so.cache:/etc/ld.so.cache:ro \\
		-v /etc/ld.so.conf:/etc/ld.so.conf:ro \\
		-v /etc/ld.so.conf.d:/etc/ld.so.conf.d:ro \\
		-u u\$user_id \\
		--workdir /home/u\$user_id \\
		-e DISPLAY=:0 \\
		-e LANG=$LANG \\
		${BASEIMAGE_NAME:-flatskel} \\
		$1 \\
		> /dev/null
}
EOT
}

[ -d ./out/bin ] || install -D -m 755 ./out/bin

while read app ; do generate_app $app > ./out/bin/${SANDLY_COMMAND_PREFIX:+${SANDLY_COMMAND_PREFIX}}${app##*/}; done < app_list.txt
