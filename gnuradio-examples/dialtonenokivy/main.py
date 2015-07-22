#!/usr/bin/env python
##################################################
# Gnuradio Python Flow Graph
# Title: Dial Tone
# Author: Example
# Description: example flow graph
# Generated: Mon Jul 20 17:36:46 2015
##################################################

from gnuradio import analog
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import tinyalsa

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
        self.tinyalsa_talsa_sink_0 = tinyalsa.talsa_sink(samp_rate, 1, 0)
        self.blocks_add_xx = blocks.add_vff(1)
        self.analog_sig_source_x_1 = analog.sig_source_f(samp_rate, analog.GR_COS_WAVE, 440, 0.3, 0)
        self.analog_sig_source_x_0 = analog.sig_source_f(samp_rate, analog.GR_COS_WAVE, 350, 0.3, 0)

        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_sig_source_x_0, 0), (self.blocks_add_xx, 0))    
        self.connect((self.analog_sig_source_x_1, 0), (self.blocks_add_xx, 1))    
        self.connect((self.blocks_add_xx, 0), (self.tinyalsa_talsa_sink_0, 0))    
        self.connect((self.blocks_add_xx, 0), (self.tinyalsa_talsa_sink_0, 1))    


    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.analog_sig_source_x_0.set_sampling_freq(self.samp_rate)
        self.analog_sig_source_x_1.set_sampling_freq(self.samp_rate)


if __name__ == '__main__':
    parser = OptionParser(option_class=eng_option, usage="%prog: [options]")
    (options, args) = parser.parse_args()
    tb = dial_tone()
    tb.start()
    tb.wait()
