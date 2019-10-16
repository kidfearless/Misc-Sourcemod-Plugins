// https://github.com/toji/gl-matrix/blob/master/src/vec3.js
#include<sourcemod>

methodmap Vec3
{
	/**
	 * Creates a new vec3 initialized with values from an existing vector
	 *
	 * @param {vec3} vector to be cloned into
	 * @param {vec3} vector to be cloned from
	 */
	public static void Clone(float out[3], const float input[3])
	{
		out = input;
	}
	/**
	 * Calculates the length of a vec3
	 *
	 * @param {vec3} a vector to calculate length of
	 * @returns {float} length of a
	 */
	public static float Length(const float input[3], bool squared = false)
	{
		return GetVectorLength(input, false);
	}
	/**
	 * Creates a new vec3 initialized with the given values
	 *
	 * @param {float} x X component
	 * @param {float} y Y component
	 * @param {float} z Z component
	 * @returns {vec3} a new 3D vector
	 */
	public static void FromValues(float out[3], const float x, const float y, const float z)
	{
		out[0] = x;
		out[1] = y;
		out[2] = z;
	}
	/**
	 * Adds two vec3's
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 */
	public static void Add(float out[3], const float a[3], const float b[3])
	{
		out[0] = a[0] + b[0];
		out[1] = a[1] + b[1];
		out[2] = a[2] + b[2];
	}
	/**
	 * Subtracts vector b from vector a
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 */
	public static void Sub(float out[3], const float a[3], const float b[3])
	{
		out[0] = a[0] - b[0];
		out[1] = a[1] - b[1];
		out[2] = a[2] - b[2];
	}
	/**
	 * Multiplies two vec3's
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 */
	public static void Multiply(float out[3], const float a[3], const float b[3])
	{
		out[0] = a[0] * b[0];
		out[1] = a[1] * b[1];
		out[2] = a[2] * b[2];
	}
	/**
	 * Divides two vec3's
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 */
	public static void Divide(float out[3], const float a[3], const float b[3])
	{
		out[0] = a[0] / b[0];
		out[1] = a[1] / b[1];
		out[2] = a[2] / b[2];
	}
	/**
	 * Math.ceil the components of a vec3
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a vector to ceil
	 */
	public static void Ceil(float out[3], const float a[3])
	{
		out[0] = float(RoundToCeil(a[0]));
		out[1] = float(RoundToCeil(a[1]));
		out[2] = float(RoundToCeil(a[2]));
	}
	/**
	 * Math.floor the components of a vec3
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a vector to floor
	 */
	public static void Floor(float out[3], const float a[3])
	{
		out[0] = float(RoundToFloor(a[0]));
		out[1] = float(RoundToFloor(a[1]));
		out[2] = float(RoundToFloor(a[2]));
	}
	/**
	 * Math.round the components of a vec3
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a vector to round
	 */
	public static void Round(float out[3], const float a[3])
	{
		out[0] = float(RoundFloat(a[0]));
		out[1] = float(RoundFloat(a[1]));
		out[2] = float(RoundFloat(a[2]));
	}
	/**
	 * Scales a vec3 by a scalar number
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the vector to scale
	 * @param {float} b amount to scale the vector by
	 */
	public static void Scale(float out[3], const float a[3], const float b)
	{
		out[0] = a[0] * b;
		out[1] = a[1] * b;
		out[2] = a[2] * b;
	}
	/**
	 * Adds two vec3's after scaling the second operand by a scalar value
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 * @param {float} scale the amount to scale b by before adding
	 */
	public static void ScaleAndAdd(float out[3], const float a[3], const float b[3], const float scale)
	{
		out[0] = a[0] + (b[0] * scale);
  		out[1] = a[1] + (b[1] * scale);
  		out[2] = a[2] + (b[2] * scale);
	}
	/**
	 * Calculates the euclidian distance between two vec3's
	 *
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 * @returns {float} distance between a and b
	 */
	public static float Distance(const float a[3], const float b[3])
	{
		float temp[3];
		temp[0] = b[0] - a[0];
		temp[1] = b[1] - a[1];
		temp[2] = b[2] - a[2];
		return GetVectorLength(temp);
	}
	/**
	 * Calculates the squared euclidian distance between two vec3's
	 *
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 * @returns {float} squared distance between a and b
	 */
	public static float SquaredDistance(const float a[3], const float b[3])
	{
		float x = b[0] - a[0];
		float y = b[1] - a[1];
		float z = b[2] - a[2];
		return x*x + y*y + z*z;
	}
	/**
	 * Calculates the squared length of a vec3
	 *
	 * @param {vec3} a vector to calculate squared length of
	 * @returns {float} squared length of a
	 */
	public static float SquaredLength(const float a[3])
	{
		float x = a[0];
		float y = a[1];
		float z = a[2];
		return x*x + y*y + z*z;
	}
	/**
	 * Negates the components of a vec3
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a vector to negate
	 */
	public static void Negate(float out[3], const float a[3])
	{
		out[0] = -a[0];
		out[1] = -a[1];
		out[2] = -a[2];
	}
	/**
	 * Returns the inverse of the components of a vec3
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a vector to invert
	 */
	public static void Inverse(float out[3], const float a[3])
	{
		out[0] = 1.0 / a[0];
		out[1] = 1.0 / a[1];
		out[2] = 1.0 / a[2];
	}
	/**
	 * Normalize a vec3
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a vector to normalize
	 */
	public static void Normalize(float out[3], const float a[3])
	{
		float x = a[0];
		float y = a[1];
		float z = a[2];
		float len = x*x + y*y + z*z;

		if (len > 0.0)
		{
			len = 1.0 / SquareRoot(len);
		}

		out[0] = a[0] * len;
		out[1] = a[1] * len;
		out[2] = a[2] * len;
	}
	/**
	 * Calculates the dot product of two vec3's
	 *
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 * @returns {float} dot product of a and b
	 */
	public static float Dot(const float a[3], const float b[3])
	{
		return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
	}
	/**
	 * Computes the cross product of two vec3's
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 */
	public static void Cross(float out[3], const float a[3], const float b[3])
	{
		float ax = a[0], ay = a[1], az = a[2];
		float bx = b[0], by = b[1], bz = b[2];

		out[0] = ay * bz - az * by;
		out[1] = az * bx - ax * bz;
		out[2] = ax * by - ay * bx;
	}
	/**
	 * Performs a linear interpolation between two vec3's
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 * @param {float} t interpolation amount, in the range [0-1], between the two inputs
	 */
	public static void Lerp(float out[3], const float a[3], const float b[3], const float t)
	{
		float ax = a[0];
		float ay = a[1];
		float az = a[2];
		out[0] = ax + t * (b[0] - ax);
		out[1] = ay + t * (b[1] - ay);
		out[2] = az + t * (b[2] - az);
	}
	/**
	 * Performs a hermite interpolation with two control points
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 * @param {vec3} c the third operand
	 * @param {vec3} d the fourth operand
	 * @param {float} t interpolation amount, in the range [0-1], between the two inputs
	 */
	public static void Hermite(float out[3], const float a[3], const float b[3], const float c[3], const float d[3], const float t)
	{
		float factorTimes2 = t * t;
		float factor1 = factorTimes2 * (2.0 * t - 3.0) + 1.0;
		float factor2 = factorTimes2 * (t - 2.0) + t;
		float factor3 = factorTimes2 * (t - 1.0);
		float factor4 = factorTimes2 * (3.0 - 2.0 * t);

		out[0] = a[0] * factor1 + b[0] * factor2 + c[0] * factor3 + d[0] * factor4;
		out[1] = a[1] * factor1 + b[1] * factor2 + c[1] * factor3 + d[1] * factor4;
		out[2] = a[2] * factor1 + b[2] * factor2 + c[2] * factor3 + d[2] * factor4;
	}
	/**
	 * Performs a bezier interpolation with two control points
	 *
	 * @param {vec3} out the receiving vector
	 * @param {vec3} a the first operand
	 * @param {vec3} b the second operand
	 * @param {vec3} c the third operand
	 * @param {vec3} d the fourth operand
	 * @param {float} t interpolation amount, in the range [0-1], between the two inputs
	 */
	public static void Bezier(float out[3], const float a[3], const float b[3], const float c[3], const float d[3], const float t)
	{
		float inverseFactor = 1.0 - t;
		float inverseFactorTimesTwo = inverseFactor * inverseFactor;
		float factorTimes2 = t * t;
		float factor1 = inverseFactorTimesTwo * inverseFactor;
		float factor2 = 3.0 * t * inverseFactorTimesTwo;
		float factor3 = 3.0 * factorTimes2 * inverseFactor;
		float factor4 = factorTimes2 * t;

		out[0] = a[0] * factor1 + b[0] * factor2 + c[0] * factor3 + d[0] * factor4;
		out[1] = a[1] * factor1 + b[1] * factor2 + c[1] * factor3 + d[1] * factor4;
		out[2] = a[2] * factor1 + b[2] * factor2 + c[2] * factor3 + d[2] * factor4;
	}
	/**
	 * Rotate a 3D vector around the x-axis
	 * @param {vec3} out The receiving vec3
	 * @param {vec3} a The vec3 point to rotate
	 * @param {vec3} b The origin of the rotation
	 * @param {float} c The angle of rotation
	 */
	public static void RotateX(float out[3], const float a[3], const float b[3], const float c)
	{
		float p[3], r[3];
		//Translate point to the origin
		p[0] = a[0] - b[0];
		p[1] = a[1] - b[1];
		p[2] = a[2] - b[2];

		//perform rotation
		r[0] = p[0];
		r[1] = p[1] * Cosine(c) - p[2] * Sine(c);
		r[2] = p[1] * Cosine(c) + p[2] * Cosine(c);

		//translate to correct position
		out[0] = r[0] + b[0];
		out[1] = r[1] + b[1];
		out[2] = r[2] + b[2];
	}
	/**
	 * Rotate a 3D vector around the y-axis
	 * @param {vec3} out The receiving vec3
	 * @param {vec3} a The vec3 point to rotate
	 * @param {vec3} b The origin of the rotation
	 * @param {float} c The angle of rotation
	 */
	public static void RotateY(float out[3], const float a[3], const float b[3], const float c)
	{
		float p[3], r[3];
		//Translate point to the origin
		p[0] = a[0] - b[0];
		p[1] = a[1] - b[1];
		p[2] = a[2] - b[2];

		//perform rotation
		r[0] = p[2] * Sine(c) + p[0] * Cosine(c);
		r[1] = p[1];
		r[2] = p[2] * Cosine(c) - p[0] * Sine(c);

		//translate to correct position
		out[0] = r[0] + b[0];
		out[1] = r[1] + b[1];
		out[2] = r[2] + b[2];
	}
	/**
	 * Rotate a 3D vector around the z-axis
	 * @param {vec3} out The receiving vec3
	 * @param {vec3} a The vec3 point to rotate
	 * @param {vec3} b The origin of the rotation
	 * @param {float} c The angle of rotation
	 */
	public static void RotateZ(float out[3], const float a[3], const float b[3], const float c)
	{
		float p[3], r[3];
		//Translate point to the origin
		p[0] = a[0] - b[0];
		p[1] = a[1] - b[1];
		p[2] = a[2] - b[2];

		//perform rotation
		r[0] = p[0]*Cosine(c) - p[1]*Sine(c);
		r[1] = p[0]*Sine(c) + p[1]*Cosine(c);
		r[2] = p[2];

		//translate to correct position
		out[0] = r[0] + b[0];
		out[1] = r[1] + b[1];
		out[2] = r[2] + b[2];
	}
	/**
	 * Get the angle between two 3D vectors
	 * @param {vec3} a The first operand
	 * @param {vec3} b The second operand
	 * @returns {float} The angle in radians
	 */
	public static float Angle(const float a[3], const float b[3])
	{
		float tempA[3];
		tempA = a;
		float tempB[3];
		tempB = b;

		Vec3.Normalize(tempA, tempA);
		Vec3.Normalize(tempB, tempB);

		float cosine = Vec3.Dot(tempA, tempB);

		if(cosine > 1.0)
		{
			return 0.0;
		}
		else if(cosine < -1.0)
		{
			return FLOAT_PI;
		}
		else
		{
			return ArcCosine(cosine);
		}
	}
	/**
	 * Returns whether or not the vectors have exactly the same elements in the same position
	 *
	 * @param {vec3} a The first vector.
	 * @param {vec3} b The second vector.
	 * @returns {Boolean} True if the vectors are equal, false otherwise.
	 */
	public static bool Equals(const float a[3], const float b[3])
	{
		return a[0] == b[0] && a[1] == b[1] && a[2] == b[2];
	}
	/**
	 * Returns a string representation of a vector
	 *
	 * @param {vec3} a vector to represent as a string
	 * @param {String} buffer to store the string representation
	 * @param {int} max length of the buffer
	 */
	public static void ToString(const float a[3], char[] buffer, int length)
	{
		FormatEx(buffer, length, "vec3( %f, %f, %f)", a[0], a[1], a[2]);
	}
}