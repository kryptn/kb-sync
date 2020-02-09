install:
	nimble build -d:ssl
	cp bin/kb_sync /usr/local/bin/kb_sync