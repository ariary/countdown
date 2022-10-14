build.sort_cewl:
	nim -o:./bin/ c src/sort_cewl.nim
build.count:
	nim -o:./bin/ -d:release c src/count.nim