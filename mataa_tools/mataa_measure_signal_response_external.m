function [dut_out, dut_in, t, dut_out_unit, dut_in_unit, X0_RMS] = mataa_measure_signal_response_external (file, fudge, cal);

% function [dut_out, dut_in, t, dut_out_unit, dut_in_unit, X0_RMS] = mataa_measure_signal_response_external (file, fudge, cal);
%
% DESCRIPTION:
% One capture of a stimulus that is played outside MATAA. Reads the WAV copy
% (see mataa_stimulus_wav_read), asks for playback to be started, waits 0.5 s
% after ENTER, then records with mataa_audio_record. The recording is aligned
% to the bare stimulus, cropped, and calibrated on the capture path only.
%
% The playback chain is not connected to MATAA. DAC calibration is not applied,
% and mataa_signal_calibrate_DUTin is not called. A DAC field in cal is ignored.
%
% OUTPUTS match mataa_measure_signal_response. X0_RMS is the RMS of the bare
% digital stimulus, not the analog DAC-output level. dut_in is that stimulus
% with trailing zeros so it has the same length as the cropped recording.
%
% INPUT:
% file: WAV copy kept for MATAA (the file the external player was given).
% fudge: extra recording time (seconds) after the lead-in and the stimulus.
%   It covers the player's output delay and the response tail to keep.
%   It is not T_trail from the file.
% cal (optional): capture-path calibration passed to mataa_signal_calibrate_DUTout.
%   Omit it, or pass [], to leave the recording in digital full scale (FS).
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

[s, fs, T_lead, T_trail] = mataa_stimulus_wav_read(file);
T = length(s) / fs;
T_rec = T_lead + T + fudge;
channel = mataa_settings('channel_DUT');
disp(sprintf('mataa_measure_signal_response_external: stimulus %.3f s, lead-in %.3f s, file trail %.3f s, recording %.3f s at %g Hz.', T, T_lead, T_trail, T_rec, fs));

if exist('OCTAVE_VERSION', 'builtin')
	more('off');
end

accepted = false;
while ~accepted
	if exist('stdout')
		fflush(stdout);
	end
	input('Start playback on the external player, then press ENTER...', 's');
	pause(0.5);
	y = mataa_audio_record(fs, T_rec, channel);
	y = y(:, 1);

	m0 = 0.95;
	m = max(abs(y));
	if m >= m0
		k = find(abs(y) >= m0);
		if exist('beep')
			beep
		end
		disp(sprintf('Signal in channel %i may be clipped (%0.3g%% of all samples)!', channel, length(k) / length(y) * 100));
		if __retry_audio_IO()
			continue
		end
	else
		disp(sprintf('Max amplitude in channel %i (DUT): %0.3g%%', channel, m * 100));
	end
	accepted = true;
end

[y_crop, x_ref, rho] = mataa_signal_align_stimulus(y, s, fs);

if isempty(cal)
	dut_out = y_crop;
	dut_out_unit = 'FS';
	t = (0:length(dut_out)-1)' / fs;
else
	[dut_out, t, dut_out_unit] = mataa_signal_calibrate_DUTout(y_crop, fs, cal);
	dut_out = dut_out(:);
	t = t(:);
end

if length(dut_out) < length(s)
	error('mataa_measure_signal_response_external: calibrated recording is shorter than the stimulus.');
end
dut_in = [ s(:) ; zeros(length(dut_out) - length(s), 1) ];
if length(t) ~= length(dut_out)
	t = (0:length(dut_out)-1)' / fs;
end

dut_out_unit = {dut_out_unit};
dut_in_unit = {'FS'};
X0_RMS = sqrt(sum(s.^2) / length(s));

% x_ref from the aligner is the uncalibrated-length reference. dut_in is
% rebuilt so it matches the calibrated length. rho is printed by the aligner.
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
