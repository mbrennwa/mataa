function mataa_export_FRD (f,mag,phase,comment,file);

% function mataa_export_FRD (f,mag,phase,comment,file);
%
% DESCRIPTION:
% Export frequency-domain data to a FRD file.
% (see also http://www.pvconsultants.com/audio/frdis.htm)
% An FRD file is essentially an ASCII file containing three columns of data: frequency, magnitude, and phase. A detailed description of the FRD file format is given below.
%
% INPUT:
% f: frequency values (Hz)
% mag: magnitude values (usually in dB)
% phase: phase (in degrees, usually wrapped to the range -180...+180 degrees)
% file: string containing the name of the file to be written (may contain a complete path. If no path is given, the file will be written to the current working directory)
% comment: string containing a comment to be saved with the data, e.g. a description of the data. Use comment = '' if you do not want a comment in the data file.
% 
% OUTPUT:
% (none)
%
% DESCRIPTION OF THE FRD FILE FORMAT
% The following is a detailed description of the FRD format (taken from the website given above):
% --------------------------------
% What is an FRD File?
% 
% A Frequency Response Data file is a human readable text file that contains a numerical description of Frequency and Phase Response.  The purpose of an FRD file to represent measurements or targets or corrections of acoustic items, like loudspeakers and/or crossovers or room effects. The reason for using FRD files is to pass information between different design programs and thus to get the programs to share data and work together to achieve a complete finished design.
% 
% Structurally, an FRD file is very simple. An * is placed in the first character position of any line that is a comment, so the remainder of that line is ignored. Comments can only be added at the beginning of an FRD file and not embedded once the data starts.
% 
% After the comment, the data block is composed of three numerical values per line separated by either one or more spaces or a tab. Each line is a single measurement or value instance. The numerical values, in order, per line, correspond to Frequency, Magnitude and Phase. The frequency data should start at the low end of the response and proceed to the higher end with no directional reversals or overlapping repeating regions in the frequency progression. That is all. It should look something like this:
% 
%         
%        * Seas T25-001.frd
%        * Freq(Hz)  SPL(db)  Phase(deg)
%        *
%        10        21.0963   158.4356 
%        10.1517   21.0967   158.4363 
%        10.3056   21.3305   158.7836 
%        10.4619   21.5644   159.1299 
%        10.6205   21.7983   159.2452 
%        10.7816   22.032     159.3599 
%        10.9451   22.2658   159.4099 
%        11.1111   22.4996   159.4597 
%        11.2796   22.7335   159.4832 
%        11.4507   22.9672   159.5065 
%        11.6243   23.2011   159.5171 
%        11.8006   23.4349   159.5276 
%        11.9795   23.6687   159.5308 
%        12.1612   23.9025   159.534 
% 
% The comment field mentioned above is sometimes required, even if the data in it is never used, or at least we have encountered programs that will not load the FRD file if the Comment field is not there. We have also found the opposite, programs that get confused about the comment field and work better if there was none. In general the comments are useful to the human reader and specific to the last program to output the data. So box modelers may have the conditions used to create the curve, like Vb, Driver name and T/S parameters, etc.
% 
% It is usually better that the data blocks have boundaries on the numbers used. Although Scientific Notation is permitted, it is usually better, more accurate and much more readable if the numbers used have exactly four decimal places below the dot (greater accuracy is really not helpful and less has been show to induce jitter from Group Delay derived or other secondary processing). In addition, it greatly simplified the operation of any subsequent program if the Frequency spacing is even and progresses in a log spacing format. This tends to spread the samples evenly over the frequency segment.
% 
% The Magnitude number is log gain and in db values. The scale can be SPL @ wattage @ distance format (hovering about 90) or a unity aligned offset (usually just above zero for diffraction or starting at and diving below zero steeply for box models and crossover functions). The Phase data is best if in degrees, from –180 to +180 wrapping.
% 
% In general, there are good reasons to keep the frequency sampling density high enough to accurately represent a complex waveform sequence (without losing detail) but not so dense as to generate large amounts of extra sample data. Usually between 200 to 250 samples per decade, which is about 60 to 75 samples per octave, works very well.
% 
% When processing files and using the resultants, there are also good reasons to have the response extend at least one octave and preferably 2 or more octaves beyond the region of interest (above and below) so as to keep phase tracking error very low. This is especially important when deriving Minimum Phase or Optimizing crossovers downstream. A good standard to target is the internal default one of the Frequency Response Combiner program, which was selected for those reasons above (sample density and frequency extension) and for a close adherence to digital sound cards sampling rates, and also that the sample set was easily sub-divided into many equal sized integer count pieces (2, 3, 4, 6, 7, 8, 14, 16, 21, 24). The FRC program default standard for internal FRD data calculation is 2 Hz to 96,000 Hz with 1176 equal log spaced samples or about 251 samples per decade.
% --------------------------------
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
% Further information: http://www.audioroot.net/MATAA.html

f = f(:);
mag = mag(:);
phase = phase(:);

N = length (f);

if length (mag) ~= N
    error ('mataa_export_FRD: mag must be of the same size as f.')
end

if length (mag) ~= N
    error ('mataa_export_FRD: phase must be of the same size as f.')
end

if length (file) == 0
    error ('mataa_export_FRD: the file name must not be empty.');
end

if length (file) < 4
    file = sprintf ('%s.FRD',file); % append '.FRD'
end

if ~strcmp (upper (file(end-3:end)),'.FRD')
    file = sprintf ('%s.FRD',file); % append '.FRD'
end

if exist(file,'file')
    beep;
    overwrite = input(sprintf("File %s exists. Enter 'Y' or 'y' to overwrite, or anything else to cancel.",file),"s");
    if ~strcmp(lower(overwrite),"y")
        disp ('File not saved, user cancelled.')
        return
    else
        disp (sprintf('Overwriting %s...',file));
    end
end

[fid,msg] = fopen (file,'wt');

if fid == -1
    error (sprintf ('mataa_export_FRD: %s',msg))
end

fprintf (fid,'* FRD data written by MATAA on %s\n',datestr (now));

if ~isempty (comment)
    fprintf (fid,'* %s\n',comment);
end

for i = 1:N-1
    fprintf (fid,'%f\t%f\t%f\n',f(i),mag(i),phase(i))
end
fprintf (fid,'%f\t%f\t%f',f(N),mag(N),phase(N)) % print last line without line break

fclose (fid);
