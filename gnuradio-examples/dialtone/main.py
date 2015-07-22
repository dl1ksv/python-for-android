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
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
#from optparse import OptionParser
#import tinyalsa
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
        self.first=True

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

class dial_tone(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Dial Tone")

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 48000

        ##################################################
        # Blocks
        ##################################################
        self.tinyalsa_talsa_sink_0 = AudioSink()
        self.blocks_add_xx = blocks.add_vff(1)
        self.analog_sig_source_x_1 = analog.sig_source_f(samp_rate, analog.GR_COS_WAVE, 440, 0.3, 0)
        self.analog_sig_source_x_0 = analog.sig_source_f(samp_rate, analog.GR_COS_WAVE, 350, 0.3, 0)
        self.blocks_float_to_int_0 = blocks.float_to_int(1, pow(2.,15))

        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_sig_source_x_0, 0), (self.blocks_add_xx, 0))    
        self.connect((self.analog_sig_source_x_1, 0), (self.blocks_add_xx, 1))
        self.connect((self.blocks_add_xx, 0), (self.blocks_float_to_int_0, 0))
        self.connect((self.blocks_float_to_int_0, 0) , (self.tinyalsa_talsa_sink_0, 0))    
        self.connect((self.blocks_float_to_int_0, 0) , (self.tinyalsa_talsa_sink_0, 1))    
        print('Topblock initialized')

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.analog_sig_source_x_0.set_sampling_freq(self.samp_rate)
        self.analog_sig_source_x_1.set_sampling_freq(self.samp_rate)

class DialtoneWindow(Widget):
    pass

class DialtoneApp(App):
    def build(self):
        #import os
        #print('++++',os.environ)
        rootWindow=DialtoneWindow()
        self.tb=dial_tone()
        self.started=0
        return rootWindow

    def startstop_audio(self):
        print('Start/stop pressed')
        if self.started == 1 :
            self.started= 0
            self.tb.stop()
        else:
            self.started= 1
            self.tb.start()

if __name__ == '__main__':
    DialtoneApp().run()
