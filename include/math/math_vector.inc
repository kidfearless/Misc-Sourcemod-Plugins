// <copyright file="Trigonometry.cs" company="Math_NET">
// Math_NET Numerics, part of the Math_NET Project
// http://numerics.mathdotnet.com
// http://github.com/mathnet/mathnet-numerics
//
// Copyright (c) 2009-2013 Math_NET
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
// </copyright>

#include <math_constants>


/// <summary>
/// Converts a degree (360-periodic) angle to a grad (400-periodic) angle.
/// </summary>
/// <param name="degree">The degree to convert.</param>
/// <returns>The converted grad angle.</returns>
stock float Math_DegreeToGrad(float degree)
{
	return degree * DegreeToGradConstant;
}

/// <summary>
/// Converts a grad (400-periodic) angle to a degree (360-periodic) angle.
/// </summary>
/// <param name="grad">The grad to convert.</param>
/// <returns>The converted degree.</returns>
stock float Math_GradToDegree(float grad)
{
	return grad * 0.9;
}

/// <summary>
/// Converts a grad (400-periodic) angle to a radian (2*Pi-periodic) angle.
/// </summary>
/// <param name="grad">The grad to convert.</param>
/// <returns>The converted radian.</returns>
stock float Math_GradToRadian(float grad)
{
	return grad * Constants_Grad;
}

/// <summary>
/// Converts a radian (2*Pi-periodic) angle to a grad (400-periodic) angle.
/// </summary>
/// <param name="radian">The radian to convert.</param>
/// <returns>The converted grad.</returns>
stock float Math_RadianToGrad(float radian)
{
	return radian / Constants_Grad;
}


/// <summary>
/// Normalized Sinc function. sinc(x) = sin(pi*x)/(pi*x).
/// </summary>
stock float Math_Sinc(float x)
{
	float z = PI*x;
	return Sine(z)/z;
}

/// <summary>
/// Trigonometric Cotangent of an angle in radian, or adjacent / opposite. Reciprocal of the tangent.
/// </summary>
/// <param name="radian">The angle in radian.</param>
/// <returns>The cotangent of an angle in radian.</returns>
stock float Math_Cot(float radian)
{
	return 1 / Tangent(radian);
}

/// <summary>
/// Trigonometric Secant of an angle in radian, or hypotenuse / adjacent. Reciprocal of the cosine.
/// </summary>
/// <param name="radian">The angle in radian.</param>
/// <returns>The secant of the radian angle.</returns>
stock float Math_Sec(float radian)
{
	return 1 / Cosine(radian);
}

/// <summary>
/// Trigonometric Cosecant of an angle in radian, or hypotenuse / opposite. Reciprocal of the sine.
/// </summary>
/// <param name="radian">The angle in radian.</param>
/// <returns>Cosecant of an angle in radian.</returns>
stock float Math_Csc(float radian)
{
	return 1 / Sine(radian);
}

/// <summary>
/// Trigonometric principal Arc Cotangent in radian
/// </summary>
/// <param name="adjacent">The adjacent for a unit opposite (i.e. adjacent / opposite).</param>
/// <returns>The angle in radian.</returns>
stock float Math_Acot(float adjacent)
{
	return ArcTangent(1 / adjacent);
}

/// <summary>
/// Trigonometric principal Arc Secant in radian
/// </summary>
/// <param name="hypotenuse">The hypotenuse for a unit adjacent (i.e. hypotenuse / adjacent).</param>
/// <returns>The angle in radian.</returns>
stock float Math_Asec(float hypotenuse)
{
	return ArcCosine(1 / hypotenuse);
}

/// <summary>
/// Trigonometric principal Arc Cosecant in radian
/// </summary>
/// <param name="hypotenuse">The hypotenuse for a unit opposite (i.e. hypotenuse / opposite).</param>
/// <returns>The angle in radian.</returns>
stock float Math_Acsc(float hypotenuse)
{
	return ArcSine(1 / hypotenuse);
}

/// <summary>
/// Hyperbolic Sine
/// </summary>
/// <param name="angle">The hyperbolic angle, i.e. the area of the hyperbolic sector.</param>
/// <returns>The hyperbolic sine of the angle.</returns>
stock float Math_Sinh(float angle)
{
	return (Exponential(angle) - Exponential(-angle)) / 2;
}


/// <summary>
/// Hyperbolic Cosine
/// </summary>
/// <param name="angle">The hyperbolic angle, i.e. the area of the hyperbolic sector.</param>
/// <returns>The hyperbolic Cosine of the angle.</returns>
stock float Math_Cosh(float angle)
{
	return (Exponential(angle) + Exponential(-angle)) / 2;
}

/// <summary>
/// Hyperbolic Tangent in radian
/// </summary>
/// <param name="angle">The hyperbolic angle, i.e. the area of the hyperbolic sector.</param>
/// <returns>The hyperbolic tangent of the angle.</returns>
stock float Math_Tanh(float angle)
{
	if (angle > 19.1)
	{
		return 1.0;
	}

	if (angle < -19.1)
	{
		return -1;
	}

	float e1 = Exponential(angle);
	float e2 = Exponential(-angle);
	return (e1 - e2) / (e1 + e2);
}

/// <summary>
/// Hyperbolic Cotangent
/// </summary>
/// <param name="angle">The hyperbolic angle, i.e. the area of the hyperbolic sector.</param>
/// <returns>The hyperbolic cotangent of the angle.</returns>
stock float Math_Coth(float angle)
{
	if (angle > 19.115)
	{
		return 1.0;
	}

	if (angle < -19.115)
	{
		return -1;
	}

	float e1 = Exponential(angle);
	float e2 = Exponential(-angle);
	return (e1 + e2) / (e1 - e2);
}



/// <summary>
/// Hyperbolic Secant
/// </summary>
/// <param name="angle">The hyperbolic angle, i.e. the area of the hyperbolic sector.</param>
/// <returns>The hyperbolic secant of the angle.</returns>
stock float Math_Sech(float angle)
{
	return 1 / Math_Cosh(angle);
}


/// <summary>
/// Hyperbolic Cosecant
/// </summary>
/// <param name="angle">The hyperbolic angle, i.e. the area of the hyperbolic sector.</param>
/// <returns>The hyperbolic cosecant of the angle.</returns>
stock float Math_Csch(float angle)
{
	return 1 / Math_Sinh(angle);
}


/// Returns an integer that indicates the sign of a single-precision floating-point number.
stock int Math_Sign(float value)
{
	if(value < 0)
	{
		return -1;
	}
	else if(value > 0)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}


/// <summary>
/// Hyperbolic Area Sine
/// </summary>
/// <param name="value">The real value.</param>
/// <returns>The hyperbolic angle, i.e. the area of its hyperbolic sector.</returns>
stock float Math_Asinh(float value)
{
	// asinh(x) = Sign(x) * ln(|x| + sqrt(x*x + 1))
	// if |x| > huge, asinh(x) ~= Sign(x) * ln(2|x|)

	if (FloatAbs(value) >= 268435456.0) // 2^28, taken from freeBSD
		return Math_Sign(value) * (Logarithm(FloatAbs(value)) + Logarithm(2.0));

	return Math_Sign(value) * Logarithm(FloatAbs(value) + SquareRoot((value * value) + 1));
}



/// <summary>
/// Hyperbolic Area Cosine
/// </summary>
/// <param name="value">The real value.</param>
/// <returns>The hyperbolic angle, i.e. the area of its hyperbolic sector.</returns>
stock float Math_Acosh(float value)
{
	// acosh(x) = ln(x + sqrt(x*x - 1))
	// if |x| >= 2^28, acosh(x) ~ ln(x) + ln(2)

	if (FloatAbs(value) >= 268435456.0) // 2^28, taken from freeBSD
		return Logarithm(value) + Logarithm(2.0);

	return Logarithm(value + (SquareRoot(value - 1) * SquareRoot(value + 1)), Constants_E);
}


/// <summary>
/// Hyperbolic Area Tangent
/// </summary>
/// <param name="value">The real value.</param>
/// <returns>The hyperbolic angle, i.e. the area of its hyperbolic sector.</returns>
stock float Math_Atanh(float value)
{
	return 0.5 * Logarithm((1 + value) / (1 - value), Constants_E);
}



/// <summary>
/// Hyperbolic Area Cotangent
/// </summary>
/// <param name="value">The real value.</param>
/// <returns>The hyperbolic angle, i.e. the area of its hyperbolic sector.</returns>
stock float Math_Acoth(float value)
{
	return 0.5 * Logarithm((value + 1) / (value - 1), Constants_E);
}


/// <summary>
/// Hyperbolic Area Secant
/// </summary>
/// <param name="value">The real value.</param>
/// <returns>The hyperbolic angle, i.e. the area of its hyperbolic sector.</returns>
stock float Math_Asech(float value)
{
	return Math_Acosh(1 / value);
}

/// <summary>
/// Hyperbolic Area Cosecant
/// </summary>
/// <param name="value">The real value.</param>
/// <returns>The hyperbolic angle, i.e. the area of its hyperbolic sector.</returns>
stock float Math_Acsch(float value)
{
	return Math_Asinh(1 / value);
}