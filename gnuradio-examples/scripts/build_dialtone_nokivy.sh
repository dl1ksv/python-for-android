#!/bin/bash
export ANDROIDAPI=16
cd ../../dist/gnuradio
./build.py --package org.dl1ksv.dial --name Dial \
           --private ../../gnuradio-examples/dialtonenokivy \
	   --minsdk 16 \
  	   --window --version 1.0 debug

