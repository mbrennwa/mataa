function audioInfo = mataa_audio_info;

% function audioInfo = mataa_audio_info;
%
% DESCRIPTION:
% This function returns a struct (audioInfo) containing information on the default devices for audio input and output. Note: the list of supported sample rates reflects the 'standard' rates offered by the operating system. This is not necessarily identical to the rates supported by hardware itself, as the operating system may provide other rates, e.g. by (automatic) sample-rate conversion (such as in the case of Mac OS X / CoreAudio). Also, the list of supported sample rates may be incomplete, because the TestDevices programs checks for 'standard' rates only. It may therefore be possible to use other sample rates than those returned from this function (check the description of your audio hardware if you need to know the rates supported by the hardware). This function checks for full and half duplex operation (i.e. if the input and output devices are the same), and returns the list of supported sample rates depending on full or half duplex operation (they may be different, e.g. if a high sampling rate is only available with half duplex due to limits in the data transfer rates).
%
% EXAMPLE:
% (get some information on the audio hardware):
% > info = mataa_audio_info;
% > info.input      % shows information about the input device
% > info.output     % shows information about the output device
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
% 6. March 2007: code cleanup to avoid problem with Octave on Windows and fix output if no sound devices are found (return name '(UNKNOWN)' instead of name = []);
% 14. Feb 2007: changed double quotes to single quotes -- 'MAC' instead of "MAC" etc., for compatibility with Matlab. Problem reported by Morten Laursen. (Matthias Brennwald)
% 13. Feb. 2007: added support PCWIN versions of TestDevices  (Matthias Brennwald)
% 4. Feb. 2007: rewrote code for use new TestDevices program to accomodate changes from Portaudio-18 to Portaudio-19. Also added check for full/half duplex (Matthias Brennwald)

plat = mataa_computer;

switch plat
    case {'MAC','PCWIN'}
    	if strcmp(plat,'PCWIN')
    		extension = '.exe';
    	else
    		extension = '';
    	end    	
 
    	TestDevices = sprintf('%s%s%s',mataa_path('TestDevices'),'TestDevicesPA19',extension);
     	
	   	infoFile = mataa_tempfile;
    	% prepare device info (with empty/unknown entries):
    	audioInfo.input.name = '(UNKNOWN)';
    	audioInfo.input.channels = [];
    	audioInfo.input.sampleRates = [];
    	audioInfo.output = audioInfo.input;
    	input_sampleRates_halfDuplex = [];
    	input_sampleRates_fullDuplex = [];
    	output_sampleRates_halfDuplex = [];
    	output_sampleRates_fullDuplex = [];
    	system(sprintf('%s > %s',TestDevices,infoFile));
        fid=fopen(infoFile,'rt');
        l = 0;
        while l ~=-1
            l = fgetl(fid);
            if findstr(l,'Default input device')
            	l = l(findstr(l,'=')+2:end);
            	if length(l) > 0
   	 	        	audioInfo.input.name = l;
            	end
            end;
            if findstr(l,'Max input channels'), audioInfo.input.channels = str2num(l(findstr(l,'=')+1:end)); end;
            if findstr(l,'Supported standard sample rates (input, full-duplex)'), input_sampleRates_fullDuplex = str2num(l(findstr(l,'=')+1:end)); end;
            if findstr(l,'Supported standard sample rates (input, half-duplex)'), input_sampleRates_halfDuplex = str2num(l(findstr(l,'=')+1:end)); end;
            if findstr(l,'Default output device')
            	l = l(findstr(l,'=')+2:end);
            	if length(l) > 0
   	 	        	audioInfo.output.name = l;
            	end
            end;
            if findstr(l,'Max output channels'), audioInfo.output.channels = str2num(l(findstr(l,'=')+1:end)); end;
            if findstr(l,'Supported standard sample rates (output, full-duplex)'), output_sampleRates_fullDuplex = str2num(l(findstr(l,'=')+1:end)); end;
            if findstr(l,'Supported standard sample rates (output, half-duplex)'), output_sampleRates_halfDuplex = str2num(l(findstr(l,'=')+1:end)); end;
        end
    	fclose(fid);
    	delete(infoFile);
    	
       	if strcmp(audioInfo.input.name,audioInfo.output.name) % full-duplex operation
	    	audioInfo.input.sampleRates = input_sampleRates_fullDuplex;
    		audioInfo.output.sampleRates = output_sampleRates_fullDuplex;
    	else % half-duplex operation
    		audioInfo.input.sampleRates = input_sampleRates_halfDuplex;
    		audioInfo.output.sampleRates = output_sampleRates_halfDuplex;
    	end
    		
    otherwise
    	error(sprintf('Sorry, this computer platform is not (yet) supported by the TestDevices program.',plat));
end % switch