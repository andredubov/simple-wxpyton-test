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
	--product-name=plotter \
	--output-dir=./.build \
	--output-filename=PlotterApp \
	--macos-app-name=PlotterApp \
	--macos-app-icon=./assets/graph-report.ico \
    --macos-create-app-bundle \
    --macos-app-version=1.0.0 \
    --onefile-windows-splash-screen-image=./assets/logo.png \
	./main.py && \
    mv ./.build/main.app ./.build/PlotterApp.app