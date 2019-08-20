function mag = mataa_FR_inbox_convert (mag,f,Vb,r);

% function mag = mataa_FR_inbox_convert (mag,f,Vb,r);
%
% DESCRIPTION:
% Convert SPL frequency response measured inside a loudspeaker box to free-field SPL frequency response (2pi). The method follows the description by R.H. Small (see reference below), but does not implement the compensation of acoustic losses (expressed as QL in the Small paper). The microphone-in-box (MIB) technique is useful to determine the acoustic performance of a loudspaker at low frequencies in the 2pi free field. The MIB technique works well for closed and vented boxes, no matter how many radiators there are. It is not suitable for transmission lines. If Vb and r are specified (optional), the code calculates the absolute free-field SPL response. Otherwise the SPL curve is normalized to 0 dB-SPL at 100 Hz. Note that the method yields the 2pi free field SPL response, so it does not account for baffle edge diffraction of similar effects. Also note that the results are strictly only accurate for frequencies with wavelength that are considerably larger than the longest dimension of the loudspeaker box. However, it is often possible to stretch this limit a bit by experimenting with the microphone position within the box (positioning the microphone close to the geometric center of the box often allows a somewhat higher upper frequency limit).
% 
% See also:
% - R.H. Small, “Simplified Loudspeaker Measurements at low Frequencies”, J. Audio Engineering Society, Vol. 20, pp. 28-33, 1972
% - https://www.audioxpress.com/article/measuring-loudspeaker-low-frequency-response
%
% INPUT:
% mag: SPL magnitude inside the box (in dB-SPL)
% f: frequency values corresponding to the mag data
% Vb (optional): box volume (in L)
% r (optional): distance used to calculate/normalize the free-field SPL level (in m)
%
% OUTPUT:
% mag: free-field frequency response (magnitude in dB-SPL)
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
% Copyright (C) 2019 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

% check input arguments:
if nargin < 3
	Vb = 1;
	r = 1;
	f_norm = 100;
else
	f_norm = [];
end

% constants:
rho0  = 1.18;  % density of air at typical room temperature, at sea level (kg/m3)
c     = 343;   % speed of sound (m/s)
p_ref = 20E-6; % reference SPL level at 0 dB-SPL

% convert in-box SPL from dB-SPL do Pa:
pB = 10.^(mag/20) * p_ref; % SPL in Pa






% Evaluate R.H. Small eqns (1), (2), and (3)
warning ('************** mataa_FR_inbox_convert: this function is not yet fully implemented. DO NOT USE IT! **************')






% Convert pr to dB-SPL:
mag = 20*log10(pr/p_ref); % free-field SPL in dB-SPL

% normalize SPL (optional):
if ~isempty(f_norm)
	mag = mag - interp1(f,mag,f_norm,"linear","extrap");
end
