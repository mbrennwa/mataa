function h = mataa_IR_deconvolve (dut, ref, rms);

% function h = mataa_IR_deconvolve (dut, ref, rms);
%
% DESCRIPTION:
% Deconvolve dut by ref using the same end-ramp, frequency-domain division,
% DC removal, and real-part cleanup as mataa_measure_IR, then multiply by rms.
% There is no loopback branch. mataa_deConvolve is not used: it has no end-ramp.
% mataa_measure_IR is left unchanged and does not call this function.
%
% INPUT:
% dut: recorded signal (vector), same length as ref.
% ref: reference signal (vector), same length as dut.
% rms: scale factor applied after deconvolution (scalar). For an external
%      stimulus this is the RMS of the bare digital stimulus.
%
% OUTPUT:
% h: impulse response (column), same length as dut.
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

if nargin < 3
	error('mataa_IR_deconvolve: need dut, ref, and rms.');
end
if ~isvector(dut) || ~isvector(ref) || isempty(dut)
	error('mataa_IR_deconvolve: dut and ref must be non-empty vectors of the same length.');
end
dut = dut(:);
ref = ref(:);
if length(dut) ~= length(ref)
	error('mataa_IR_deconvolve: dut and ref must have the same length.');
end
if ~isscalar(rms) || ~isfinite(rms)
	error('mataa_IR_deconvolve: rms must be a finite scalar.');
end

% Same ramp, division, DC removal, and real-part cleanup as mataa_measure_IR.
l = length(dut);
uu = flipud([1:l]' / l);
dut = [ dut ; uu * dut(end) ];
ref = [ ref ; uu * ref(end) ];
H = fft(dut) ./ fft(ref);
H(1) = 0;
dummy = ifft(H);
dummy = dummy(1:l);
h = abs(dummy) .* sign(real(dummy));
h = h * rms;

end
