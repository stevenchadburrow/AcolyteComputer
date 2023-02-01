#include <stdio.h>
#include <stdlib.h>

int main(const int argc, const char **argv)
{
	if (argc < 6)
	{
		printf("Combines a 48K .bin video file and two 64K .bin code files (only bottom 16K populated) into a single 128K .bin file and into a 512K .bin file (only first 128K populated)\n");
		printf("Arguments: <input1.bin> <input2.bin> <input3.bin> <output1.bin> <output2.bin>\n");
	
		return 0;
	}

	FILE *input[3], *output;

	unsigned char buffer;

// first is the completely filled 128K .bin file

	input[0] = NULL;
	input[1] = NULL;
	input[2] = NULL;

	for (int i=0; i<3; i++)
	{
		input[i] = fopen(argv[i+1], "rb");
		if (!input[i])
		{
			printf("Input Error\n");
		
			return 0;
		}
	}

	output = NULL;

	output = fopen(argv[4], "wb");
	if (!output)
	{
		printf("Output Error\n");

		return 0;
	}

	for (unsigned int i=0; i<49152; i++)
	{
		fscanf(input[0], "%c", &buffer);
		fprintf(output, "%c", buffer);
		fscanf(input[1], "%c", &buffer);
		//fprintf(output, "%c", buffer);
	}

	for (unsigned int i=49152; i<65536; i++)
	{
		fscanf(input[1], "%c", &buffer);
		fprintf(output, "%c", buffer);
	}

	for (int i=0; i<3; i++)
	{
		fclose(input[i]);
	}

	input[0] = NULL;
	input[1] = NULL;
	input[2] = NULL;

	for (int i=0; i<3; i++)
	{
		input[i] = fopen(argv[i+1], "rb");
		if (!input[i])
		{
			printf("Input Error\n");
		
			return 0;
		}
	}
	
	for (unsigned int i=0; i<49152; i++)
	{
		fscanf(input[0], "%c", &buffer);
		fprintf(output, "%c", buffer);
		fscanf(input[2], "%c", &buffer);
		//fprintf(output, "%c", buffer);
	}

	for (unsigned int i=49152; i<65536; i++)
	{
		fscanf(input[2], "%c", &buffer);
		fprintf(output, "%c", buffer);
	}

	for (int i=0; i<3; i++)
	{
		fclose(input[i]);
	}

	fclose(output);


// now for mostly blank 512K .bin file

	input[0] = NULL;
	input[1] = NULL;
	input[2] = NULL;

	for (int i=0; i<3; i++)
	{
		input[i] = fopen(argv[i+1], "rb");
		if (!input[i])
		{
			printf("Input Error\n");
		
			return 0;
		}
	}

	output = NULL;

	output = fopen(argv[5], "wb");
	if (!output)
	{
		printf("Output Error\n");

		return 0;
	}

	for (unsigned int i=0; i<49152; i++)
	{
		fscanf(input[0], "%c", &buffer);
		fprintf(output, "%c", buffer);
		fscanf(input[1], "%c", &buffer);
		//fprintf(output, "%c", buffer);
	}

	for (unsigned int i=49152; i<65536; i++)
	{
		fscanf(input[1], "%c", &buffer);
		fprintf(output, "%c", buffer);
	}

	for (int i=0; i<3; i++)
	{
		fclose(input[i]);
	}

	input[0] = NULL;
	input[1] = NULL;
	input[2] = NULL;

	for (int i=0; i<3; i++)
	{
		input[i] = fopen(argv[i+1], "rb");
		if (!input[i])
		{
			printf("Input Error\n");
		
			return 0;
		}
	}
	
	for (unsigned int i=0; i<49152; i++)
	{
		fscanf(input[0], "%c", &buffer);
		fprintf(output, "%c", buffer);
		fscanf(input[2], "%c", &buffer);
		//fprintf(output, "%c", buffer);
	}

	for (unsigned int i=49152; i<65536; i++)
	{
		fscanf(input[2], "%c", &buffer);
		fprintf(output, "%c", buffer);
	}

	for (int i=0; i<3; i++)
	{
		fclose(input[i]);
	}

	for (unsigned int i=0; i<65536; i++)
	{
		fprintf(output, "%c", 0);
	}

	for (unsigned int i=0; i<65536; i++)
	{
		fprintf(output, "%c", 0);
	}

	for (unsigned int i=0; i<65536; i++)
	{
		fprintf(output, "%c", 0);
	}

	for (unsigned int i=0; i<65536; i++)
	{
		fprintf(output, "%c", 0);
	}

	for (unsigned int i=0; i<65536; i++)
	{
		fprintf(output, "%c", 0);
	}

	for (unsigned int i=0; i<65536; i++)
	{
		fprintf(output, "%c", 0);
	}


	fclose(output);

	return 1;
}
