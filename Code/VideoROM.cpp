#include <stdio.h>
#include <stdlib.h>

// bits are output as:

// bit7 = V-blank (active low)
// bit6 = visible (active high)
// bit5 = V-sync (active low)
// bit4 = H-sync (active low)

// bit3 = ~V-reset
// bit2 = V-reset (active low)
// bit1 = ~H-reset
// bit0 = H-reset (active low)


// Normal visible operation would use: 10110101 = 0xB5

// This should produce a 48KB .bin file, which resides from $0000 to $BFFF in memory

int main()
{
	FILE *output = NULL;

	output = fopen("VideoROM.bin","wt");
	if (!output) return 0;

	for (int i=0; i<16; i++) // should this go up here like this???
	{
		for (int j=0; j<80; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x35);
			//else 
			//	fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		for (int j=0; j<2; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x35);
			//else 
			//	fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		for (int j=0; j<12; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x25);
			//else 
			//	fprintf(output, "%c", 0xA5); // 1110 0101
		}
		
		for (int j=0; j<5; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x35);
			//else 
			//	fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		if (i < 15)
		{
			fprintf(output, "%c", 0x36); // 0011 0110
		}
		else
		{
			fprintf(output, "%c", 0x76); // 0111 0110
		}

		for (int i=0; i<28; i++)
		{
			fprintf(output, "%c", 0x00); // (doesn't matter)
		}
	}

	for (int i=0; i<240; i++)
	{
		for (int j=0; j<80; j++)
		{
			//if (j % 2 == 0) fprintf(output, "%c", 0x75);
			//else 
				fprintf(output, "%c", 0xF5); // 1011 0101
		}
		
		for (int j=0; j<2; j++)
		{
			//if (j % 2 == 0) fprintf(output, "%c", 0x35);
			//else 
				fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		for (int j=0; j<12; j++)
		{
			//if (j % 2 == 0) fprintf(output, "%c", 0x25);
			//else 
				fprintf(output, "%c", 0xA5); // 1110 0101
		}
		
		for (int j=0; j<5; j++)
		{
			//if (j % 2 == 0) fprintf(output, "%c", 0x35);
			//else 
				fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		if (i < 239)
		{
			fprintf(output, "%c", 0xF6); // 1111 0110
		}
		else
		{
			fprintf(output, "%c", 0xF6); // 1111 0110
		}

		for (int i=0; i<28; i++)
		{
			fprintf(output, "%c", 0x00); // (doesn't matter)
		}
	}
	
	for (int i=0; i<5; i++)
	{
		for (int j=0; j<80; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x35);
			//else 
			//	fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		for (int j=0; j<2; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x35);
			//else 
			//	fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		for (int j=0; j<12; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x25);
			//else 
			//	fprintf(output, "%c", 0xA5); // 1110 0101
		}
		
		for (int j=0; j<5; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x35);
			//else 
			//	fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		fprintf(output, "%c", 0x36); // 0011 0110

		for (int i=0; i<28; i++)
		{
			fprintf(output, "%c", 0x00); // (doesn't matter)
		}
	}

	for (int i=0; i<1; i++)
	{
		for (int j=0; j<80; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x15);
			//else 
			//	fprintf(output, "%c", 0x95); // 1101 0101
		}
		
		for (int j=0; j<2; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x15);
			//else 
			//	fprintf(output, "%c", 0x95); // 1101 0101
		}
		
		for (int j=0; j<12; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x05);
			//else 
			//	fprintf(output, "%c", 0x85); // 1100 0101
		}
		
		for (int j=0; j<5; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x15);
			//else 
			//	fprintf(output, "%c", 0x95); // 1101 0101
		}
		
		fprintf(output, "%c", 0x56); // 0101 0110

		for (int i=0; i<28; i++)
		{
			fprintf(output, "%c", 0x00); // (doesn't matter)
		}
	}

	for (int i=0; i<1; i++)
	{
		for (int j=0; j<80; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x35);
			//else 
			//	fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		for (int j=0; j<2; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x35);
			//else 
			//	fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		for (int j=0; j<12; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x25);
			//else 
			//	fprintf(output, "%c", 0xA5); // 1110 0101
		}
		
		for (int j=0; j<5; j++)
		{
			//if (j % 2 == 0) 
				fprintf(output, "%c", 0x35);
			//else 
			//	fprintf(output, "%c", 0xB5); // 1111 0101
		}
		
		fprintf(output, "%c", 0x3A); // 0011 1010

		for (int i=0; i<28; i++)
		{
			fprintf(output, "%c", 0x00); // (doesn't matter)
		}
	}

	for (int i=0; i<121; i++)
	{
		for (int i=0; i<128; i++)
		{
			fprintf(output, "%c", 0x00); // (doesn't matter)
		}
	}

	fclose(output);

	return 1;
}
