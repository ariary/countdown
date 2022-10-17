build.sort_cewl:
	nim -o:./bin/ c src/sort_cewl.nim
build.countdown:
	nim -o:./bin/ -d:release c src/countdown.nim