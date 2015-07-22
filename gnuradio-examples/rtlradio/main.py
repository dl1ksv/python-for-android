#!/usr/bin/env python
##################################################
# Gnuradio Python Flow Graph
# Title: Dial Tone
# Author: Example
# Description: example flow graph
# Generated: Mon Jun  8 12:38:35 2015
##################################################
from gnuradio import analog
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import osmosdr
import time

from audiostream import get_output, AudioSample
from struct import *
import numpy

from kivy.app import App
from kivy.uix.widget import Widget


import os

class AudioSink(gr.sync_block):
    "AudioSink"
    def __init__(self):
        gr.sync_block.__init__(
             self,
             name = "AudioSink",
             #in_sig = [numpy.float32,numpy.float32], # Input signature: 2 float at a time
             in_sig = [numpy.int,numpy.int], # Input signature: 2 int at a time
             out_sig = [], # Output signature: 1 float at a time
        )
        self.stream = get_output(channels=2, buffersize=2048 , rate= 48000  )
        self.sample = AudioSample()
        self.stream.add_sample(self.sample)
        #self.scale=pow(2.,14)
        self.first=True
        print('AudioSink initialized')

    def work(self, input_items, output_items):
        if self.first :
            self.sample.play()
            self.first=False

        count=len(input_items[0])
        for i in range(0, count):
            self.sample.write(pack('<hh',input_items[0][i],input_items[1][i]))
        
        return count
    
    def starte(self):
        self.sample.play()

    def halte(self):
        self.sample.stop()

class Rtlradio(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Top Block")

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 1920000

        ##################################################
        # Blocks
        ##################################################
        self.tinyalsa_talsa_sink_0 = AudioSink()
	self.blocks_float_to_int_0 = blocks.float_to_int(1, pow(2.,15))
        print('+++Vor osmo')
        self.rtlsdr_source_0 = osmosdr.source( args="numchan=" + str(1) + " " + "rtl=0" )
        print('+++Nach osmo')
        self.rtlsdr_source_0.set_sample_rate(samp_rate)
        self.rtlsdr_source_0.set_center_freq(88.8e6, 0)
        self.rtlsdr_source_0.set_freq_corr(0, 0)
        self.rtlsdr_source_0.set_dc_offset_mode(0, 0)
        self.rtlsdr_source_0.set_iq_balance_mode(0, 0)
        self.rtlsdr_source_0.set_gain_mode(True, 0)
        self.rtlsdr_source_0.set_gain(10, 0)
        self.rtlsdr_source_0.set_if_gain(20, 0)
        self.rtlsdr_source_0.set_bb_gain(20, 0)
        self.rtlsdr_source_0.set_antenna("", 0)
        self.rtlsdr_source_0.set_bandwidth(0, 0)
          
        self.low_pass_filter_0 = filter.fir_filter_ccf(10, firdes.low_pass(
                4, samp_rate, 48000, 5000, firdes.WIN_HAMMING, 6.76))
        self.analog_fm_demod_cf_0 = analog.fm_demod_cf(
                channel_rate=samp_rate/10,
                audio_decim=4,
                deviation=75000,
                audio_pass=15000,
                audio_stop=16000,
                gain=5.0,
                tau=75e-6,
        )

        ##################################################
        # Connections
        ##################################################

        self.connect((self.analog_fm_demod_cf_0, 0), (self.blocks_float_to_int_0, 0))    
        self.connect((self.blocks_float_to_int_0, 0) , (self.tinyalsa_talsa_sink_0, 0))    
        self.connect((self.blocks_float_to_int_0, 0) , (self.tinyalsa_talsa_sink_0, 1))    
        self.connect((self.low_pass_filter_0, 0), (self.analog_fm_demod_cf_0, 0))    
        self.connect((self.rtlsdr_source_0, 0), (self.low_pass_filter_0, 0))    

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.low_pass_filter_0.set_taps(firdes.low_pass(4, self.samp_rate, 48000, 5000, firdes.WIN_HAMMING, 6.76))
        self.rtlsdr_source_0.set_sample_rate(self.samp_rate)



class RtlradioWindow(Widget):
    pass

class RtlradioApp(App):
    def build(self):
        rootWindow=RtlradioWindow()
        self.tb=Rtlradio()
        self.started=0
        print("####Environment", os.environ)
        return rootWindow

    def startstop_audio(self):
        print('Start/stop pressed')
        if self.started == 1 :
            self.started= 0
            print('Vor stop')
            self.tb.stop()
            #self.tb.tinyalsa_talsa_sink_0.halte()
            print('Nach stop')
        else:
            print('Vor start')
            self.started= 1
            self.tb.start()
            #self.tb.tinyalsa_talsa_sink_0.starte()
            print('Nach start')

if __name__ == '__main__':
    RtlradioApp().run()
#    parser = OptionParser(option_class=eng_option, usage="%prog: [options]")
#    (options, args) = parser.parse_args()
#    tb = dial_tone()
#    tb.start()
#    try:
#        raw_input('Press Enter to quit: ')
#    except EOFError:
#        pass
#    tb.stop()
#    tb.wait()
