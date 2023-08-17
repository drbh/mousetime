.PHONY: build

build: 
	@mkdir  -p MouseTime.app/Contents/MacOS/ && \
		swiftc -o MouseTime.app/Contents/MacOS/MouseTime main.swift

run:
	MouseTime.app/Contents/MacOS/MouseTime

app:
	 open MouseTime.app

clean:
	 rm -rf MouseTime.app

dev:
	swift main.swift