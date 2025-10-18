function audioInfo = mataa_audio_info;

% function audioInfo = mataa_audio_info;
%
% DESCRIPTION:
% This function returns a struct (audioInfo) containing information on the default devices for audio input and output. Note: the list of supported sample rates reflects the 'standard' rates offered by the operating system. This is not necessarily identical to the rates supported by hardware itself, as the operating system may provide other rates, e.g. by (automatic) sample-rate conversion (such as in the case of Mac OS X / CoreAudio). Also, the list of supported sample rates may be incomplete, because the TestDevices programs checks for 'standard' rates only. It may therefore be possible to use other sample rates than those returned from this function (check the description of your audio hardware if you need to know the rates supported by the hardware). This function checks for full and half duplex operation (i.e. if the input and output devices are the same), and returns the list of supported sample rates depending on full or half duplex operation (they may be different, e.g. if a high sampling rate is only available with half duplex due to limits in the data transfer rates).
%
% NOTE: some audio interfaces react in unwanted ways to the audio-info query. For instance, the RTX-6001 goes through a nasty cycle of relays clicking, which causes clicks in its audio output and may lead to excessive wear of the relays. To avoid such effects, the test query can be skipped by changing the value of the 'audioinfo_skipcheck' field in the MATAA settings to a non-zero value. mataa_audio_info will then return audioInfo corresponding to a "typical" generic audio interface.
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
% Copyright (C) 2006, 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

% prepare device info (with empty/unknown entries):
audioInfo.input.name = '(UNKNOWN)';
audioInfo.input.channels = [];
audioInfo.input.sampleRates = [];
audioInfo.input.API = 'UNKNOWN';
audioInfo.output.API = 'UNKNOWN';
audioInfo.output = audioInfo.input;

% determine computer OS platform:
plat = mataa_computer;

% check if running TestDevices should be avoided:
u = mataa_settings ('audioinfo_skipcheck');
if isempty(u) % settings don't have the skipcheck field
	mataa_settings ('audioinfo_skipcheck',0); % set and store default
	u = 0;
end

if u
	% Skip the TestDevices run, return generic info for a typical audio interface instead
	
	%%% warning ('mataa_audio_interface: checking audio interface properties is turned off in the MATAA settings. Returning audio info for a typical / generic audio interface!')
	
	API = '???';
	switch plat
		case 'MAC'
			API = 'Core Audio';
		case 'PCWIN'
			API = 'ASIO';
		case 'LINUX_X86-32'
			API = 'ALSA';
		case 'LINUX_X86-64'
			API = 'ALSA';
		case 'LINUX_PPC'
			API = 'ALSA';
		case 'LINUX_ARM_GNUEABIHF'
			API = 'ALSA';
		case 'LINUX_ARM_AARCH64'
			API = 'ALSA';
		end
    
	audioInfo.input.name = '***GENERIC-UNTESTED***';
	audioInfo.input.channels = 2;
	audioInfo.input.sampleRates = [ 44100 48000 88200 96000 176400 192000 ];
	audioInfo.input.API = API;
	audioInfo.output = audioInfo.input;
	
else
	
	try
		audio_IO_method = mataa_settings ('audio_IO_method');
	catch
		audio_IO_method = 'TestTone';
	end

	if strcmp(upper(audio_IO_method),'TESTTONE')

		switch plat
		 case {'MAC','PCWIN','LINUX_X86-32','LINUX_X86-64','LINUX_PPC','LINUX_ARM_GNUEABIHF'}
				if strcmp(plat,'PCWIN')
					extension = '.exe';
				else
					extension = '';
				end    	
		 
				TestDevices = sprintf('%s%s%s',mataa_path('TestDevices'),'TestDevicesPA19',extension);
				
				infoFile = mataa_tempfile;

				input_sampleRates_halfDuplex = [];
				input_sampleRates_fullDuplex = [];
				output_sampleRates_halfDuplex = [];
				output_sampleRates_fullDuplex = [];
				
				if strcmp(plat,'PCWIN')
					system(sprintf('"%s" > %s',TestDevices,infoFile)); % the ' are needed if the paths contain spaces
				else
					system(sprintf('"%s" > %s 2>/dev/null',TestDevices,infoFile)); % the ' are needed if the paths contain spaces
				end
						
				fid=fopen(infoFile,'rt');
				l = 0;
				while l ~=-1
					l = fgetl(fid);
					% disp (l)
					if findstr (l,'Default input device')
						l = l(findstr(l,'=')+2:end);
						if length(l) > 0
							audioInfo.input.name = l;
						end
					end;
					if findstr (l,'Host API (input)'), audioInfo.input.API = l(20:end); end;
					if findstr (l,'Host API (output)'), audioInfo.output.API = l(21:end); end;
					if findstr (l,'Max input channels'), audioInfo.input.channels = str2num(l(findstr(l,'=')+1:end)); end;
					if findstr (l,'Supported standard sample rates (input, full-duplex'), input_sampleRates_fullDuplex = str2num(l(findstr(l,'=')+1:end)); end;
					if findstr (l,'Supported standard sample rates (input, half-duplex'), input_sampleRates_halfDuplex = str2num(l(findstr(l,'=')+1:end)); end;
					if findstr (l,'Default output device')
						l = l(findstr(l,'=')+2:end);
						if length(l) > 0
							audioInfo.output.name = l;
						end
					end;
					
					if findstr (l,'Max output channels'), audioInfo.output.channels = str2num(l(findstr(l,'=')+1:end)); end;
					if findstr (l,'Supported standard sample rates (output, full-duplex'), output_sampleRates_fullDuplex = str2num(l(findstr(l,'=')+1:end)); end;
					if findstr (l,'Supported standard sample rates (output, half-duplex'), output_sampleRates_halfDuplex = str2num(l(findstr(l,'=')+1:end)); end;
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
				error(sprintf('mataa_audio_info: Sorry, this computer platform is not (yet) supported by the TestDevices program.',plat));
		end % switch
	
	elseif strcmp(upper(audio_IO_method),'PLAYREC')
		
		warning ('mataa_audio_info: audio I/O using PlayRec is not yet implemented. Using generic audio device parameters...')
		
		u = mataa_settings ('audioinfo_skipcheck');
		u = mataa_settings ('audioinfo_skipcheck', 1);
		audioInfo = mataa_audio_info()
		u = mataa_settings ('audioinfo_skipcheck', u);
		audioInfo.input.name = '***PLAYREC -- GENERIC-UNTESTED***';
		audioInfo.output.name = '***PLAYREC -- GENERIC-UNTESTED***';
		
	else
		error (sprintf('mataa_audio_info: unknown audio I/O method <%s>.',audio_IO_method))

	end
	
end
