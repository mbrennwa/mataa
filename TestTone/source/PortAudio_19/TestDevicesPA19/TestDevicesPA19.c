/*
 * This is the source code for TestDevicesPA19, which is based on PortAudio V19 (http://www.portaudio.com).
 *
 * TestDevices is part of MATAA. MATAA is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * MATAA is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with MATAA; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 * 
 * Copyright (C) 2006, 2007 Matthias S. Brennwald.
 * Contact: info@audioroot.net
 * Further information: http://www.audioroot.net/mataa.html
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "portaudio.h"

#ifdef WIN32
#ifndef PA_NO_ASIO
#include "pa_asio.h"
#endif
#endif

#define PA_SAMPLE_TYPE  paFloat32


/*******************************************************************/
static void PrintSupportedStandardSampleRates(
        const PaStreamParameters *inputParameters,
        const PaStreamParameters *outputParameters )
{
    static double standardSampleRates[] = {
        1000.0, 2000.0, 4000.0, 8000.0, 9600.0, 11025.0, 12000.0, 16000.0, 22050.0, 24000.0, 32000.0,
        44100.0, 48000.0, 64000.0, 88200.0, 96000.0, 192000.0, -1 /* negative terminated  list */
    };
    int     i, printCount;
    PaError err;

    printCount = 0;
    for( i=0; standardSampleRates[i] > 0; i++ )
    {
        err = Pa_IsFormatSupported( inputParameters, outputParameters, standardSampleRates[i] );
        if( err == paFormatIsSupported )
        {
            if( printCount == 0 )
            {
                printf( "\t%8.2f", standardSampleRates[i] );
                printCount = 1;
            }
            else
            {
                printf( ", %8.2f", standardSampleRates[i] );
                ++printCount;
            }
        }
    }
    if( !printCount )
        printf( "None\n" );
    else
        printf( "\n" );
}

int main(int argc, char *argv[]);
int main(int argc, char *argv[])
{
    int     i, numDevices, defaultInputFound, defaultOutputFound;
    const   PaDeviceInfo *deviceInfo;
    PaStreamParameters inputParameters, outputParameters;
    PaError err;

    argc -=1; /* first argument is call to TestTone itself */

    if (argc > 0) {
		printf("TestDevices usage:\n");
		printf("'TestDevices' displays the properties of the default audio devices for sound input and output.\n\n");
		printf("Note: the list of supported sample rates reflects the 'standard' rates offered by the operating system or the driver software of the sound device. This is not necessarily identical to the rates supported natively by hardware itself, as the operating system or the driver software may provide automatic sample-rate conversion (e.g. Mac OS X / CoreAudio). Also, the list of supported sample rates may be incomplete, because the TestDevices program checks for 'standard' rates only. It is therefore possible that sample rates other than those listed may be used with the device.\n\n");
		printf("TestDevices is part of MATAA. MATAA is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.\n\n");
		printf("MATAA is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.\n\n");
		printf("You should have received a copy of the GNU General Public License along with MATAA; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA\n\n");
		printf("Copyright (C) 2007 Matthias S. Brennwald.\nContact: info@audioroot.net\nFurther information: http://www.audioroot.net/mataa.html\n");
		exit(1);
	}

    
    Pa_Initialize();
            
    numDevices = Pa_GetDeviceCount();
    if( numDevices < 0 )
    {
        printf( "ERROR: Pa_CountDevices returned 0x%x\n", numDevices );
        err = numDevices;
        goto error;
    }
    	
	defaultInputFound = 0;
	defaultOutputFound = 0;
    
	for( i=0; i<numDevices; i++ )
    {
        deviceInfo = Pa_GetDeviceInfo( i );
		
		if( i == Pa_GetDefaultInputDevice() ) // display info for default input
        {
			defaultInputFound = 1;
            printf( "Default input device = %s\n", deviceInfo->name );
			printf( "Max input channels = %d\n", deviceInfo->maxInputChannels  );
			inputParameters.device = i;
			inputParameters.channelCount = deviceInfo->maxInputChannels;
			inputParameters.sampleFormat = PA_SAMPLE_TYPE;
			inputParameters.suggestedLatency = 0; /* ignored by Pa_IsFormatSupported() */
			inputParameters.hostApiSpecificStreamInfo = NULL;
			
			// check for full-duplex operation:
			outputParameters.device = i;
			outputParameters.channelCount = deviceInfo->maxOutputChannels;
			outputParameters.sampleFormat = PA_SAMPLE_TYPE;
			outputParameters.suggestedLatency = 0; /* ignored by Pa_IsFormatSupported() */
			outputParameters.hostApiSpecificStreamInfo = NULL;
			
			if( inputParameters.channelCount > 0 && outputParameters.channelCount > 0 )
			{
				printf("Supported standard sample rates (input, full-duplex) = ",
                inputParameters.channelCount, outputParameters.channelCount );
				PrintSupportedStandardSampleRates( &inputParameters, &outputParameters );
			}
			
			// check for half duplex operation:
			if( inputParameters.channelCount > 0 )
			{
				printf("Supported standard sample rates (input, half-duplex) = ",
                inputParameters.channelCount, 0 );
				PrintSupportedStandardSampleRates( &inputParameters, &outputParameters );
			}
			
        }


		if( i == Pa_GetDefaultOutputDevice() ) // display info for default output
        {
			defaultOutputFound = 1;
            printf( "Default output device = %s\n", deviceInfo->name );
			printf( "Max output channels = %d\n", deviceInfo->maxOutputChannels  );
			
			outputParameters.device = i;
			outputParameters.channelCount = deviceInfo->maxOutputChannels;
			outputParameters.sampleFormat = PA_SAMPLE_TYPE;
			outputParameters.suggestedLatency = 0; /* ignored by Pa_IsFormatSupported() */
			outputParameters.hostApiSpecificStreamInfo = NULL;

			// check for full-duplex operation:
			inputParameters.device = i;
			inputParameters.channelCount = deviceInfo->maxInputChannels;
			inputParameters.sampleFormat = PA_SAMPLE_TYPE;
			inputParameters.suggestedLatency = 0; /* ignored by Pa_IsFormatSupported() */
			inputParameters.hostApiSpecificStreamInfo = NULL;
			
			if( inputParameters.channelCount > 0 && outputParameters.channelCount > 0 )
			{
				printf("Supported standard sample rates (output, full-duplex) = ",
                inputParameters.channelCount, outputParameters.channelCount );
				PrintSupportedStandardSampleRates( &inputParameters, &outputParameters );
			}
			
			// check for half duplex operation:
			if( outputParameters.channelCount > 0 )
			{
				printf("Supported standard sample rates (output, half-duplex) = ",
                0, outputParameters.channelCount );
				PrintSupportedStandardSampleRates( &inputParameters, &outputParameters );
			}
			
        }
        
		   
    }
	
	if (defaultInputFound == 0)
	{	
		printf("No default audio input device found. No input device available? Default input device not set?\n");
	}
		
	if (defaultOutputFound == 0)
	{	
		printf("No default audio output device found. No output device available? Default output device not set?\n");
	}
		
    Pa_Terminate();

    return 0;

error:
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
	fprintf( stderr, "Last error from host API: %s\n", Pa_GetLastHostErrorInfo()->errorText );
    return err;
}
