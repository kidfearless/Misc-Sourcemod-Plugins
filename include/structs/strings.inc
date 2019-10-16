
#if defined _strings_included
 #endinput
#endif
#define _strings_included

enum struct String_t
{
	#define String_t.Size 1024

	char StringValue[String_t.Size];

	int Length()
	{
		return strlen(this.StringValue);
	}

	int Size()
	{
		return String_t.Size;
	}

	bool IsNullOrEmpty()
	{
		if(IsNullString(this.StringValue))
		{
			return true;
		}
		if(this.StringValue[0] == 0)
		{
			return true;
		}
		return this.Equals(NULL_STRING);
	}

	bool BoolValue()
	{
		return !!this.IntValue();
	}

	int Break(char[] arg, int argLen)
	{
		return BreakString(this.StringValue, arg, argLen);
	}

	int Compare(const char[] str2, int num, bool caseSensitive = true)
	{
		return strncmp(this.StringValue, str2, num, caseSensitive);
	}

	int ConCat(const char[] appender)
	{
		int len = this.Length();
		return Format(this.StringValue[len], String_t.Size - len, "%s", appender);
	}

	int Contains(const char[] substr, bool caseSensitive = true)
	{
		return StrContains(this.StringValue, substr, caseSensitive);
	}

	int Copy(const char[] source)
	{
		return strcopy(this.StringValue, String_t.Size, source);
	}

	bool Equals(const char[] str2, bool caseSensitive = true)
	{
		return (strcmp(this.StringValue, str2, caseSensitive) == 0);
	}

	float FloatValue()
	{
		return StringToFloat(this.StringValue);
	}

	int FloatValueEx(float &result)
	{
		return StringToFloatEx(this.StringValue, result);
	}

	int Format(const char[] format, any ...)
	{
		return VFormat(this.StringValue, String_t.Size, format, 3);
	}

	int GetBytes()
	{
		return GetCharBytes(this.StringValue);
	}

	int IntValue(int nBase = 10)
	{
		return StringToInt(this.StringValue, nBase);
	}

	int IntValueEx(int &result, int nBase = 10)
	{
		return StringToIntEx(this.StringValue, result, nBase);
	}

	int Insert(const char[] appender)
	{
		return Format("%s%s", String_t.Size, appender, this.StringValue);
	}

	int FindChar(const char c, bool reverse = false)
	{
		int len = this.Length();
		
		if (!reverse)
		{
			for (int i = 0; i < len; ++i)
			{
				if (this.StringValue[i] == c)
				{
					return i;
				}
			}
		} 
		else
		{
			for (int i = len - 1; i >= 0; --i)
			{
				if (this.StringValue[i] == c)
				{
					return i;
				}
			}
		}

		return -1;
	}

	int Replace(const char[] search, const char[] replace, bool caseSensitive = true)
	{
		return ReplaceString(this.StringValue, String_t.Size, search, replace, caseSensitive);
	}

	int ReplaceEx(const char[] search, const char[] replace, int searchLen = -1, int replaceLen = -1, bool caseSensitive = true)
	{
		return ReplaceStringEx(this.StringValue, String_t.Size, search, replace, searchLen, replaceLen, caseSensitive);
	}

	int Split(const char[] split, char[] part, int partLen)
	{
		return SplitString(this.StringValue, split, part, partLen);
	}

	bool Strip()
	{
		return StripQuotes(this.StringValue);
	}

	void ToUpper()
	{
		for(int i = 0; i < this.Length(); ++i)
		{
			this.StringValue[i] = CharToUpper(this.StringValue);
		}
	}

	void ToLower()
	{
		for(int i = 0; i < this.Length(); ++i)
		{
			this.StringValue[i] = CharToLower(this.StringValue);
		}
	}
	
	int Trim()
	{
		return TrimString(this.StringValue);
	}
}