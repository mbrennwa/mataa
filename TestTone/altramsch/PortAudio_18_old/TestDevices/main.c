/*
 * This is the source code for TestDevices, which is based on PortAudio V18 (http://www.portaudio.com).
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
#include <math.h>
#include "portaudio.h"
/*******************************************************************/
int main(int argc, char *argv[]);
int main(int argc, char *argv[])
{

    argc -=1; /* first argument is call to TestTone itself */

    if (argc > 0) {
		printf("TestDevices usage:\n");
		printf("'TestDevices' returns a list of the available sound devices and their properties.\n\n");
		printf("TestDevices is part of MATAA. MATAA is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.\n\n");
		printf("MATAA is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.\n\n");
		printf("You should have received a copy of the GNU General Public License along with MATAA; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA\n\n");
		printf("Copyright (C) 2007 Matthias S. Brennwald.\nContact: info@audioroot.net\nFurther information: http://www.audioroot.net/MATAA.html\n");
		exit(1);
	}


    int      i,j;
    int      numDevices;
    const    PaDeviceInfo *pdi;
    PaError  err;
    Pa_Initialize();
    numDevices = Pa_CountDevices();
    if( numDevices < 0 )
    {
        printf("ERROR: Pa_CountDevices returned 0x%x\n", numDevices );
        err = numDevices;
        goto error;
    }
    printf("Number of devices = %d\n", numDevices );
    for( i=0; i<numDevices; i++ )
    {
        pdi = Pa_GetDeviceInfo( i );
        printf("---------------------------------------------- #%d", i );
        if( i == Pa_GetDefaultInputDeviceID() ) printf(" DefaultInput");
        if( i == Pa_GetDefaultOutputDeviceID() ) printf(" DefaultOutput");
        printf("\nName         = %s\n", pdi->name );
        printf("Max Inputs   = %d", pdi->maxInputChannels  );
        printf(", Max Outputs = %d\n", pdi->maxOutputChannels  );
        if( pdi->numSampleRates == -1 )
        {
            printf("Sample Rate Range = %f to %f\n", pdi->sampleRates[0], pdi->sampleRates[1] );
        }
        else
        {
            printf("Sample Rates =");
            for( j=0; j<pdi->numSampleRates; j++ )
            {
				// fixed output (no comma after last value), 31.7.2006, Matthias Brennwald
				printf(" %8.2f", pdi->sampleRates[j] );
                if (j < pdi->numSampleRates-1) printf(",", pdi->sampleRates[j] );
            }
            printf("\n");
        }
        printf("Native Sample Formats = ");
        if( pdi->nativeSampleFormats & paInt8 )        printf("paInt8, ");
        if( pdi->nativeSampleFormats & paUInt8 )       printf("paUInt8, ");
        if( pdi->nativeSampleFormats & paInt16 )       printf("paInt16, ");
        if( pdi->nativeSampleFormats & paInt32 )       printf("paInt32, ");
        if( pdi->nativeSampleFormats & paFloat32 )     printf("paFloat32, ");
        if( pdi->nativeSampleFormats & paInt24 )       printf("paInt24, ");
        if( pdi->nativeSampleFormats & paPackedInt24 ) printf("paPackedInt24, ");
        printf("\n");
    }
    Pa_Terminate();

    printf("----------------------------------------------\n");
    return 0;
error:
    Pa_Terminate();
    fprintf( stderr, "An error occured while using the portaudio stream\n" );
    fprintf( stderr, "Error number: %d\n", err );
    fprintf( stderr, "Error message: %s\n", Pa_GetErrorText( err ) );
    return err;
}
