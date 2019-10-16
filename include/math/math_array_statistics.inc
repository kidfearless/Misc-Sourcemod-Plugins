// <copyright file="ArrayStatistics.Int32.cs" company="Math.NET">
// Math.NET Numerics, part of the Math.NET Project
// http://numerics.mathdotnet.com
// http://github.com/mathnet/mathnet-numerics
//
// Copyright (c) 2009-2015 Math.NET
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


/// <summary>
/// Estimates the arithmetic sample mean from the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_Mean(int[] data, int length)
{
	if (length == 0)
	{
		return -1;
	}

	float mean = 0;
	float m = 0;
	for (int i = 0; i < length; i++)
	{
		mean += (data[i] - mean) / ++m;
	}

	return mean;
}

/// <summary>
/// Evaluates the geometric mean of the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_GeometricMean(int[] data, int length)
{
	if (length == 0)
	{
		return float.NaN;
	}

	float sum = 0;
	for (int i = 0; i < length; i++)
	{
		sum += Logarithm(data[i]);
	}

	return Exponential(sum / length);
}

/// <summary>
/// Evaluates the harmonic mean of the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_HarmonicMean(int[] data, int length)
{
	if (length == 0)
	{
		return float.NaN;
	}

	float sum = 0;
	for (int i = 0; i < length; i++)
	{
		sum += 1.0 / data[i];
	}

	return length / sum;
}

/// <summary>
/// Estimates the unbiased population variance from the provided samples as unsorted array.
/// On a dataset of size N will use an N-1 normalizer (Bessel's correction).
/// Returns NaN if data has less than two entries or if any entry is NaN.
/// </summary>
/// <param name="samples">Sample array, no sorting is assumed.</param>
stock float Math_Variance(int[] samples, int length)
{
	if (length <= 1)
	{
		return float.NaN;
	}

	float variance = 0;
	float t = samples[0];
	for (int i = 1; i < length; i++)
	{
		t += samples[i];
		float diff = ((i + 1) * samples[i]) - t;
		variance += (diff * diff) / ((i + 1.0) * i);
	}

	return variance / (length - 1);
}

/// <summary>
/// Evaluates the population variance from the full population provided as unsorted array.
/// On a dataset of size N will use an N normalizer and would thus be biased if applied to a subset.
/// Returns NaN if data is empty or if any entry is NaN.
/// </summary>
/// <param name="population">Sample array, no sorting is assumed.</param>
stock float Math_PopulationVariance(int[] population, int length)
{
	if (length == 0)
	{
		return float.NaN;
	}

	float variance = 0;
	float t = population[0];
	for (int i = 1; i < length; i++)
	{
		t += population[i];
		float diff = ((i + 1) * population[i]) - t;
		variance += (diff * diff) / ((i + 1.0) * i);
	}

	return variance / length;
}

/// <summary>
/// Estimates the unbiased population standard deviation from the provided samples as unsorted array.
/// On a dataset of size N will use an N-1 normalizer (Bessel's correction).
/// Returns NaN if data has less than two entries or if any entry is NaN.
/// </summary>
/// <param name="samples">Sample array, no sorting is assumed.</param>
stock float Math_StandardDeviation(int[] samples)
{
	return SquareRoot(Math_Variance(samples));
}

/// <summary>
/// Evaluates the population standard deviation from the full population provided as unsorted array.
/// On a dataset of size N will use an N normalizer and would thus be biased if applied to a subset.
/// Returns NaN if data is empty or if any entry is NaN.
/// </summary>
/// <param name="population">Sample array, no sorting is assumed.</param>
stock float Math_PopulationStandardDeviation(int[] population)
{
	return SquareRoot(Math_PopulationVariance(population));
}

/// <summary>
/// Estimates the arithmetic sample mean and the unbiased population variance from the provided samples as unsorted array.
/// On a dataset of size N will use an N-1 normalizer (Bessel's correction).
/// Returns NaN for mean if data is empty or any entry is NaN and NaN for variance if data has less than two entries or if any entry is NaN.
/// </summary>
/// <param name="samples">Sample array, no sorting is assumed.</param>
stock float Math_MeanVariance(int[] samples, float& variance = 0)
{
	variance = Math_Variance(samples);
	return Math_Mean(samples);
}

/// <summary>
/// Estimates the arithmetic sample mean and the unbiased population standard deviation from the provided samples as unsorted array.
/// On a dataset of size N will use an N-1 normalizer (Bessel's correction).
/// Returns NaN for mean if data is empty or any entry is NaN and NaN for standard deviation if data has less than two entries or if any entry is NaN.
/// </summary>
/// <param name="samples">Sample array, no sorting is assumed.</param>
stock float Math_MeanStandardDeviation(int[] samples, float& sd = 0)
{
	sd = Math_StandardDeviation(samples);
	return Math_Mean(samples);
}

/// <summary>
/// Estimates the unbiased population covariance from the provided two sample arrays.
/// On a dataset of size N will use an N-1 normalizer (Bessel's correction).
/// Returns NaN if data has less than two entries or if any entry is NaN.
/// </summary>
/// <param name="samples1">First sample array.</param>
/// <param name="samples2">Second sample array.</param>
stock float Math_Covariance(int[] samples1, int length1, int[] samples2, length2)
{
	if (length1 != length2)
	{
		throw new ArgumentException(Resources.ArgumentVectorsSameLength);
	}

	if (length1 <= 1)
	{
		return float.NaN;
	}

	float mean1 = Math_Mean(samples1);
	float mean2 = Math_Mean(samples2);
	float covariance = 0.0;
	for (int i = 0; i < length1; i++)
	{
		covariance += (samples1[i] - mean1) * (samples2[i] - mean2);
	}

	return covariance / (length1 - 1);
}

/// <summary>
/// Evaluates the population covariance from the full population provided as two arrays.
/// On a dataset of size N will use an N normalizer and would thus be biased if applied to a subset.
/// Returns NaN if data is empty or if any entry is NaN.
/// </summary>
/// <param name="population1">First population array.</param>
/// <param name="population2">Second population array.</param>
stock float Math_PopulationCovariance(int[] population1, int length1, int[] population2, int length2)
{
	if (length1 != length2)
	{
		throw new ArgumentException(Resources.ArgumentVectorsSameLength);
	}

	if (length1 == 0)
	{
		return float.NaN;
	}

	float mean1 = Math_Mean(population1);
	float mean2 = Math_Mean(population2);
	float covariance = 0.0;
	for (int i = 0; i < length1; i++)
	{
		covariance += (population1[i] - mean1) * (population2[i] - mean2);
	}

	return covariance / length1;
}

/// <summary>
/// Estimates the root mean square (RMS) also known as quadratic mean from the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_RootMeanSquare(int[] data, int length)
{
	if (length == 0)
	{
		return float.NaN;
	}

	float mean = 0;
	float m = 0;
	for (int i = 0; i < length; i++)
	{
		mean += (data[i] * data[i] - mean) / ++m;
	}

	return SquareRoot(mean);
}