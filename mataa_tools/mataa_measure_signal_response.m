function [responseSignal,inputSignal,t] = mataa_measure_signal_response(input_signal,fs,latency,verbose);

% function [responseSignal,inputSignal,t] = mataa_measure_signal_response(input_signal,fs,latency,verbose);
%
% DESCRIPTION:
% This function feeds one or more test signal(s) to the DUT(s) and records the response signal(s).
% 
% INPUT:
% input_signal: this is either a matrix containing the samples of the test signal, or a string containing the name of a TestTone file containing the test signal. See mataa_signal_to_TestToneFile for the format of the matrix containing the test signal samples. If a data file is given as the input, and if the file name is given without the full path of the file, the file is assumed to reside in the MATAA signals-path (you can retrieve the signals path with the command mataa_path('signals') ).
% 
% fs: the sampling rate to be used for the audio input / output (in Hz). Only sample rates supported by the hardware (or its driver software) are supported.
%
% latency: if the signal samples were specified rather than a file name/path, the signal is padded with zeros at its beginning and end to avoid cutting off the test signals early due to the latency of the sound input/output device(s). 'latency' is the length of the zero signals padded to the beginning and the end of the test signal (in seconds). If a file name is specified instead of the signal samples, the value of 'latency' is ignored.
% 
% verbose (optional): If verbose=0, no information or feedback is displayed. Otherwise, mataa_measure_signal_response prints feedback on the progress of the sound in/out. If verbose is not specified, verbose ~= 0 is assumed.
% 
% OUTPUT:
% inputSignal: matrix containing the input signal(s). This may be handy if the original test-signal data are stored in a file, which would otherwise have to be loaded into into workspace to be used.
%
% responseSignal: matrix containing the signal(s) from the audio input device. This will contain the data from all channels used for signal recording, where each matrix colum corresponds to one channel.
%
% t is vector containing the times corresponding the samples in responseSignal and inputSignal (in seconds)
%
% FURTHER INFORMATION:
% The signal samples range from -1.0 to +1.0).
% The TestTone program feeds the input_signal to both stereo channels of the output device, and records from both stereo channels of the input device (assuming we have a stereo device). Therefore, the response signal has two channels. As an example, channel 1 is used for for the DUT's response signal and channel 2 can be used to automatically calibrate for the frequency response / impulse response of the audio hardware (by directly connecting the audio output to the audio input). Channel allocation can be set using mataa_settings.
%
% EXAMPLE:
% Feed a 20Hz square-wave signal to the DUT and compare the input and response signals:
% > [out,in,t] = mataa_measure_signal_response('squareburst_96k_1s_20Hz.in',96000);
% > plot(t,in,t,out)
% 
% DISCLAIMER:
% This file is part of MATAA.
% 
% MATAA is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% MATAA is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with MATAA; if not, write to the Free Software
% Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
% 
% Copyright (C) 2006 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html
%
% HISTORY:
% 3. Nov 2008 (Matthias Brennwald): fixed the fix from yesterday...
% 2. November 2008 (Matthias Brennwald): fixed a problem that occurred if the MATAA files are in paths containing spaces
% 3. January 2008 (Matthias Brennwald): check for compatibility of number of input-signal channels with sound device only if input signal is given as a numerical matrix. The check is not done if the input signal is specified as a file name.
% 8. November 2007 (Matthias Brennwald): improved documentation
% 2. March 2007 (Matthias Brennwald): added check if input data has more channels than supported by the audio output device.
% 26. Feb., 1. March 2007 (Matthias Brennwald): added support for multi-channel signals (Thanks to Morten Laursen for compiling the multichannel version of TestTone for Windows).
% 15.2.2007: added missing fclose(...) after reading the data file with the signal data (Matthias Brennwald)
% 13.2.07: added a few error/sanity checks for the TestTone output (Matthias Brennwald)
% 8.2.07: cleaned up reading the data header
% 4.2.07: added changes for new TestDevices TestTone programs (change from Portaudio-18 to Portaudio-19), Matthias Brennwald.

if ~exist('verbose')
    verbose=1;
end

% check computer platform:
plat = mataa_computer;
if ( ~strcmp(plat,'MAC') && ~strcmp(plat,'PCWIN') )
% if ( ~strcmp(plat,'MAC') )
	error('mataa_measure_signal_response: Sorry, this computer platform is not (yet) supported by the TestTone program.');
end
%% if ((size(input_signal,2) > 1) && strcmp(plat,'PCWIN'))
%%     error('mataa_measure_signal_response: Multi-channel sound output is not yet supported on PC/Windows systems.');
%% end

% check audio hardware:
audioInfo = mataa_audio_info;
if strcmp(audioInfo.input.name,'(UNKNOWN)')
  error('mataa_measure_signal_response: No audio input device selected or no device available.');
end

if strcmp(audioInfo.output.name,'(UNKNOWN)')
   error('mataa_measure_signal_response: No audio output device selected or no device available.');
end



numInputChannels = audioInfo.input.channels;
if numInputChannels < 1
    error('mataa_measure_signal_response: The default audio input device has less than one input channel !?');
end

numOutputChannels = audioInfo.output.channels;

if ~isstr (input_signal)
    input_channels = size (input_signal,2);
    if numOutputChannels < input_channels
        error(sprintf('mataa_measure_signal_response: input data has more channels (%i) than supported by the audio output device (%i).',input_channels,numOutputChannels));
    end
end

if ~any(fs == audioInfo.input.sampleRates)
	warning(sprintf('The requested sample rate (%d Hz) is not listed for your audio input device. This is not always a problem, e.g. if the requested rate is available from sample-rate conversion by the operating system of if it is a non-standard rate that is not checked for by TestDevices but is supported by the audio hardware.',fs));
end

% do the sound I/O:
deleteInputFileAfterIO = 0;

if ~ischar(input_signal)
% signal samples have been specified instead of file name:
    if ~exist('latency')
        warning('mataa_measure_signal_response: latency not specified. Assuming latency = 0.1 seconds. Check for truncated data!');
        latency = 0.1;
    end
    if verbose
        disp('Writing sound data to disk...');
    end
    input_signal = mataa_signal_to_TestToneFile(input_signal,'',latency,fs);
    if verbose
        disp('...done');
    end
    deleteInputFileAfterIO = 1;
end

if length(input_signal)==0
    error('mataa_measure_signal_response: no input file specified.')
end

if ~any(findstr(input_signal,filesep))
    % only the file name without the path was specified
    % the file should therefore reside in the MATAA signals path
    in_path = [mataa_path('signals') input_signal];
else
    % the full path to the file was given
    in_path = input_signal;
end

if ~exist(in_path,'file')
    error(sprintf('mataa_measure_signal_response: could not find input file (''%s'').',in_path));
end

out_path = mataa_tempfile;

if exist('OCTAVE_VERSION')
	more('off'),
end
if verbose
    disp('Sound input / output started...');
    disp(sprintf('Sound output device: %s',audioInfo.output.name));
    disp(sprintf('Sound input device: %s',audioInfo.input.name));
    disp(sprintf('Sampling rate: %.3f kHz',fs/1000));
end


R = num2str(fs);

if strcmp(plat,'PCWIN')
    extension = '.exe';
else
    extension = '';
end    	

TestTone = sprintf('%s%s%s',mataa_path('TestTone'),'TestTonePA19',extension);

command = sprintf('"%s" %s %s > %s',TestTone,num2str(fs),in_path,out_path); % the ' are needed in case the paths contain spaces


status = -42; % in case the system command fails miserably, such that it does not even set the status flag
[output,status] = system(command);

if status ~= 0
    error('mataa_measure_signal_response: an error has occurred during sound I/O.')
end

if verbose
    disp('...sound I/O done.');
    disp('Reading sound data from disk...')
end

% GNU Octave does not a great job with 'out=load('matlab_dummy.out'). Also, Matlab's load command can be slow. The following approach is more reliable and (much) faster:
%if exist('OCTAVE_VERSION')		
    fid = fopen(out_path,'rt');
    if fid == -1
        error('mataa_octave_outsignal_load: could not find input file.');
    else
        frewind(fid);
        numChan = [];
        doRead = 1;
        while doRead % read the header
            l = fgetl(fid);
            % if findstr('Number of channels =',l) % for the old TestTone program
            if findstr('Number of sound input channels =',l) % for the new TestTone program
            	numChan = str2num(l(findstr('=',l)+1:end));
            elseif findstr('time (s)',l) % this was the last line of the header
            	doRead = 0;
            elseif ~isempty(str2num(l));
            	% if the 'time(s) ...' line is missing in the header for some reason...
           		% this is the first line of the data
           		doRead = 0;
           		fseek(fid,ftell(fid)-length(l)-1); % go back to the end of the previous line so that we won't miss the first line of the data later on
           	elseif l==-1
           		warning('mataa_measure_signal_response:end of data file reached prematurely! Is the data file corrupted?');
           		doRead = 0;
            end 
        end
        if isempty(numChan)
        	error('mataa_measure_signal_response: could not determine number of channels in recorded data.');
        end
        % read the data:
        out = fscanf(fid,'%f');
        l = length(out);
        if l < 1
        	error('mataa_measure_signal_response: no data found in TestTone output file.');
        end
        out = reshape(out',numChan+1,l/(numChan+1))';
        fclose(fid);
    end
% else
%     keyboard
% 	out=load(out_path); % normal Matlab-call
% end

if verbose
    disp('...data reading done.');
end

t=out(:,1);responseSignal=out(:,2:end);

inputSignal=load(in_path); % octave can easily read 1-row ASCII files

% clean up:
delete(out_path);
if deleteInputFileAfterIO
    delete(in_path);
end

if verbose
% check for clipping:
    for chan=1:size(responseSignal,2)
    	m = max(abs(responseSignal(:,chan)));
    	if m >= 1
    		k = find(abs(responseSignal(:,chan)) == m);
    		beep
    		disp(sprintf('Signal in channel %i may be clipped (%0.3g%% of all samples)!',chan,length(k)/length(responseSignal(:,1))*100));		
    		input('If you want to continue, press ENTER. To abort, press CTRL-C.');
    	else
    		disp(sprintf('Max amplitude in channel %i: %0.3g%%',chan,m*100));
    	end
    end
end