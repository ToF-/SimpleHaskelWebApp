C=ghc
F=--make -threaded


p: ServerP.hs
	$(C) $(F) ServerP.hs -o bin/serverp

param: ParameterServer.hs
	  $(C) $(F) ParameterServer -o bin/paramserver

form: FormServer.hs
	$(C) $(F) FormServer.hs -o bin/formserver

upload: UploadServer.hs
	$(C) $(F) UploadServer.hs -o bin/uploadserver 	

dice:
	$(C) $(F) DiceServer.lhs -o bin/diceserver

clean:
	rm *.hi
	rm *.o