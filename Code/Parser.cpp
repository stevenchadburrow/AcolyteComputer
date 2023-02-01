#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(const int argc, const char **argv)
{
	if (argc < 7)
	{
		printf("Parses an AS65/Dev65 .lst file into a binary .bin file\n");
		printf("Will always take the .lst file and make it however bytes long.\n");
		printf("Can add '$00' bytes before or after with arguments.\n");
		printf("Argument: <input.lst> <output.bin> <memory_location> <bytes_before> <byte_size> <bytes_after>\n");
		printf("<input.lst> is the output of: ~/dev65/bin/as65 File.asm\n");
		printf("<output.bin> is what you run in: minipro -p \"sst39sf010\" -w File.bin\n");
		printf("<memory_location> is subtracted from any location values in .lst file, typically 32768 (for $8000)\n");
		printf("<bytes_before> is how many $00 bytes are written before any code, typically 0\n");
		printf("<byte_size> is how big the actual code is expected to be (up to 262144), typically 32768\n");
		printf("<bytes_after> is how many $00 bytes are written after all code, typically 98304 for (128K ROM)\n");
		
		return 0;
	}

	FILE *input = NULL, *output = NULL;

	input = fopen(argv[1], "rt");
	if (!input)
	{
		printf("Error: Input file\n");
		return 0;
	}

	output = fopen(argv[2], "wb");
	if (!output)
	{
		printf("Error: Output file\n");
		return 0;
	}

	char buffer[4];
	char prev;

	for (int i=0; i<4; i++) buffer[i] = 0;

	int mode = 0;

	unsigned char memory[262144];
	unsigned long location = 0;
	unsigned long bank = 0;

	for (unsigned long i=0; i<262144; i++)
	{
		memory[i] = 0;
	}

	while (buffer[0] != '|') // end of file
	{
		prev = buffer[0];

		fscanf(input, "%c", &buffer[0]);

		if (buffer[0] == ':')
		{
			bank = (unsigned long)(prev - '0');

			if (mode == 0)
			{
				mode = 1;
				
				fscanf(input, "%c%c%c%c", &buffer[0], &buffer[1], &buffer[2], &buffer[3]);

				for (int i=0; i<4; i++)
				{
					if (buffer[i] >= 'A') buffer[i] = (char)(buffer[i] - 'A' + 10);
					else if (buffer[i] >= '0') buffer[i] = (char)(buffer[i] - '0');
				}

				location = buffer[0] * 4096 + buffer[1] * 256 + buffer[2] * 16 + buffer[3] - atoi(argv[3]);
			}
			else mode = 0;
		}
		else if (mode == 1)
		{
			if ((buffer[0] >= '0' && buffer[0] <= '9') || (buffer[0] >= 'A' && buffer[0] <= 'F'))
			{
				fscanf(input, "%c", &buffer[1]);

				for (int i=0; i<2; i++)
				{
					if (buffer[i] >= 'A') buffer[i] = (char)(buffer[i] - 'A' + 10);
					else if (buffer[i] >= '0') buffer[i] = (char)(buffer[i] - '0');
				}

				memory[location + 65536 * bank] = buffer[0] * 16 + buffer[1];
				location++;
			}
		}	
	}

	for (unsigned long i=0; i<atoi(argv[4]); i++)
	{
		fprintf(output, "%c", 0);
	}
	
	for (unsigned long i=0; i<atoi(argv[5]); i++)
	{
		fprintf(output, "%c", memory[i]);
	}

	for (unsigned long i=0; i<atoi(argv[6]); i++)
	{
		fprintf(output, "%c", 0);
	}
	
	fclose(input);
	fclose(output);

	return 1;
}
