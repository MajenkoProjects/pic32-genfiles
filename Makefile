ROOT=/home/matt/.uecide/compilers/mipsel-pic32-elf/mipsel-pic32-elf

all:
	bin/pic32-genfiles

install:
	cp -r lib ${ROOT}/
	cp -r include ${ROOT}/
