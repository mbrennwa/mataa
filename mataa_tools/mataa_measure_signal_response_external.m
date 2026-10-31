function [dut_out, dut_in, t, dut_out_unit, dut_in_unit, X0_RMS] = mataa_measure_signal_response_external (file, fudge, cal);

% function [dut_out, dut_in, t, dut_out_unit, dut_in_unit, X0_RMS] = mataa_measure_signal_response_external (file, fudge, cal);
%
% DESCRIPTION:
% One capture of a stimulus that is played outside MATAA. Reads the whole WAV
% (see mataa_stimulus_wav_read), opens Playrec, then asks for playback to be
% started. After ENTER it records at once. Playrec is already open,
% so that wait is not spent initialising PortAudio. Recording starts when
% ENTER is pressed. Its length is fudge, then the whole stimulus file, then
% fudge again, so playback can be early or late and the file still lands
% inside the buffer. Alignment keeps the samples that correspond to the file
% and drops the fudge. That crop is then deconvolved with the file. The crop
% is calibrated on the capture path only.
%
% The playback chain is not connected to MATAA. DAC calibration is not applied,
% and mataa_signal_calibrate_DUTin is not called. A DAC field in cal is ignored.
%
% OUTPUTS match mataa_measure_signal_response. X0_RMS is the RMS of the
% non-zero span of the file, not the analog DAC-output level. dut_in is the
% whole file, including its own lead-in and trail.
%
% INPUT:
% file: WAV copy kept for MATAA (the file the external player was given).
% fudge: extra recording time before and after the stimulus file (seconds).
%   Playback and recording are not locked, so the same margin is needed on
%   both ends. It is not part of the deconvolution.
% cal (optional): capture-path calibration passed to mataa_signal_calibrate_DUTout.
%   Omit it, or pass [], to leave the recording in digital full scale (FS).
%   An ADC sensitivity_autoscalefunction is evaluated before recording, so an
%   RTX6001 input range is read from the unit. A DAC field is removed first.
%
% OUTPUT:
% dut_out, dut_in, t, dut_out_unit, dut_in_unit, X0_RMS: see mataa_measure_signal_response.
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
% Copyright (C) 2026 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if nargin < 2
	error('mataa_measure_signal_response_external: need file and fudge.');
end
if ~isscalar(fudge) || fudge < 0
	error('mataa_measure_signal_response_external: fudge must be a duration >= 0 seconds.');
end
if ~exist('cal', 'var')
	cal = [];
end
if iscell(cal)
	if isempty(cal)
		cal = [];
	else
		cal = cal{1};
	end
end
if ~isempty(cal)
	if ischar(cal)
		cal = mataa_load_calibration(cal);
	end
	% Playback is outside MATAA. Do not query or apply the DAC range.
	if isstruct(cal) && isfield(cal, 'DAC')
		cal = rmfield(cal, 'DAC');
	end
	cal = mataa_cal_autoscale(cal);
end

[s, fs] = mataa_stimulus_wav_read(file);
T_rec = fudge + length(s) / fs + fudge;
channel = mataa_settings('channel_DUT');

if exist('OCTAVE_VERSION', 'builtin')
	more('off');
end

% PortAudio's first open scans devices and is slow. Do it before the user
% starts playback, or the lead-in is gone before capture starts.
mataa_audio_record_open(fs, channel);

accepted = false;
while ~accepted
	if exist('stdout')
		fflush(stdout);
	end
	input('Start playback and press ENTER at the same time.', 's');
	% fudge before and after the file leaves room if playback is early or late.
	t_start = tic();
	disp('Recording now...');
	y = mataa_audio_record(fs, T_rec, channel);
	disp(sprintf('...done (%.3f seconds).', toc(t_start)));
	y = y(:, 1);

	m0 = 0.95;
	m = max(abs(y));
	if m >= m0
		k = find(abs(y) >= m0);
		disp(sprintf('Signal in channel %i may be clipped (%0.3g%% of all samples)!', channel, length(k) / length(y) * 100));
		if __retry_audio_IO()
			continue
		end
	else
		disp(sprintf('Max amplitude in channel %i (DUT): %0.3g%%', channel, m * 100));
	end
	accepted = true;
end

% Keep the recording that corresponds to the whole stimulus file.
[y_crop, x_ref, rho] = mataa_signal_align_stimulus(y, s, fs, 'file');

if isempty(cal)
	dut_out = y_crop;
	dut_out_unit = 'FS';
	t = (0:length(dut_out)-1)' / fs;
else
	[dut_out, t, dut_out_unit] = mataa_signal_calibrate_DUTout(y_crop, fs, cal);
	dut_out = dut_out(:);
	t = t(:);
end

ksig = find(s ~= 0);
if length(dut_out) < ksig(end)
	error('mataa_measure_signal_response_external: calibrated recording is shorter than the stimulus.');
end
% x_ref is the whole stimulus file. Keep its start if calibration drops a sample.
if length(dut_out) <= length(x_ref)
	dut_in = x_ref(1:length(dut_out));
else
	dut_in = [ x_ref ; zeros(length(dut_out) - length(x_ref), 1) ];
end
if length(t) ~= length(dut_out)
	t = (0:length(dut_out)-1)' / fs;
end

dut_out_unit = {dut_out_unit};
dut_in_unit = {'FS'};
% Zeros in the lead-in and trail add no energy. Divide by the non-zero span
% so that padding does not scale the impulse down.
X0_RMS = sqrt(sum(s.^2) / (ksig(end) - ksig(1) + 1));
if length(x_ref) < 1 || ~isfinite(rho)
	error('mataa_measure_signal_response_external: alignment did not return a reference.');
end

end


function ans = __retry_audio_IO()
	ans = [];
	while isempty(ans)
		ans = upper([input('Repeat the measurement? (Y/N)', 's') 'x'])(1);
	end
	if upper(ans) == 'Y'
		ans = true;
	else
		ans = false;
	end
end
