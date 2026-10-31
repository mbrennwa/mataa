function mataa_test_external_stimulus

% function mataa_test_external_stimulus
%
% DESCRIPTION:
% Synthetic checks for the external-stimulus path. Does not open a sound
% device and does not change MATAA settings.
%
% Checks the WAV round trip, alignment (including a rejected noise buffer
% and a stimulus that starts before the buffer), deconvolution of a known
% two-point impulse, and the same impulse after mataa_signal_calibrate_DUTout
% with FLAT_MICROPHONE.txt. The calibrated impulse must stay at the start.
%
% EXAMPLE:
% > mataa_test_external_stimulus
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

script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
	script_dir = pwd;
end
addpath(fullfile(fileparts(script_dir), 'mataa_tools'));

if exist('OCTAVE_VERSION', 'builtin')
	more('off');
end

fs = 48000;
n = round(0.2 * fs);
tt = (0:n-1)' / fs;
x = 0.5 * sin(2 * pi * 440 * tt + 0.7);
if x(1) == 0 || x(end) == 0
	error('mataa_test_external_stimulus: test stimulus touches zero at an end.');
end

wav = [tempname() '.wav'];
unwind_protect
	mataa_stimulus_wav_write(x, fs, wav, 0.05, 0.02);
	[s, fs2, T_lead, T_trail] = mataa_stimulus_wav_read(wav);
	__check(fs2 == fs, 'sample rate changed');
	__check(max(abs(s - x)) < 1e-6, 'WAV samples did not round-trip');
	__check(abs(T_lead - 0.05) <= 1/fs, 'lead-in length changed');
	__check(abs(T_trail - 0.02) <= 1/fs, 'trail length changed');

	D = 1000;
	tail = 500;
	y = [ zeros(D,1) ; x ; zeros(tail,1) ];
	[y_crop, x_ref, rho] = mataa_signal_align_stimulus(y, x, fs);
	__check(rho > 0.2, 'delayed stimulus correlation is weak');
	__check(max(abs(y_crop(1:length(x)) - x)) < 1e-12, 'crop does not start at the stimulus');
	__check(length(y_crop) == length(x) + tail, 'crop dropped the tail or kept the lead-in');
	__check(max(abs(x_ref - [x ; zeros(tail,1)])) < 1e-12, 'reference padding is wrong');

	rejected = false;
	try
		mataa_signal_align_stimulus(randn(5 * length(x), 1), x, fs);
	catch err
		msg = err.message;
		if ~isempty(strfind(msg, 'correlation')) || ~isempty(strfind(msg, 'inside'))
			rejected = true;
		else
			rethrow(err);
		end
	end
	__check(rejected, 'noise was accepted as the stimulus');

	rejected = false;
	try
		mataa_signal_align_stimulus([ x(200:end) ; zeros(300,1) ], x, fs);
	catch err
		msg = err.message;
		if ~isempty(strfind(msg, 'inside')) || ~isempty(strfind(msg, 'correlation'))
			rejected = true;
		else
			rethrow(err);
		end
	end
	__check(rejected, 'a stimulus that starts before the buffer was accepted');

	yd = [ zeros(40,1) ; 1 ; zeros(15,1) ];
	[y_dirac, x_dirac, rho_dirac] = mataa_signal_align_stimulus(yd, 1, fs);
	__check(y_dirac(1) == 1, 'Dirac onset was missed');
	__check(x_dirac(1) == 1, 'Dirac reference was missed');
	__check(rho_dirac > 0.99, 'Dirac correlation collapsed');

	h_true = [1; -0.5];
	y = [ zeros(800,1) ; conv(x, h_true) ; zeros(400,1) ];
	[y_crop, x_ref, rho] = mataa_signal_align_stimulus(y, x, fs);
	__check(rho > 0.2, 'convolved stimulus correlation is weak');
	rms = sqrt(sum(x.^2) / length(x));
	h = mataa_IR_deconvolve(y_crop, x_ref, rms);
	[~, i_peak] = max(abs(h));
	__check(i_peak <= 2, sprintf('impulse peak is at sample %d, not at the start', i_peak));
	__check(h(i_peak) > 0, 'impulse sign was reversed');
	__check(h(i_peak + 1) < 0, 'second tap sign was reversed');
	__check(abs(h(i_peak) / rms - 1) < 0.05, sprintf('first tap is %g, expected about %g', h(i_peak), rms));
	__check(abs(h(i_peak + 1) / rms + 0.5) < 0.05, sprintf('second tap is %g, expected about %g', h(i_peak + 1), -0.5 * rms));

	% File span: lead silence, sweep, trail silence. A fudge tail past the
	% file must not be kept. The rise before the impulse peak must survive.
	T_lead = 0.05;
	T_trail = 0.01;
	n_lead = round(T_lead * fs);
	n_trail = round(T_trail * fs);
	n_fudge = round(0.02 * fs);
	n_rise = round(0.3e-3 * fs);
	h_rise = [ (1:n_rise)' / n_rise ; -1 ; 0.5 * exp(-(0:30)' / 10) ];
	x_sw = mataa_signal_generator('sweep', fs, 0.2, [100 fs/2]);
	x_sw = x_sw(:);
	y_sw = [ zeros(5000, 1) ; conv([zeros(n_lead, 1); x_sw; zeros(n_trail, 1)], h_rise) ; zeros(n_fudge, 1) ];
	[y_file, x_file] = mataa_signal_align_stimulus(y_sw, x_sw, fs, T_lead, T_trail);
	__check(length(y_file) == n_lead + length(x_sw) + n_trail, sprintf('file window is %d samples', length(y_file)));
	__check(length(x_file) == length(y_file), 'file reference length differs from the crop');
	__check(max(abs(x_file(1:n_lead))) == 0, 'lead-in in the reference is not silent');
	__check(max(abs(x_file(n_lead + (1:length(x_sw))) - x_sw)) < 1e-12, 'bare stimulus moved inside the file reference');
	__check(max(abs(x_file(end - n_trail + 1:end))) == 0, 'trail in the reference is not silent');
	rms_sw = sqrt(sum(x_sw.^2) / length(x_sw));
	h_file = mataa_IR_deconvolve(y_file, x_file, rms_sw);
	[~, i_file] = max(abs(h_file));
	__check(i_file > n_rise, sprintf('file-span impulse peak is at sample %d; the rise was cropped', i_file));
	__check(abs(h_file(i_file - n_rise)) < 0.2 * abs(h_file(i_file)), 'file-span impulse does not start from a quiet sample');
	__check(abs(abs(h_file(i_file)) / rms_sw - 1) < 0.15, sprintf('file-span peak is %g, expected about %g', h_file(i_file), -rms_sw));

	[y_cal, t_cal, unit_cal] = mataa_signal_calibrate_DUTout(y_crop, fs, 'FLAT_MICROPHONE.txt');
	y_cal = y_cal(:);
	t_cal = t_cal(:);
	__check(length(y_cal) == length(t_cal), 'calibrated time vector does not match the signal');
	__check(strcmp(unit_cal, 'Pa'), sprintf('calibrated unit is %s, expected Pa', unit_cal));
	x_cal = [ x(:) ; zeros(length(y_cal) - length(x), 1) ];
	h_cal = mataa_IR_deconvolve(y_cal, x_cal, rms);
	[~, i_peak_cal] = max(abs(h_cal));
	__check(i_peak_cal <= 2, sprintf('calibrated impulse peak is at sample %d (not at the start)', i_peak_cal));
	__check(i_peak_cal < length(h_cal) / 2, 'calibrated impulse was time-reversed');
	__check(h_cal(i_peak_cal) > 0, 'calibrated impulse sign was reversed');
	__check(h_cal(i_peak_cal + 1) < 0, 'calibrated second tap sign was reversed');
	% FLAT_MICROPHONE.txt is 15 mV/Pa. With no ADC field the capture gain is that sensitivity.
	sens = 0.015;
	__check(abs(h_cal(i_peak_cal) / rms * sens - 1) < 0.02, sprintf('calibrated peak is %g Pa, expected about %g Pa', h_cal(i_peak_cal), rms / sens));
unwind_protect_cleanup
	if exist(wav, 'file')
		delete(wav);
	end
end_unwind_protect

disp('mataa_test_external_stimulus: all checks passed.');

end


function __check (cond, msg)
	if ~cond
		error(sprintf('mataa_test_external_stimulus: %s', msg));
	end
end
