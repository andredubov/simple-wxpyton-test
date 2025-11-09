BUILD_DIR=.build
APP_NAME=MyApp
APP_BUNDLE=./$(BUILD_DIR)/$(APP_NAME).app
DMG_NAME=$(APP_NAME)_Installer
VERSION=1.0.0

clean:
	rm -rf .build .venv

venv:
	python3 -m venv .venv
	. ./.venv/bin/activate && \
	python3 -m pip install --upgrade pip && \
	python3 -m pip install -r ./requirements/x64/requirements.txt && \
	python3 -m pip install imageio nuitka

build: clean venv
	. ./.venv/bin/activate && \
	python3 -m nuitka \
	--mode=app \
	--assume-yes-for-downloads \
	--include-package=wx \
	--include-package-data=wx \
	--include-module=utils \
	--include-data-files=./assets/*=assets/ \
	--noinclude-unittest-mode=nofollow \
	--noinclude-setuptools-mode=nofollow \
	--include-module=_bisect \
	--include-module=_json \
	--company-name=https://github.com/andredubov \
	--product-name=$(APP_NAME) \
	--output-dir=./$(BUILD_DIR) \
	--output-filename=$(APP_NAME) \
	--macos-app-name=$(APP_NAME) \
	--macos-app-icon=./assets/graph-report.ico \
	--macos-app-version=1.0.0 \
	--macos-target-arch=x86_64 \
	./main.py

renane-app-bundle:
	mv ./$(BUILD_DIR)/main.app ./$(BUILD_DIR)/$(APP_NAME).app

create-dmg: renane-app-bundle
	create-dmg \
	--volname "$(APP_NAME) $(VERSION)" \
	--volicon "./assets/graph-report.icns" \
	--window-pos 200 120 \
	--window-size 600 400 \
	--icon-size 96 \
	--icon "$(APP_NAME).app" 150 200 \
	--hide-extension "$(APP_NAME).app" \
	--app-drop-link 450 200 \
	--no-internet-enable \
	--format UDZO \
	"./$(BUILD_DIR)/$(DMG_NAME).dmg" \
	"$(APP_BUNDLE)"