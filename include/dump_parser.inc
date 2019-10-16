#if defined _output_dump_parser_defined_
#endinput
#endif
#define _output_dump_parser_defined_

#define OUTPUT_SIZE 2048

#define DEBUG

#if defined DEBUG
	#define LOG(%1) LogMessage(%1)
#else
	#define LOG(%1) //(%1)
#endif

// Used to keep temporary files for debugging
// #define NO_DEL

enum
{
	OUTPUTTYPE,
	TARGETENTITY,
	OUTPUTNAME,
	PARAMETERS,
	DELAY,
	ONCE,
	OUTPUTSIZE
};

enum struct Output
{
	char Output[32];// OnStartTouch
	char Target[32];// !Activator 
	char Input[32];// Addoutput
	char Parameters[32];// gravity 0.1
	float Delay;// 0.1
	bool Once;// 0

	void Dump()
	{
		PrintToServer("output: %s\ntarget: %s\ninput: %s\nParameters: %s\ndelay: %f\nonce: %i", this.Output, this.Target, this.Input, this.Parameters, this.Delay, this.Once);
	}
	
	void ToString(char[] input, int length = OUTPUT_SIZE)
	{
		Format(input, length, "%s;%s;%s;%s;%f;%i", this.Output, this.Target, this.Input, this.Parameters, this.Delay, this.Once);
	}

	void Parse(char[] buffer)
	{
		// Break it up into more managable parts
		char entity[OUTPUTSIZE][64];
		ExplodeString(buffer, ";", entity, OUTPUTSIZE, 64);

		strcopy(this.Output, 32, entity[OUTPUTTYPE]);
		strcopy(this.Target, 32, entity[TARGETENTITY]);
		strcopy(this.Input, 32, entity[OUTPUTNAME]);
		strcopy(this.Parameters, 32, entity[PARAMETERS]);
		this.Delay = StringToFloat(entity[DELAY]);
		this.Once = (StringToInt(entity[ONCE]) > 0);
	}
}

enum struct Entity
{
	char HammerID[32];
	float Wait;
	char Classname[32];
	ArrayList OutputList;

	void Dump()
	{
		char b[OUTPUT_SIZE];
		for(int i = 0; i < this.OutputList.Length; ++i)
		{
			Output temp;
			this.OutputList.GetArray(i, temp);
			char buffer[OUTPUT_SIZE];
			temp.ToString(buffer);
			Format(b, OUTPUT_SIZE, "\t\t%s\n\t\t%s", b, buffer);
		}
		PrintToServer("\n\"%s\"\n{\n\t\"wait\" \"%f\"\n\t\"classname\" \"%s\"\n\t\"outputs\"\n\t{\n\t%s\n\t}\n}\n", this.HammerID, this.Wait, this.Classname, b);
	}

	void ToString(char[] input, int length = OUTPUT_SIZE)
	{
		char outputs[OUTPUT_SIZE];
		for(int i = 0; i < this.OutputList.Length; ++i)
		{
			Output temp;
			this.OutputList.GetArray(i, temp);
			char buffer[OUTPUT_SIZE];
			temp.ToString(buffer);
			Format(outputs, OUTPUT_SIZE, "%s|%s", outputs, buffer);
		}
		Format(input, length, "%s;%f;%s;{%s}", this.HammerID, this.Wait, this.Classname, outputs);
	}

	void CleanUp()
	{
		delete this.OutputList;
	}
}

/* *
*	Stock function to copy all the data from one 'Output' to another
*	Since there's no handles nothing will need to be freed.
*	
*	return: noreturn
* */
stock void CloneOutput(const Output input, Output out)
{
	strcopy(out.Output, 32, input.Output);
	strcopy(out.Target, 32, input.Target);
	strcopy(out.Input, 32, input.Input);
	strcopy(out.Parameters, 32, input.Parameters);
	out.Delay = input.Delay;
	out.Once = input.Once;
}

/* *
*	Stock function to copy all the data from one 'Entity' to another
*	Output ArrayLists are copies as well and need to be freed.
*	
*	return: noreturn
* */
stock void CloneEntity(const Entity input, Entity out)
{
	strcopy(out.HammerID, 32, input.HammerID);
	out.Wait = input.Wait;
	strcopy(out.Classname, 32, input.Classname);
	out.OutputList = input.OutputList.Clone();
}

/* *
*	Fired when either JSON Dump file is found or is fully parsed.
*	
*	return: noreturn
* */
forward void OnDumpFileReady();

/* *
*	Fired when everything is processed and it's safe to call natives.
*	
*	return: noreturn
* */
forward void OnDumpFileProcessed();

/* *
*	Retrieves a copy of the 'Entity' enum struct for the given index and places it inside an ArrayList.
*	The ArrayList will not be cleared automatically.
*	Use the GetDumpEntity stock instead.
*	
*	Param: index		Entity index.
*	
*	return: ArrayList containing the Entity enum struct if found, INVALID_HANDLE otherwise.
* */
native ArrayList GetDumpEntityAsList(int index);

/* *
*	Retrieves a copy of the 'Entity' enum struct for the given index.
*	
*	Param: index		Entity index.
*	Param: ent			Entity enum struct if found.
*	
*	return: true if successful, false otherwise.
* */
stock bool GetDumpEntity(int index, Entity ent)
{
	ArrayList temp = GetDumpEntityAsList(index);
	if(temp != INVALID_HANDLE)
	{
		temp.GetArray(0, ent);
		delete temp;
		return true;
	}
	delete temp;
	return false;
}

/* *
*	Retrieves a copy of the 'Entity' enum struct from the given hammer id and places it inside an ArrayList.
*	The ArrayList will not be cleared automatically.
*	Use the GetDumpEntity2 stock instead.
*	
*	Param: hammerid		Hammer id of the entity.
*	
*	return: ArrayList containing the Entity enum struct if found, INVALID_HANDLE otherwise.
* */
native ArrayList GetDumpEntityFromID(int hammerid);

/* *
*	Retrieves a copy of the 'Entity' enum struct for the given hammer id.
*	
*	Param: hammerid		Hammer id of the entity.
*	Param: ent			Entity enum struct if found.
*	
*	return: true if successful, false otherwise.
* */
stock bool GetDumpEntity2(int hammerid, Entity ent)
{
	ArrayList temp = GetDumpEntityFromID(hammerid);
	if(temp != INVALID_HANDLE)
	{
		temp.GetArray(0, ent);
		delete temp;
		return true;
	}
	delete temp;
	return false
}

/* *
*	Retrieves a copy of all the entities inside an ArrayList
*	The ArrayList will not be cleared automatically.
*	
*	
*	return: ArrayList full of 'Entities' if successful, INVALID_HANDLE otherwise.
* */
native ArrayList GetDumpEntities();

/* *
*	Retrieves a copy of the StringMap that holds the indexes of the entities.
*	Hammer ids are the keys and the cells are the index in the entity dump
*	The StringMap will not be cleared automatically.
*	
*	
*	return: StringMap full of keys if successful, INVALID_HANDLE otherwise.
* */
native StringMap GetDumpStringMap();

/* *
*	Returns whether or not it's safe to call any natives
*	
*	return: gB_Ready.
* */
native bool IsDumpReady();

///////////////////////////////////////////////////////////
// OutputInfo stocks used for use in plugins that use it //
//			I do not recommend using these				 //
///////////////////////////////////////////////////////////

/* *
*	Retrieves the number of outputs that have the given trigger
*	
*	Param: index		Ent index of the entity.
*	Param: output		Output that you want to count. ("OnStartTouch" or empty for all)
*	
*	return: Output count
* */
stock int GetOutputCount(int index, const char[] output = "")
{
	Entity ent;
	GetDumpEntity(index, ent);

	int count = 0;
	if(output[0] == 0)
	{
		count = ent.OutputList.Length;
	}
	else
	{
		for(int i = 0; i < ent.OutputList.Length; ++i)
		{
			Output out;
			ent.OutputList.GetArray(i, out);
			if(StrEqual(output, out.Output, false))
			{
				++count;
			}
		}
	}
	ent.Cleanup();
	return count;
}

/* *
*	Retrieves the target at the current index for the given output.
*	Not recommended as outputs aren't organized and aren't guarenteed to be the same between sessions and servers.
*	
*	Param: index		Ent index of the entity.
*	Param: output		Output that you want to count. ("OnStartTouch" or empty for all)
*	Param: num			Index/occurance of that given output to return
*	Param: target		Buffer to store the outputs target
*	Param: length		Size of the buffer, default is the max size of the enum structs members
*	
*	return: True if operation was successful, false otherwise.
* */
stock bool GetOutputTarget(int index, const char[] output, int num, char[] target, int length = 32)
{
	Entity ent;
	GetDumpEntity(index, ent);

	int count = 0;
	bool ret = false;
	char buffer[32];
	if(StrContains(output, "m_") == 0)
	{
		strcopy(buffer, 32, output[2]);
	}
	else
	{
		strcopy(buffer, 32, output);
	}

	for(int i = 0; i < ent.OutputList.Length; ++i)
	{
		Output out;
		ent.OutputList.GetArray(i, out);
		if(StrEqual(buffer, out.Output, false))
		{
			if(count++ == num)
			{
				strcopy(target, length, out.Target);
				ret = true
				break;
			}
		}
	}

	ent.Cleanup();
	return ret;
}

stock bool GetOutputTargetInput(int index, const char[] output, int num, char[] input, int length = 32)
{
	Entity ent;
	GetDumpEntity(index, ent);
	int count = 0;
	bool ret = false;
	char buffer[32];
	if(StrContains(output, "m_") == 0)
	{
		strcopy(buffer, 32, output[2]);
	}
	else
	{
		strcopy(buffer, 32, output);
	}

	for(int i = 0; i < ent.OutputList.Length; ++i)
	{
		Output out;
		ent.OutputList.GetArray(i, out);
		if(StrEqual(buffer, out.Output, false))
		{
			if(count++ == num)
			{
				strcopy(input, length, out.Input);
				ret = true
				break;
			}
		}
	}

	ent.Cleanup();
	return ret;
}

stock bool GetOutputParameter(int index, const char[] output, int num, char[] parameters, int length = 32)
{
	Entity ent;
	GetDumpEntity(index, ent);
	int count = 0;
	bool ret = false;
	char buffer[32];
	if(StrContains(output, "m_") == 0)
	{
		strcopy(buffer, 32, output[2]);
	}
	else
	{
		strcopy(buffer, 32, output);
	}

	for(int i = 0; i < ent.OutputList.Length; ++i)
	{
		Output out;
		ent.OutputList.GetArray(i, out);
		if(StrEqual(buffer, out.Output, false))
		{
			if(count++ == num)
			{
				strcopy(parameters, length, out.Parameters);
				ret = true
				break;
			}
		}
	}

	ent.Cleanup();
	return ret;
}

stock float GetOutputDelay(int index, const char[] output, int num)
{
	Entity ent;
	GetDumpEntity(index, ent);
	float delay = 0.0;
	int count = 0;
	char buffer[32];
	if(StrContains(output, "m_") == 0)
	{
		strcopy(buffer, 32, output[2]);
	}
	else
	{
		strcopy(buffer, 32, output);
	}

	for(int i = 0; i < ent.OutputList.Length; ++i)
	{
		Output out;
		ent.OutputList.GetArray(i, out);
		if(StrEqual(buffer, out.Output, false))
		{
			if(count++ == num)
			{
				delay = out.Delay;
				break;
			}
		}
	}

	ent.Cleanup();
	return delay;
}

public SharedPlugin __pl_output_dump_parser =
{
	name = "output_dump_parser",
	file = "dump_parser.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_output_dump_parser_SetNTVOptional()
{
	MarkNativeAsOptional("IsDumpReady");
	MarkNativeAsOptional("GetDumpEntityAsList");
	MarkNativeAsOptional("GetDumpEntities");
	MarkNativeAsOptional("GetDumpStringMap");
}
#endif

///////////////////////////////////////////
// Generic stocks used inside the plugin //
///////////////////////////////////////////

stock bool StringContains(const char[] str, const char[] sub, bool caseSense = false)
{
	return (StrContains(str, sub, caseSense) != -1);
}

stock bool GetKVString(KeyValues kv, char[] input, char[] output, int length)
{
	kv.GetString(input, output, length);

	return (kv.GetDataType(input) != KvData_None);
}

stock int GetHammerFromIndex(int index)
{
	if(!IsValidEntity(index))
	{
		return 0;
	}

	return GetEntProp(index, Prop_Data, "m_iHammerID");
}