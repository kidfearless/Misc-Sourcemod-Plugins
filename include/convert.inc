#define MAXFLOATSIZE 40
#define MAXINTSIZE 10
stock bool Convert_IntToBool(int x)
{
	return (x == 0? false : true);
}

stock char[] Convert_IntToString(int i)
{
	char output[MAXINTSIZE];

	FormatEx(output, MAXINTSIZE, "%i", i);

	return output;
}

stock char[] Convert_BoolToString(bool b)
{
	char output[5];
	if(b)
	{
		output = "True";
	}
	else
	{
		output = "False";
	}

	return output;
}


stock char[] Convert_FloatToString(float f)
{
	char output[MAXFLOATSIZE];

	Format(output, MAXFLOATSIZE, "%f", f);

	return output;
}

