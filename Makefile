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

clean:
	rm *.hi
	rm *.o