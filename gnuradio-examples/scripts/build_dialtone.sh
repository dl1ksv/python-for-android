#!/bin/bash
export ANDROIDAPI=16
cd ../../dist/gnuradio
./build.py --package org.dl1ksv.dialtone --name Dialtone \
           --private ../../gnuradio-examples/dialtone \
	   --icon ../../gnuradio-examples/dialtone/gnuradio_logo.png \
	   --minsdk 16 \
  	   --window --version 1.0 debug

