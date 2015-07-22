#!/bin/bash
export ANDROIDAPI=16
cd ../../dist/gnuradio
./build.py --package org.dl1ksv.dialtonealsa --name Dialtonealsa \
           --private ../../gnuradio-examples/dialtonealsa \
	   --icon ../../gnuradio-examples/dialtonealsa/gnuradio_logo.png \
	   --minsdk 16 \
  	   --window --version 1.0 debug

