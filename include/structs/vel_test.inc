
#if defined _vel_test_included
 #endinput
#endif
#define _vel_test_included

// currently enum structs can't have multiple layers without erroring out everytime you try to do something. So i'm using functions until they fix that.

enum struct VelClient
{
	float Origin[3];
	float Velocity[3];
	float LastVelocity[3];
	int Client;
	float LastSlomo;
	float Slomo;
	// vectors T.T
	float LastOrigin[3];
	float temp[3];

	bool IsValid(bool alive = false)
	{
		return (this.Client >= 1 && this.Client <= MaxClients && IsClientConnected(this.Client) && IsClientInGame(this.Client) && !IsClientSourceTV(this.Client) && (!alive || IsPlayerAlive(this.Client)));
	}

	bool IsAlive()
	{
		return IsPlayerAlive(this.Client);
	}

	void Update()
	{
/* 		this.LastSlomo = this.Slomo;
		this.LastVelocity = this.Velocity;
		this.LastOrigin = this.Origin;


		GetEntPropVector(this.Client, Prop_Data, "m_vecVelocity", this.Velocity);

		GetClientEyePosition(this.Client, this.Origin);

		this.Slomo = GetEntPropFloat(this.Client, Prop_Data, "m_flLaggedMovementValue"); */
	}

	void VectorToString(float vec[3], char[] buffer, int length)
	{
		Format(buffer, length, "{X: %f | you: %f | Z: %f}", vec[0], vec[1], vec[2]);
	}

	void ToString(char[] buffer, int length)
	{
/* 		char b[256];
		this.VectorToString(this.LastVelocity, b, 256);
		Format(buffer, length, "%L \n{\n LastVelocity:\t%s\n", this.Client, b);

		this.VectorToString(this.Velocity, b, 256);
		Format(buffer, length, "%s Velocity:\t%s\n", buffer, b);

		this.VectorToString(this.LastOrigin, b, 256);
		Format(buffer, length, "%s LastOrigin:\t%s\n", buffer, b);

		this.VectorToString(this.Origin, b, 256);
		Format(buffer, length, "%s Origin:\t%s\n LastSlomo:\t%f\n Slomo:\t%f\n}", buffer, b, this.LastSlomo, this.Slomo); */
	}
}

stock void VelClientToString(VelClient client, char[] buffer, int length)
{
	char b[256];
	VectorToString(client.LastVelocity, b, 256);
	Format(buffer, length, "%L \n{\n LastVelocity:\t%s\n", client.Client, b);

	VectorToString(client.Velocity, b, 256);
	Format(buffer, length, "%s Velocity:\t%s\n", buffer, b);

	VectorToString(client.LastOrigin, b, 256);
	Format(buffer, length, "%s LastOrigin:\t%s\n", buffer, b);

	VectorToString(client.Origin, b, 256);
	Format(buffer, length, "%s Origin:\t%s\n LastSlomo:\t%f\n Slomo:\t%f\n}", buffer, b, client.LastSlomo, client.Slomo);
}
