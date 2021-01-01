function [dut_out,dut_in,t,dut_out_unit,dut_in_unit,X0_RMS] = mataa_measure_signal_response (X0,fs,latency,verbose,channels,cal,X0_unit);

% function [dut_out,dut_in,t,dut_out_unit,dut_in_unit] = mataa_measure_signal_response (X0,fs,latency,verbose,channels,cal,X0_unit);
%
% DESCRIPTION:
% This function feeds one or more test signal(s) to the DUT(s) and records the response signal(s).
% See also note on channel numbers and allocation of DAC, ADC and cal channel numbers below!
% 
% INPUT:
% X0: test signal with values ranging from -1...+1. For a single signal (same signal for all DAC output channels), X0 is a vector. For different signals, X0 is a matrix, with each column corresponding to one channel
% fs: the sampling rate to be used for the audio input / output (in Hz). Only sample rates supported by the hardware (or its driver software) are supported.
% latency: the signal data in X0 are padded with zeros at the beginning and end to avoid cutting off the test signals early due to the latency of the sound input/output device(s). 'latency' is the length of the zero signals padded to the beginning and the end of the test signal (in seconds).C
% verbose (optional): If verbose=0, no information or feedback is displayed. Otherwise, mataa_measure_signal_response prints feedback on the progress of the sound in/out. If verbose is not specified, verbose ~= 0 is assumed.
% channels (optional): index to data channels obtained from the ADC that should be processed and returned. If not specified, all data channels are returned.
% cal (optional): calibration data for the full analysis chain DAC / SENSOR / ADC (see mataa_signal_calibrate_DUTin and mataa_signal_calibrate_DUTout for details). If different audio channels are used with different hardware (e.g., a microphone in the DUT channel and a loopback without microphone in the REF channel), separate structs describing the hardware of each channel can be provided in a cell array. If no cal is given or cal = [], the data will not be calibrated.
% X0_unit (optional): unit of test signal data in X0 (string):
%	If unit = 'digital' (default): X0 signal is given in digital domain. The X0 values are sent to the DAC without any amplitude conversion. X0 values are allowed to range from -1 to +1, corresponding to the min. and max. value of the analog signal at the DAC output.
%	If unit = unit of the sensitivity value specified in the cal data for the DAC analog output signal (e.g., unit = 'V': X0 signal is given in the physical units of the ; X0 reflects the signal voltage that is generated at the DAC output. The X0 voltages are converted to "digital domain values" using the DAC sensitivity given in the 'cal' data before the data is sent the DAC. X0 values are allowed to range from the min. to max. voltages that can be generated by the DAC output.
% 
% OUTPUT:
% dut_out: matrix containing the signal(s) at the DUT output(s) / SENSOR input(s) (all channels used for signal recording, each colum corresponds to one channel). If SENSOR and ADC cal data are available, these data are calibrated for the input sensitivity of the SENSOR and ADC.
% dut_in: matrix containing the signal(s) at the DAC(+BUFFER) output(s) / DUT input. If DAC cal data are available, these data are calibrated for the output sensitivity of the DAC(+BUFFER). This may also be handy if the original test-signal data are stored in a file, which would otherwise have to be loaded into into workspace to be used.
% t: vector containing the times corresponding the samples in dut_out and dut_in (in seconds)
% dut_out_unit: unit of data in dut_out. If the signal has more than one channel, signal_unit is a cell string with each cell reflecting the units of each signal channel.
% dut_in_unit: unit of data in dut_in (analogous to dut_out_unit)
% X0_RMS: RMS amplitude of signal at DUT input / DAC(+BUFFER) output (same unit as dut_in data). This may be different from the RMS amplitude of dut_in due to the zero-padding of dut_in in order to accomodate for the latency of the analysis system; the X0_RMS value is determined from the test signal before zero padding.
%
%
% NOTES:
%
% (1) As a general rule, the number of DAC channels (X0) and the number of ADC channels ('channels' index) must be the same:
% * In many situations the optional 'channels' index for the ADC channels can be omitted or left empty (channels=[]). The index will then be set automatically to channels = [1:size(X0,2)] (i.e., the ADC channel numbers correspond to the DAC channel numbers). 
% * Some audio interfaces have more ADC channels than DAC channels, so it is necessary to explicitly specify which ADC channels are used. Example for an audio interface with 2 DACs and 4 ADCs: using X0 with two channels (size(X0,2)=2) requires two ADC channels. If channels = [], ADC channels 1 and 2 will be used automatically. To use ADC channels 3 and 4 instead, set channels=[3,4].
% * If cal data is specified, each channel needs its own cal data, so length(cal) = size(X0,2). If cal is not specified, the cal data for each channel will be set to cal{k}=[], and the data will remain uncalibrated.
%
% (2) If the DAC output is specified as "digital" (no physical unit for X0 data), the signal samples may range from -1.0 to +1.0.
%
%
% EXAMPLES:
%
% (1) Feed a 1 kHz sine-wave signal to the DUT and plot the DUT output (no data calibration):
% > fs = 44100;
% > [s,t] = mataa_signal_generator ('sine',fs,0.2,1000);
% > [out,in,t,out_unit,in_unit] = mataa_measure_signal_response(s,fs,0.1,1,1);
% > plot (t,out);
% > xlabel ('Time (s)')
%
% (2) Feed a 1 kHz sine-wave signal with a 1.8 Volt amplitude (zero-to-peak) to the DUT, use calibration as in GENERIC_CHAIN_DIRECT.txt file, and compare the input and response signals:
% > fs = 44100;
% > [s,t] = mataa_signal_generator ('sine',fs,0.2,1000);
% > [out,in,t,out_unit,in_unit] = mataa_measure_signal_response(1.8*s,fs,0.1,1,1,'GENERIC_CHAIN_DIRECT.txt','V');
% > subplot (2,1,1); plot (t,in); ylabel (sprintf('Signal at DUT input (%s)',in_unit));
% > subplot (2,1,2); plot (t,out); ylabel (sprintf('Signal at DUT output (%s)',out_unit));
% > xlabel ('Time (s)')
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


1;


function ans = __retry_audio_IO()
	ans = [];
	while isempty(ans)
    		ans = upper([input('Repeat the measurement? (Y/N)','g') 'x'])(1);
    		ans = strfind ('NY',ans);
    	end
    	ans = ( ans == 2 );
endfunction



% check input
if ~exist ('channels','var')
	channels = [];
end
if isempty(channels)
	channels = [1:size(X0,2)];
end
if length(channels) ~= size(X0,2)
	error (sprintf('mataa_measure_signal_response: the number of ADC data channels (%i) must not be different from the number of DAC channels in X0 (%i)!',length(channels),size(X0,2)))
end

if ~exist ('cal','var')
	for k = 1:size(X0,2)
		cal{k} = [];
	end
end

if ~exist('verbose','var')
    verbose=1;
end

% check computer platform:
plat = mataa_computer;
if ( ~strcmp(plat,'MAC') && ~strcmp(plat,'PCWIN') && ~strcmp(plat,'LINUX_X86-32') && ~strcmp(plat,'LINUX_X86-64') && ~strcmp(plat,'LINUX_PPC')  && ~strcmp(plat,'LINUX_ARM_GNUEABIHF') )
	error('mataa_measure_signal_response: Sorry, this computer platform is not (yet) supported by the TestTone program.');
end

% check audio hardware:
audioInfo = mataa_audio_info;

switch plat
case 'MAC'
    desired_API = 'Core Audio';
case 'PCWIN'
    desired_API = 'ASIO';
case 'LINUX_X86-32'
    desired_API = 'ALSA';
case 'LINUX_X86-64'
    desired_API = 'ALSA';
case 'LINUX_PPC'
    desired_API = 'ALSA';
case 'LINUX_ARM_GNUEABIHF'
    desired_API = 'ALSA';
end
if ~strcmp (audioInfo.input.API,desired_API)
    warning (sprintf('mataa_measure_signal_response: The recommended sound API on your computer platform (%s) is %s, but your default input device uses another API (%s). Please see the MATAA manual.',plat,desired_API,audioInfo.input.API));
end
if ~strcmp (audioInfo.output.API,desired_API)
    warning (sprintf('mataa_measure_signal_response: The recommended sound API on your computer platform (%s) is %s, but you default output device uses another API (%s). Please see the MATAA manual.',plat,desired_API,audioInfo.output.API));
end

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

if ischar (X0)
	error ('mataa_measure_signal_response: use of this function with loading test signals from data files is not supported anymore. Please load the data first, then use this function with a vecor or matrix containing the test signal data.')
end

input_channels = size (X0,2);
if numOutputChannels < input_channels
	error(sprintf('mataa_measure_signal_response: input data has more channels (%i) than supported by the audio output device (%i).',input_channels,numOutputChannels));
end

if ~any(fs == audioInfo.input.sampleRates)
	warning(sprintf('The requested sample rate (%d Hz) is not listed for your audio input device. This is not always a problem, e.g. if the requested rate is available from sample-rate conversion by the operating system of if it is a non-standard rate that is not checked for by TestDevices but is supported by the audio hardware.',fs));
end

if ~any(fs == audioInfo.output.sampleRates)
	warning(sprintf('The requested sample rate (%d Hz) is not listed for your audio output device. This is not always a problem, e.g. if the requested rate is available from sample-rate conversion by the operating system of if it is a non-standard rate that is not checked for by TestDevices but is supported by the audio hardware.',fs));
end

% get/load cal data if necessary:
if ischar(cal) % name of calibration file instead of cal struct
	if strcmp (cal,'')
		cal = [];
	else
		cal = mataa_load_calibration (cal);
	end
end

cal_ini = cal;
X0_ini = X0;

do_try_audio_IO = true;
while do_try_audio_IO
% several attempts may be required if signals are found to be clipped etc.

	% assume this will be the last attempt (this may change later)
	do_try_audio_IO = false;
	
	% init flag for "DAC output cal is okay":
	cal_dac_out_ok = false;

	% deal with autoscaling (evaluate autoscaling function):
	cal = mataa_cal_autoscale (cal_ini);
	
	% init X0 to initial version (if repeating the measurement)
	X0 = X0_ini;

	if ~iscell(cal)
		u{1} = cal; cal = u;
	end

	if length(cal) ~= size(X0,2)
		% need exactly one cal struct per signal channel to calibrate the data in each channel!
		error (sprintf('mataa_measure_signal_response: number of channels in test signal X0 (%i) must not be different from number of channels in cal structs (%i).',size(X0,2),length(cal)))
	end

	% deal with data unit of X0 / test signal data:
	if ~exist ('X0_unit','var')
		X0_unit = 'digital';
	end

	if strcmp (upper(X0_unit),'DIGITAL') % no amplitude conversion
		if max(X0) > 1.0
			error ('mataa_measure_signal_response: max. value of X0 is higher than 1.0 in digital domain.')
		elseif min(X0) < -1.0
			error ('mataa_measure_signal_response: min. value of X0 is lower than -1.0 in digital domain.')
		else
			cal_dac_out_ok = true;
		end

	else % convert data in each channel of X0 to "digital" using the sensitivity of the DAC cal before sending signal to DAC
		for k = 1:size(X0,2)
			if ~isfield(cal{k},'DAC')
				error ('mataa_measure_signal_response: cal data has no DAC field, cannot convert X0 voltages to digital domain (-1...+1).')
			else
				if ~strcmp(upper(X0_unit),upper(cal{k}.DAC.sensitivity_unit))
					error (sprintf("mataa_measure_signal_response: X0 data given in %s, but analog output of DAC '%s' is in units %s.",X0_unit,cal{k}.DAC.name,cal{k}.DAC.sensitivity_unit))
				else
					if max(X0(:,k)) > cal{k}.DAC.sensitivity
						disp (sprintf("mataa_measure_signal_response: max. value of X0 (%g Volts) is higher than analog output limit of DAC '%s' (%g %s)",max(X0(:,k)),cal{k}.DAC.name,cal{k}.DAC.sensitivity,cal{k}.DAC.sensitivity_unit))
						do_try_audio_IO = __retry_audio_IO();
					elseif min(X0(:,k)) < -cal{k}.DAC.sensitivity
						disp (sprintf("mataa_measure_signal_response: min. value of X0 (%g Volts) is lower than analog output limit of DAC '%s' (%g %s)",min(X0(:,k)),cal{k}.DAC.name,cal{k}.DAC.sensitivity,cal{k}.DAC.sensitivity_unit))
						do_try_audio_IO = __retry_audio_IO();
					else
						X0(:,k) = X0(:,k) / cal{k}.DAC.sensitivity; % scale to digital domain
						cal_dac_out_ok = true;
					end
				end % if else
			end % if else
		end % for
	end % if else


	if cal_dac_out_ok

		% do the sound I/O:	
		try
			audio_IO_method = mataa_settings ('audio_IO_method');
		catch
			audio_IO_method = 'TestTone';
		end

		% determine latency:
		default_latency = 0.1 * max([1 fs/44100]); % just from experience with Behringer UMC202HD and M-AUDIO FW-410
		if ~exist('latency','var')
			latency = [];
		end
		if isempty (latency)
			latency = default_latency;
			warning(sprintf('mataa_measure_signal_response: latency not specified. Assuming latency = %g seconds. Check for truncated data!',latency));
		elseif latency < default_latency
			warning(sprintf('mataa_measure_signal_response: latency (%gs) is less than generic default (%gs). Make sure this is really what you want and check for truncated data!',latency,default_latency));
		end




		tic();





		if strcmp(upper(audio_IO_method),'TESTTONE')

			deleteInputFileAfterIO = 0;

			if verbose
				disp('Writing sound data to disk...');
			end
			in_path = mataa_signal_to_TestToneFile(X0,'',latency,fs);
			if verbose
				disp('...done');
			end
			if ~exist(in_path,'file')
				error(sprintf('mataa_measure_signal_response: could not find input file (''%s'').',in_path));
			end
			deleteInputFileAfterIO = 1;
			out_path = mataa_tempfile;

			if exist('OCTAVE_VERSION','builtin')
				more('off'),
			end
			if verbose
				disp('Sound input / output started...');
				disp(sprintf('Sound output device: %s',audioInfo.output.name));
				disp(sprintf('Sound input device: %s',audioInfo.input.name));
				disp(sprintf('Sampling rate: %.3f samples per second',fs));
			end

			R = num2str(fs);

			if strcmp(plat,'PCWIN')
				extension = '.exe';
			else
				extension = '';
			end    	

			TestTone = sprintf('%s%s%s',mataa_path('TestTone'),'TestTonePA19',extension);
			command = sprintf('"%s" %s %s > %s 2>/dev/null',TestTone,num2str(fs),in_path,out_path); % the ' are needed in case the paths contain spaces
			[output,status] = system(command);

			if status ~= 0
				error('mataa_measure_signal_response: an error has occurred during sound I/O.')
			end

			if verbose
				disp('...sound I/O done.');
				disp('Reading sound data from disk...')
			end


			fid = fopen(out_path,'rt');
			if fid == -1
				error('mataa_measure_signal_response: could not find input file.');
			else
				frewind(fid);
				numChan = [];
				doRead = 1;
				while doRead % read the header
					l = fgetl(fid);
					if isempty(l)
						error('mataa_measure_signal_response: found empty line in header, cannot continue.')
					end
					if l==-1
						error('mataa_measure_signal_response: end of data file reached prematurely! Is the data file corrupted?');
					end
					if strfind(upper(l),'ERROR')
						error(sprintf('mataa_measure_signal_response: %s',l));
					end
					if findstr('Number of sound input channels =',l)
						numChan = str2num(l(findstr('=',l)+1:end));
						elseif findstr('time (s)',l) % this was the last line of the header
						doRead = 0;
					elseif ~isempty(str2num(l));
						% this is the first line of the data block
						doRead = 0;
						fseek(fid,ftell(fid)-length(l)-1); % go back to the end of the previous line so that we won't miss the first line of the data later on
					end
				end % while doRead
				
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
				clear numChan % avoid confusion with numChan below
			end

			if verbose
				disp('...data reading done.');
			end

			t=out(:,1);dut_out=out(:,2:end);

			% keep only ADC channels as given in channels, discard the rest:
			dut_out = dut_out(:,channels);

			dut_in=load(in_path); % octave can easily read 1-row ASCII files
			
			% clean up:
			delete(out_path);
			if deleteInputFileAfterIO
			    delete(in_path);
			end

		elseif strcmp(upper(audio_IO_method),'PLAYREC')
			
			% make sure PlayRec is initialised as needed:
			ID_out = mataa_settings ('audio_PlayRec_OutputDeviceName');
			if isempty (ID_out)
				ID_out = 0;
			end
			ID_in  = mataa_settings ('audio_PlayRec_InputDeviceName');
			if isempty (ID_in)
				ID_in = 0;
			end
			if ~mataa_audio_playrec_init(fs, ID_out, ID_in, max(channels), max(channels))
				error('mataa_measure_signal_response: could not configure PlayRec as needed.')
			end
			
			% zeroes for latency:
			z = repmat(0,round(latency*fs),size(X0,2));
			dut_in = [ z ; X0 ; z ];
			
			% Start audio input / output (with zero padding for latency):
			pageNumber = playrec('playrec', dut_in, 1:max(channels), -1, channels );
			
			% Wait until audio input / output is done:
			%%% while ( playrec('isFinished', pageNumber) == 0 ); end; % this will run the CPU at full power!
			playrec('block', pageNumber); % tell PlayRec to block until audio I/O is done (this may introduce a delay until PlayRec unblocks, but does not waste CPU power)
			
			% get audio data:
			dut_out = playrec('getRec', pageNumber);
			
			% determine time values:
			t = [0:size(dut_out,1)-1](:) / fs;
			
			% clear PlayRec audio page
			playrec('delPage');
			
		else
			error (sprintf('mataa_measure_signal_response: unknown audio I/O method <%s>.',audio_IO_method))

		end % audio_IO_method = TESTTONE or PlayRec



					
		elaps = toc();
		elaps = elaps - ( t(end)-t(1) )



		if verbose
		% check for clipping:
			for chan=1:size(dut_out,2)
				m = max(abs(dut_out(:,chan)));
				m0 = 0.95;
				if m >= m0
					k = find(abs(dut_out(:,chan)) >= m0);
					beep
					disp(sprintf('Signal in channel %i may be clipped (%0.3g%% of all samples)!',channels(chan),length(k)/length(dut_out(:,1))*100));		
					%%% input('If you want to continue, press ENTER. To abort, press CTRL-C.');
					do_try_audio_IO = __retry_audio_IO();
				else
					u = '';
					if channels(chan) == mataa_settings ('channel_DUT')
						u = ' (DUT)';
					elseif channels(chan) == mataa_settings ('channel_REF')
						u = ' (REF)';
					end
					disp(sprintf('Max amplitude in channel %i%s: %0.3g%%',channels(chan),u,m*100));
				end % if m >= m0
			end % for chan=...
		end % if verbose

		
		
		if ~do_try_audio_IO && exist('dut_out','var')
		% audio IO was okay (no need to retry), so let's try to calibrate the result
			
			X0_RMS = repmat(NA,1,size(X0,2));

			for k = 1:length(cal)
				% calibrate k-th channel

				if isempty(cal{k})
					disp (sprintf('mataa_measure_signal_response: no calibration data available for channel %i. Returning raw, uncalibrated data!',k))
					dut_out_unit{k} = '???'; 
					dut_in_unit{k}  = '???';
				else

					if isfield(cal{k},'DAC')

						% calibrate signal at DUT input for DAC(+BUFFER):
						RMS_raw = sqrt (sum(dut_in(:,k).^2 / length(dut_in(:,k))));
						[dut_in(:,k),t_in,dut_in_unit{k}] = mataa_signal_calibrate_DUTin (dut_in(:,k),t,cal{k});
						RMS_cal = sqrt (sum(dut_in(:,k).^2 / length(dut_in(:,k))));

						% determine RMS amplitude of signal at DUT input (without zero padding):
						X0_RMS(k) = RMS_cal/RMS_raw * sqrt (sum(X0(:,k).^2 / length(X0(:,k))));

					else
						warning (sprintf('mataa_measure_signal_response: cal data for channel %i has no ADC data! Skipping calibration of signal at DUT input!',k))
					end


					if isfield(cal{k},'ADC')
						if isfield(cal{k},'SENSOR')
							[dut_out(:,k),t_out,dut_out_unit{k}] = mataa_signal_calibrate_DUTout (dut_out(:,k),t,cal{k}); % calibrate signal at DUT output for SENSOR and ADC
						else
							warning (sprintf('mataa_measure_signal_response: cal data for channel %i has no SENSOR data! Skipping calibration of signal at DUT output!',k))
						end
					else
						warning (sprintf('mataa_measure_signal_response: cal data for channel %i has no ADC data! Skipping calibration of signal at DUT input!',k))
					end
				end % if isempty(...)
			end % for	
		end % if ~do_try_audio_IO
	end % if cal_dac_out ok
end % while do_try_audio_IO

% make sure all messages to STDOUT are out:
if exist('stdout')
	fflush (stdout);
end

if ~exist('dut_out','var')
	% measurement failed:
	error ('mataa_measure_signal_response: measurement failed.')
end

endfunction
