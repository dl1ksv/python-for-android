#!/bin/bash
export ANDROIDAPI=16
cd ../../dist/gnuradio
./build.py --package org.dl1ksv.rtlradio --name Rtlradio \
           --private ../../gnuradio-examples/rtlradio \
	   --icon ../../gnuradio-examples/rtlradio/gnuradio_logo.png \
	   --minsdk 16 \
  	   --window --version 1.0 debug

