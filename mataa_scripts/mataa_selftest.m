% This script runs various tests to check the set up of MATAA
%
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
% 
% Copyright (C) 2006, 2007, 2008 Matthias S. Brennwald.
% Contact: info@audioroot.net
% Further information: http://www.audioroot.net/MATAA.html

if exist('OCTAVE_VERSION','builtin')
	more('off'),
end

err = 0;

disp('****** MATAA self test ******')

if exist('OCTAVE_VERSION','builtin')
    disp(sprintf('You are running Octave version %s.',version))
else
    disp(sprintf('You are running Matlab version %s.',version))
end

disp(sprintf('The computer platform is %s.',mataa_computer))

try
    p = mataa_path('main');
    if exist(p,'dir');
        disp(sprintf('MATAA main path is %s.',mataa_path('main')))
    else
        disp(sprintf('** ERROR: MATAA main path does not exist (%s)!',p))
    end
catch
    disp(sprintf('** ERROR: %s',lasterr));
end

try
    disp('Files and directories in the MATAA main path:')
    dir(mataa_path('main'))
catch
    disp(sprintf('** ERROR: %s',lasterr));
end

try
    p = mataa_path('signals');
    if exist(p,'dir');
        disp(sprintf('MATAA test-signals path is %s.',p))
    else
        disp(sprintf('** ERROR: MATAA test-signals path does not exist (%s)!',p))
    end
catch
    disp(sprintf('** ERROR: %s',lasterr));
end

try
    p = mataa_path('tools');
    if exist(p,'dir');
        disp(sprintf('MATAA tools path is %s.',p))
    else
        disp(sprintf('** ERROR: MATAA tools path does not exist (%s)!',p))
    end
catch
    disp(sprintf('** ERROR: %s',lasterr));
end

try
    p = mataa_path('TestTone');
    if exist(p,'dir');
        disp(sprintf('MATAA TestTone path is %s.',p))
    else
        disp(sprintf('** ERROR: MATAA TestTone path does not exist (%s). This may be no problem, if audio I/O does not rely on TestTone (see MATAA manual).',p))
    end
catch
    disp(sprintf('** ERROR: %s',lasterr));
end

try
    p = mataa_path('mataa_scripts');
    if exist(p,'dir');
        disp(sprintf('MATAA scripts path is %s.',p))
    else
        disp(sprintf('** ERROR: path to MATAA scripts does not exist (%s)!',p))
    end
catch
    disp(sprintf('** ERROR: %s',lasterr));
end

try
    p = mataa_path('microphone');
    if exist(p,'dir');
        disp(sprintf('MATAA path to microphone data is %s.',p))
    else
        disp(sprintf('** ERROR: path to microphone data does not exist (%s). This may be no problem if you do not use microphones.',p))
    end
catch
    disp(sprintf('** ERROR: %s',lasterr));
end

try
    disp('Your MATAA tools are (files and directories in the MATAA tools path):')
    dir(mataa_path('tools'))
catch
    disp(sprintf('** ERROR: %s',lasterr));
end

try
    disp('Your MATAA scripts are (files and directories in the MATAA scripts path):')
    dir(mataa_path('mataa_scripts'))
catch
    disp(sprintf('** ERROR: %s',lasterr));
end

try
    disp('Testing sound input/output...')
    % tryLatencyTest = 1;
    a = mataa_audio_info;
    disp(['  The audio device that will be used for audio output is: ' , a.output.name ]);
    disp(['  The audio host API is (output): ' , a.output.API ]);
    disp(['     Number of channels of output device: ' , num2str(a.output.channels) ]);
    disp(['     Minimum sampling rate (sound output): ' , num2str(min(a.output.sampleRates)) , ' Hz' ]);
    disp(['     Maximum sampling rate (sound output): ' , num2str(max(a.output.sampleRates)) , ' Hz' ]);
    disp(['  The audio device that will be used for audio input is: ' , a.input.name ]);
    disp(['  The audio host API is (intput): ' , a.input.API ]);
    disp(['     Number of channels of input device: ' , num2str(a.input.channels) ]);
    disp(['     Minimum sampling rate (sound input): ' , num2str(min(a.input.sampleRates)) , ' Hz' ]);
    disp(['     Maximum sampling rate (sound input): ' , num2str(max(a.input.sampleRates)) , ' Hz' ]);
    
    % find an appropriate sample rate:
    fs = intersect (a.input.sampleRates,a.output.sampleRates);
    [dummy,kk] = min(abs(fs-44100)); fs = fs(kk);
    
    f0 = 1000;
    T = 0.1;
    disp('  The audio I/O test will be done using a sine-wave signal with:')
    disp(sprintf('     frequency = %i Hz',f0))
    disp(sprintf('     duration = %f s',T))
    disp(sprintf('     sampling rate = %i Hz',fs))
    out = mataa_signal_generator('sine',fs,T,f0);
    disp('  Starting sound I/O...')
    in = mataa_measure_signal_response(out,fs,0);
    % delete(testfile);
    disp('   ...sound input/output done.')
    disp('   You may have noticed a short beep at the output of your sound output device.')
    for k=1:size(in,2)
        disp(sprintf('   The max. amplitude of the input signal in channel %i is %i%%',k,round(max(abs(in(:,k)))*100)))
    end
    disp('   (these values will depend on the setup of your audio device(s) and the the connections to it.)')
    disp('...testing of sound input/output completed.')
catch
    disp(sprintf('** ERROR: %s',lasterr));
    % tryLatencyTest = 0;
end

% if tryLatencyTest % don't try to do the latency test if the audio-info stuff did not work.
%     disp(sprintf('Guessing latency of your audio set up (sampling rate: %i Hz). Connect sound output to sound input for this test...',fs))
%     try
%         lat = mataa_audio_guess_latency(fs,1.0);
%         disp(sprintf('...done: latency = %f s',lat))
%     catch
%         disp('** ERROR: could not determine latency (is your audio hardware set up correctly? Is the audio output connected to the input?')
%     end
% end

disp('****** MATAA self test completed ******')
