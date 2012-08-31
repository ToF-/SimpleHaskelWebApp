p: ServerP.hs
	ghc --make -threaded ServerP.hs -o bin/serverp
	rm *.hi
	rm *.o

param: ParameterServer.hs
	  ghc --make -threaded ParameterServer -o bin/paramserver
	  rm *.hi
	  rm *.o