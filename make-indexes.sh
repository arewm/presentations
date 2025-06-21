#!/bin/bash
# Make index.html files

for dirname in . $(find * -type d); do
	parent=$(dirname $dirname)
	rm "$dirname/index.html" || true
	if [ "$parent" != "$dirname" ]; then
		echo '<a href="../">../</a><br/>' >> "$dirname/index.html";
	fi
	for child in $(ls $dirname); do
		echo '<a href="'"$child"'">'"$child"'</a><br/>' >> "$dirname/index.html";
	done;
done
