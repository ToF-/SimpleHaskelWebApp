p: ServerP.hs
	ghc --make -threaded ServerP.hs -o bin/serverp
	rm *.hi
	rm *.o