BETTER WAY TO ACHIEVE THE BEWLOW "DISABLING OF PULSEAUDIO":

Run Octave throug "pasuspender", i.e.:

>> pasuspender octave

This will disable Pulseaudio while Octave is running, so PlayRec will be happy.



--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------



See also:
https://wiki.debian.org/PulseAudio#Disabling_daemon_autospawn

NOTE: paths to config files may be different on differen Linux distros!



Stopping PulseAudio

You can disable PulseAudio for the current user or all users on a machine. To stop the daemon, do the following:

Note:  PulseAudio restarts automatically when you restart you machine, but you can prevent this by navigating to System > Preferences > Startup Applications and disabling the PulseAudio Sound System.

1. Open the ~/.pulse/client.conf file to disable PulseAudio for the current user,

2. Set the following attribute and ensure the line is not commented out:
autospawn = no

3. Call pulseaudio --kill to end the PulseAudio process.

4. Call ps -e | grep pulse to check the process stopped correctly.

Note:  Ending PulseAudio while other applications are running may disable audio output. Stop and start the application to re-enable audio output. Additionally, the desktop audio slider may be removed.


Restarting PulseAudio

To start the PulseAudio daemon, do the following:

1. Open the ~/.pulse/client.conf file to enable PulseAudio for the current user,
autospawn = yes

3. Call pulseaudio --start to start the PulseAudio daemon.
4. Call ps -e | grep pulse to check the process started correctly.
