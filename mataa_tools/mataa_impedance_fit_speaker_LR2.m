function [Rdc,f0,Qe,Qm,L1,L2,R2] = mataa_impedance_fit_speaker_LR2 (f,mag,phase);

% function [Rdc,f0,Qe,Qm,L1,L2,R2] = mataa_impedance_fit_speaker_LR2 (f,mag,phase);
%
% DESCRIPTION:
% Fits the impedance model of mataa_impedance_speaker_model_LR2 to the impedance data mag(f) and phase(f). This can be useful in determining Thielle/Small parameters from impedance measurements.
%
% INPUT:
% f: frequency values of the impedance data
% mag: magnitude of impedance data (Ohm)
% phase: phase of impedance data (degrees)
%
% OUTPUT:
% Rdc, f0, Qe, Qm, L1, L2, R2: see mataa_impedance_speaker_model_LR2 (input parameters)
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
% Copyright (C) 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA

if exist ('OCTAVE_VERSION','builtin')
    if ~exist ('fminsearch','file')
        error ('mataa_impedance_fit_speaker: the ''fminsearch'' function is missing. You may need to install the optim package from Octave forge.')
    end
end

if ~(length (f) == length (mag))
    error ('mataa_impedance_fit_speaker: f and mag must be of the same length.')
end

% unwrap phase:
phase = unwrap (phase/180*pi)/pi*180;

% guess starting value for Rdc:
Rdc = min (mag);

% guess starting values for f0:
u = diff (mag);
F = ( f(1:end-1) + f(2:end))/2;
[u1,k1] = max (u); [u2,k2] = min (u);
if ~exist ('f0','var')
    f0 = (F(k1)+F(k2))/2;
end
clear F

% estimate impedance at f0:
[u,k] = min(abs(f-f0));
Rmax = mag(k);
clear u
clear k

% estimate f1 and f2:
k = find(f<f0);
[u,k] = min(abs(mag(k)-sqrt(Rmax*Rdc)));
f1 = f(k);
clear u
clear k
f2 = f0^2/f1;

% guess starting values for Qe and Qm:
Qm = f0/(f2-f1)*sqrt(Rmax/Rdc);
Qe = Qm / (Rmax/Rdc-1);

clear f1
clear f2

i_low = find (f < 3*f0);
i_high = find (f >= 3*f0);

% find best-fit values of Rdc, f0, Q, L1, L2, and R2:
global ff = f;
global ff_low = f (i_low);
global ff_high = f (i_high);
global mm = mag;
global pp = phase;
global mm_low = mag(i_low);
global mm_high = mag(i_high);;
global pp_low = phase(i_low);
global pp_high = phase(i_high);;
global x1

% fit low-frequency part
x0 = [Rdc f0 Qe Qm];
x1 = fminsearch (@ZspeakerMin_low,x0);

% fit high-frequency part:
x0 = [1 1 1];
x2 = fminsearch (@ZspeakerMin_high,x0);

% fit full frequency range:
x0 = [x1 x2];
x = fminsearch (@ZspeakerMin_full,x0);
% x = x0;

clear global ff
clear global mm

Rdc = x(1);
f0  = x(2);
Qe  = x(3);
Qm  = x(4);
L1  = x(5)/1000;
L2  = x(6)/1000;
R2  = x(7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function chiSquare = ZspeakerMin_general (f,MAG,PHAS,Rdc,f0,Qe,Qm,L1,L2,R2)
x = [Rdc,f0,Qe,Qm,L1,L2,R2];
if any (i = find (x < 0))
    chiSquare = 1E7 + (sum (abs (x(i))))^10;
elseif Rdc == 0
    chiSquare = 1E7;
elseif Qe == 0
    chiSquare = 1E7;
elseif Qm == 0
    chiSquare = 1E7;
elseif f0 == 0
    chiSquare = 1E7;
elseif R2 == 0
    chiSquare = 1E7;
else
    [m,p] = mataa_impedance_speaker_model_LR2 (f,Rdc,f0,Qe,Qm,L1/1000,L2/1000,R2);
    chiSquare = sum ((m-MAG).^2) + sum ( ( (p-mean (p)) - (PHAS-mean(PHAS)) ).^2);
end




function chiSquare = ZspeakerMin_low (x)
    global ff_low;
    global mm_low;
    global pp_low;
    
    chiSquare = ZspeakerMin_general(ff_low,mm_low,pp_low,x(1),x(2),x(3),x(4),0,0,Inf);




function chiSquare = ZspeakerMin_high (x)
    global ff_high;
    global mm_high;
    global pp_high;
    global x1;
    
    chiSquare = ZspeakerMin_general(ff_high,mm_high,pp_high,x1(1),x1(2),x1(3),x1(4),x(1),x(2),x(3)); 




function chiSquare = ZspeakerMin_full (x)
    global ff;
    global mm;
    global pp;

    chiSquare = ZspeakerMin_general(ff,mm,pp,x(1),x(2),x(3),x(4),x(5),x(6),x(7)); 
