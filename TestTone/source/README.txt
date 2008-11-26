* Description:

TestTone is a console program that reads test-signal data from a text file. This signal is then played through the default audio output device, and simultaneously recorded through the default audio input device. Alternatively, if no input file is given, then a default signal is generated.

TestDevices is a console program that prints information about the default audio devices for sound input and output.

TestTone and TestDevices make use of PortAudio to communicate with the audio device (see http://www.portaudio.com). This should allow TestTone to be compiled on several platforms.


* Compiling TestTone and TestDevices:

If you need/want to compile TestTone and TestDevices yourself, PLEASE read the corresponding sections in the MATAA manual. You may also want to read the instructions given in the tutorial on the portaudio wiki (http://portaudio.com/trac/wiki/TutorialDir/TutorialStart). This involves the following steps:

- Download the portaudio package (you'll need version 19 for TestTone and TestDevices).
- Compile and build the portaudio library for the computer platform on which you intend to use MATAA.
- Compile and build the TestTone and TestDevices programs for the computer platform on which you intend to use MATAA.

The following are some platform specific notes an additions to the wiki tutorial (which, as of 13. Feb. 2007, was not complete, out of date, or wrong):

- Mac OS X
Follow the instructions on the tutorial on the wiki. Make sure you use the 'Release' settings in XCode. Otherwise the programs won't be linked properly, so they won't run on other machines.

- Windows
I haven't compiled TestTone and TestDevices myself for Windows. Shu Sang (sangshu@hotmail.com) successfully compiled them, and provided his binaries for inclusion with the MATAA package (thanks Shu!).
Note that PortAudio seems unable to reliably determine the properties of the default sound input/output device if used with WMME or DirectSound. The only option therefore seems to be ASIO, which is also more efficient (i.e. gives lower latency). Hence, TestTone and especially TestDevices must be compiled with ASIO support only (i.e. WMME and DirecSound support must be disabled). This is achieved by specifying the following #defines (see http://portaudio.com/trac/wiki/TutorialDir/Compile/WindowsASIOMSVC):

#define PA_NO_WMME
#define PA_NO_DS

If your soundcard does not come with an ASIO driver, take a look at ASIO4ALL (http://asio4all.com).
Apart from these notes, Shu Sang gave the following instructions:

	1. download and install ASIO4ALL from http://www.asio4all.com/
	2. download port audio 19 from http://www.portaudio.com/ , unzip the source code, and open the project under MSVC.
	3. remove the dsound subdir from the project (optional)
	4. remove the PA_ENABLE_DEBUG_OUTPUT from solution properties (optional). Or you can just take the dll and lib under mataa testtone.
	5. To compile the test tone and test device under windows, you need to change filenames from TestTonePA19.c and TestDevicesPA19.c to TestTonePA19.cpp and TestDevicesPA19.cpp.

	I was using VS2005, but it should be similar in 2003.


- Linux
1. Download a recent release of the portaudio source code from www.portaudio.org. The files are packed in *.tgz file. Extract the files from the *.tgz file. In the following example, I stored the portaudio files on my Desktop (~/Desktop/portaudio/).

2. Open a terminal window and cd to the portaudio directory:

cd ~/Desktop/portaudio

3. Compile portaudio with support for the ALSA backend using the following two commands:

./configure --with-alsa=yes --with-jack=no --with-oss=no
make

4. Copy the portaudio library you just compiled to the path where the TestTone source code lives, e.g.:

cp lib/.libs/libportaudio.a ~/matlab/mataa/TestTone/source/

5. Copy the portaudio library you just compiled to the path where the TestTone source code lives, e.g.:

cp include/portaudio.h ~/matlab/mataa/TestTone/source/

6. Compile TestTone and TestDevices using the following commands:

cd ~/matlab/mataa/TestTone/source/
gcc -lrt -lasound -lpthread -o TestTonePA19 TestTonePA19.c libportaudio.a
gcc -lrt -lasound -lpthread -o TestDevicesPA19 TestDevicesPA19.c libportaudio.a

7. Move the binaries you just compiled to the path where MATAA expects them (e.g. ~/matlab/mataa/TestTone/LINUX_X86 or ~/matlab/mataa/TestTone/LINUX_PPC):

mv TestTonePA19 ../LINUX_PPC/
mv TestDevicesPA19 ../LINUX_PPC/


* License and Copyright information:

TestTone and TestDevices are part of MATAA. MATAA is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

MATAA is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with MATAA; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

Copyright (C) 2006, 2007 Matthias S. Brennwald.

Contact
info@audioroot.net
http://www.audioroot.net/mataa.html
