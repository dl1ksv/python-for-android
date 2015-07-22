#!/usr/bin/env python
##################################################
# Gnuradio Python Flow Graph
# Title: Dial Tone
# Author: Example
# Description: example flow graph
# Generated: Mon Jun  8 12:38:35 2015
##################################################
from gnuradio import analog
from gnuradio import filter
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
import osmosdr
import time
import tinyalsa

from kivy.app import App
from kivy.uix.widget import Widget


#import os

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
        self.tinyalsa_talsa_sink_0 = tinyalsa.talsa_sink(48000, 1, 0)
        self.rtlsdr_source_0 = osmosdr.source( args="numchan=" + str(1) + " " + "rtl=0" )
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
        self.connect((self.analog_fm_demod_cf_0, 0), (self.tinyalsa_talsa_sink_0, 0))    
        self.connect((self.analog_fm_demod_cf_0, 0), (self.tinyalsa_talsa_sink_0, 1))    
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
#        print("####Environment", os.environ)
        return rootWindow

    def startstop_audio(self):
        print('Start/stop pressed')
        if self.started == 1 :
            self.started= 0
            print('Vor stop')
            self.tb.stop()
            print('Nach stop')
        else:
            print('Vor start')
            self.started= 1
            self.tb.start()
            print('Nach start')

if __name__ == '__main__':
    RtlradioApp().run()
