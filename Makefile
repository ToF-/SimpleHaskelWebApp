p: ServerP.hs
	ghc --make -threaded ServerP.hs -o bin/serverp

param: ParameterServer.hs
	  ghc --make -threaded ParameterServer -o bin/paramserver

form: FormServer.hs
	ghc --make -threaded FormServer.hs -o bin/formserver


clean:
	rm *.hi
	rm *.o