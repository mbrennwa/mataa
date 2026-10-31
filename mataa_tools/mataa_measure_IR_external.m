function [h, t, unit] = mataa_measure_IR_external (file, fudge, N, cal);

% function [h, t, unit] = mataa_measure_IR_external (file, fudge, N, cal);
%
% DESCRIPTION:
% Measure an impulse response from a stimulus played outside MATAA.
% Each take calls mataa_measure_signal_response_external (which prompts for
% playback) and deconvolves with mataa_IR_deconvolve. N takes are averaged.
% If the crops differ in length, they are truncated to the shortest take.
%
% mataa_guess_IR_start and mataa_IR_to_FR stay with the caller, as they do
% for mataa_measure_IR. This function does not drive the playback device and
% does not apply loopback compensation.
%
% INPUT:
% file: WAV copy kept for MATAA. See mataa_stimulus_wav_write.
% fudge: see mataa_measure_signal_response_external.
% N (optional): number of takes to average. Default is 1.
% cal (optional): see mataa_measure_signal_response_external.
%
% OUTPUT:
% h: impulse response, in the unit of the calibrated recording.
% t: time vector (seconds).
% unit: unit of h. FS when cal is omitted. Pascals for a measurement microphone.
%
% EXAMPLE:
% > [s,t] = mataa_signal_generator('sweep',48000,1,[50 20000]);
% > mataa_stimulus_wav_write(s,48000,'stimulus.wav',2,0.5);
% > % Load stimulus.wav into the external player. Keep this copy for MATAA.
% > mataa_settings('audio_IO_method','Playrec');
% > [h,t,unit] = mataa_measure_IR_external('stimulus.wav',2,1,'GENERIC_CHAIN_ACOUSTIC.txt');
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
	error('mataa_measure_IR_external: need file and fudge.');
end
if ~exist('N', 'var') || isempty(N)
	N = 1;
end
if ~isscalar(N) || N < 1 || N ~= fix(N)
	error('mataa_measure_IR_external: N must be an integer >= 1.');
end
if ~exist('cal', 'var')
	cal = [];
end

if exist('OCTAVE_VERSION', 'builtin')
	more('off');
end

takes = {};
times = {};
units = {};
for i = 1:N
	if N > 1
		disp(sprintf('mataa_measure_IR_external: take %d of %d.', i, N));
	end
	if isempty(cal)
		[out, in, t_i, out_unit, in_unit, X0_RMS] = mataa_measure_signal_response_external(file, fudge);
	else
		[out, in, t_i, out_unit, in_unit, X0_RMS] = mataa_measure_signal_response_external(file, fudge, cal);
	end
	if iscell(in_unit)
		in_unit = in_unit{1};
	end
	if ~strcmp(in_unit, 'FS')
		warning(sprintf('mataa_measure_IR_external: reference unit is %s, expected FS.', in_unit));
	end
	disp('Deconvolving external-stimulus recording...');
	takes{i} = mataa_IR_deconvolve(out(:,1), in(:,1), mean(X0_RMS));
	times{i} = t_i(:);
	if iscell(out_unit)
		units{i} = out_unit{1};
	else
		units{i} = out_unit;
	end
	disp('...deconvolution done.');
end

nmin = min(cellfun(@length, takes));
if any(cellfun(@length, takes) ~= nmin)
	warning('mataa_measure_IR_external: takes differ in length. Averaging the first shared samples only.');
end
h = zeros(nmin, 1);
for i = 1:N
	h = h + takes{i}(1:nmin) / N;
end
t = times{1}(1:nmin);
unit = units{1};

end
