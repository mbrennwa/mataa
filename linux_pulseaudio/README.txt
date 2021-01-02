Using MATAA on Linux with Pulseaudio installed

Pulseaudio is a "sound software layer" that sits on top of the ALSA sound layer. Pulseaudio may sometimes interfere with MATAA / PlayRec, which needs direct ALSA access to the audio hardware. If you need to disable Pulseaudio for use with MATAA / PlayRec, run Octave using "pasuspender":

>> pasuspender octave

This will disable Pulseaudio while Octave is running, so PlayRec will be happy.
