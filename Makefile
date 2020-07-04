SHELL := /bin/bash

# set variables
export NAME = jupyter-board

create-install:
	python3 -m venv venv
	source venv/bin/activate \
		&& pip3 install -r requirements.txt \
		&& ipython kernel install --user --name=$$NAME \
		&& jupyter nbextension enable --py widgetsnbextension

install:
	source venv/bin/activate && pip3 install -r requirements.txt

ipython:
	source venv/bin/activate && ipython --pdb

jupyter:
	source venv/bin/activate && jupyter notebook

nbconvert:
	source venv/bin/activate && jupyter nbconvert TestWidgets.ipynb

server:
	source venv/bin/activate && python -m http.server
