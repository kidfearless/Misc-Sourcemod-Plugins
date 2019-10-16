// <copyright file="ArrayStatistics.Single.cs" company="Math.NET">
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
/// Returns the smallest value from the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_Minimumf(float[] data, int length)
{
	if (length == 0)
	{
		return float.NaN;
	}

	float min = float.PositiveInfinity;
	for (int i = 0; i < length; i++)
	{
		if (data[i] < min || float.IsNaN(data[i]))
		{
			min = data[i];
		}
	}

	return min;
}

/// <summary>
/// Returns the smallest value from the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_Maximumf(float[] data, int length)
{
	if (length == 0)
	{
		return float.NaN;
	}

	float max = float.NegativeInfinity;
	for (int i = 0; i < length; i++)
	{
		if (data[i] > max || float.IsNaN(data[i]))
		{
			max = data[i];
		}
	}

	return max;
}

/// <summary>
/// Returns the smallest absolute value from the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_MinimumAbsolutef(float[] data, int length)
{
	if (length == 0)
	{
		return float.NaN;
	}

	float min = float.PositiveInfinity;
	for (int i = 0; i < length; i++)
	{
		if (FloatAbs(data[i]) < min || float.IsNaN(data[i]))
		{
			min = FloatAbs(data[i]);
		}
	}

	return min;
}

/// <summary>
/// Returns the largest absolute value from the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_MaximumAbsolutef(float[] data, int length)
{
	if (length == 0)
	{
		return float.NaN;
	}

	float max = 0.0;
	for (int i = 0; i < length; i++)
	{
		if (FloatAbs(data[i]) > max || float.IsNaN(data[i]))
		{
			max = FloatAbs(data[i]);
		}
	}

	return max;
}

/// <summary>
/// Estimates the arithmetic sample mean from the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_Meanf(float[] data, int length)
{
	if (length == 0)
	{
		return float.NaN;
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
stock float Math_GeometricMeanf(float[] data, int length)
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
stock float Math_HarmonicMeanf(float[] data, int length)
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
stock float Math_Variancef(float[] samples, int length)
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
stock float Math_PopulationVariancef(float[] population, int length)
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
stock float Math_StandardDeviationf(float[] samples, int length)
{
	return SquareRoot(Math_Variancef(samples, length));
}

/// <summary>
/// Evaluates the population standard deviation from the full population provided as unsorted array.
/// On a dataset of size N will use an N normalizer and would thus be biased if applied to a subset.
/// Returns NaN if data is empty or if any entry is NaN.
/// </summary>
/// <param name="population">Sample array, no sorting is assumed.</param>
stock float Math_PopulationStandardDeviationf(float[] population, int length)
{
	return SquareRoot(Math_PopulationVariancef(population, length));
}

/// <summary>
/// Estimates the arithmetic sample mean and the unbiased population variance from the provided samples as unsorted array.
/// On a dataset of size N will use an N-1 normalizer (Bessel's correction).
/// Returns NaN for mean if data is empty or any entry is NaN and NaN for variance if data has less than two entries or if any entry is NaN.
/// </summary>
/// <param name="samples">Sample array, no sorting is assumed.</param>
stock Tuple<float, float> MeanVariancef(float[] samples)
{
	return new Tuple<float, float>(Mean(samples), Variance(samples));
}

/// <summary>
/// Estimates the arithmetic sample mean and the unbiased population standard deviation from the provided samples as unsorted array.
/// On a dataset of size N will use an N-1 normalizer (Bessel's correction).
/// Returns NaN for mean if data is empty or any entry is NaN and NaN for standard deviation if data has less than two entries or if any entry is NaN.
/// </summary>
/// <param name="samples">Sample array, no sorting is assumed.</param>
stock Tuple<float, float> MeanStandardDeviationf(float[] samples)
{
	return new Tuple<float, float>(Mean(samples), StandardDeviation(samples));
}

/// <summary>
/// Estimates the unbiased population covariance from the provided two sample arrays.
/// On a dataset of size N will use an N-1 normalizer (Bessel's correction).
/// Returns NaN if data has less than two entries or if any entry is NaN.
/// </summary>
/// <param name="samples1">First sample array.</param>
/// <param name="samples2">Second sample array.</param>
stock float Math_Covariancef(float[] samples1, float[] samples2)
{
	if (samples1.Length != samples2.Length)
	{
		throw new ArgumentException(Resources.ArgumentVectorsSameLength);
	}

	if (samples1.Length <= 1)
	{
		return float.NaN;
	}

	float mean1 = Mean(samples1);
	float mean2 = Mean(samples2);
	float covariance = 0.0;
	for (int i = 0; i < samples1.Length; i++)
	{
		covariance += (samples1[i] - mean1) * (samples2[i] - mean2);
	}

	return covariance / (samples1.Length - 1);
}

/// <summary>
/// Evaluates the population covariance from the full population provided as two arrays.
/// On a dataset of size N will use an N normalizer and would thus be biased if applied to a subset.
/// Returns NaN if data is empty or if any entry is NaN.
/// </summary>
/// <param name="population1">First population array.</param>
/// <param name="population2">Second population array.</param>
stock float Math_PopulationCovariancef(float[] population1, float[] population2)
{
	if (population1.Length != population2.Length)
	{
		throw new ArgumentException(Resources.ArgumentVectorsSameLength);
	}

	if (population1.Length == 0)
	{
		return float.NaN;
	}

	float mean1 = Mean(population1);
	float mean2 = Mean(population2);
	float covariance = 0.0;
	for (int i = 0; i < population1.Length; i++)
	{
		covariance += (population1[i] - mean1) * (population2[i] - mean2);
	}

	return covariance / population1.Length;
}

/// <summary>
/// Estimates the root mean square (RMS) also known as quadratic mean from the unsorted data array.
/// Returns NaN if data is empty or any entry is NaN.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed.</param>
stock float Math_RootMeanSquaref(float[] data)
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

/// <summary>
/// Returns the order statistic (order 1..N) from the unsorted data array.
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
/// <param name="order">One-based order of the statistic, must be between 1 and N (inclusive).</param>
stock float Math_OrderStatisticInplacef(float[] data, int order)
{
	if (order < 1 || order > length)
	{
		return float.NaN;
	}

	if (order == 1)
	{
		return Minimum(data);
	}

	if (order == length)
	{
		return Maximum(data);
	}

	return SelectInplace(data, order - 1);
}

/// <summary>
/// Estimates the median value from the unsorted data array.
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
stock float Math_MedianInplacef(float[] data)
{
	float k = length / 2;
	return length.IsOdd()
		? SelectInplace(data, k)
		: (SelectInplace(data, k - 1) + SelectInplace(data, k)) / 2.0;
}

/// <summary>
/// Estimates the p-Percentile value from the unsorted data array.
/// If a non-integer Percentile is needed, use Quantile instead.
/// Approximately median-unbiased regardless of the sample distribution (R8).
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
/// <param name="p">Percentile selector, between 0 and 100 (inclusive).</param>
stock float Math_PercentileInplacef(float[] data, int p)
{
	return QuantileInplace(data, p/100.0d);
}

/// <summary>
/// Estimates the first quartile value from the unsorted data array.
/// Approximately median-unbiased regardless of the sample distribution (R8).
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
stock float Math_LowerQuartileInplacef(float[] data)
{
	return QuantileInplace(data, 0.25d);
}

/// <summary>
/// Estimates the third quartile value from the unsorted data array.
/// Approximately median-unbiased regardless of the sample distribution (R8).
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
stock float Math_UpperQuartileInplacef(float[] data)
{
	return QuantileInplace(data, 0.75d);
}

/// <summary>
/// Estimates the inter-quartile range from the unsorted data array.
/// Approximately median-unbiased regardless of the sample distribution (R8).
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
stock float Math_InterquartileRangeInplacef(float[] data)
{
	return QuantileInplace(data, 0.75d) - QuantileInplace(data, 0.25d);
}

/// <summary>
/// Estimates {min, lower-quantile, median, upper-quantile, max} from the unsorted data array.
/// Approximately median-unbiased regardless of the sample distribution (R8).
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
stock float[] FiveNumberSummaryInplacef(float[] data)
{
	if (length == 0)
	{
		return new[] { float.NaN, float.NaN, float.NaN, float.NaN, float.NaN };
	}

	// TODO: Benchmark: is this still faster than sorting the array then using SortedArrayStatistics instead?
	return new[] { Minimum(data), QuantileInplace(data, 0.25d), MedianInplace(data), QuantileInplace(data, 0.75d), Maximum(data) };
}

/// <summary>
/// Estimates the tau-th quantile from the unsorted data array.
/// The tau-th quantile is the data value where the cumulative distribution
/// function crosses tau.
/// Approximately median-unbiased regardless of the sample distribution (R8).
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
/// <param name="tau">Quantile selector, between 0.0 and 1.0 (inclusive).</param>
/// <remarks>
/// R-8, SciPy-(1/3,1/3):
/// Linear interpolation of the approximate medians for order statistics.
/// When tau &lt; (2/3) / (N + 1/3), use x1. When tau &gt;= (N - 1/3) / (N + 1/3), use xN.
/// </remarks>
stock float Math_QuantileInplacef(float[] data, float tau)
{
	if (tau < 0d || tau > 1d || length == 0)
	{
		return float.NaN;
	}

	float h = (length + 1d / 3d) * tau + 1d / 3d;
	float hf = float(h;

	if (hf <= 0 || tau == 0d)
	{
		return Minimum(data);
	}

	if (hf >= length || tau == 1d)
	{
		return Maximum(data);
	}

	float a = SelectInplace(data, hf - 1);
	float b = SelectInplace(data, hf);
	return float((a + (h - hf) * (b - a));
}

/// <summary>
/// Estimates the tau-th quantile from the unsorted data array.
/// The tau-th quantile is the data value where the cumulative distribution
/// function crosses tau. The quantile definition can be specified
/// by 4 parameters a, b, c and d, consistent with Mathematica.
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
/// <param name="tau">Quantile selector, between 0.0 and 1.0 (inclusive)</param>
/// <param name="a">a-parameter</param>
/// <param name="b">b-parameter</param>
/// <param name="c">c-parameter</param>
/// <param name="d">d-parameter</param>
stock float Math_QuantileCustomInplacef(float[] data, int length, float tau, float a, float b, float c, float d)
{
	if (tau < 0d || tau > 1d || length == 0)
	{
		return float.NaN;
	}

	float x = a + (length + b) * tau - 1;
	float ip = Math.Truncate(x);
	float fp = x - ip;

	if (FloatAbs(fp) < 1e-9)
	{
		return SelectInplace(data, RoundFloat(ip));
	}

	float lower = SelectInplace(data, RoundToFloor(x));
	float upper = SelectInplace(data, RoundToCeil(x));
	return float(lower + (upper - lower) * (c + d * fp));
}

/// <summary>
/// Estimates the tau-th quantile from the unsorted data array.
/// The tau-th quantile is the data value where the cumulative distribution
/// function crosses tau. The quantile definition can be specified to be compatible
/// with an existing system.
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
/// <param name="data">Sample array, no sorting is assumed. Will be reordered.</param>
/// <param name="tau">Quantile selector, between 0.0 and 1.0 (inclusive)</param>
/// <param name="definition">Quantile definition, to choose what product/definition it should be consistent with</param>
stock float Math_QuantileCustomInplacef(float[] data, float tau, QuantileDefinition definition)
{
	if (tau < 0d || tau > 1d || length == 0)
	{
		return float.NaN;
	}

	if (tau == 0d || length == 1)
	{
		return Minimum(data);
	}

	if (tau == 1d)
	{
		return Maximum(data);
	}

	switch (definition)
	{
		case QuantileDefinition.R1:
			{
				float h = length * tau + 0.5d;
				return SelectInplace(data, RoundToCeil(h - 0.5d) - 1);
			}

		case QuantileDefinition.R2:
			{
				float h = length * tau + 0.5d;
				return (SelectInplace(data, RoundToCeil(h - 0.5d) - 1) + SelectInplace(data, RoundFloat(h + 0.5d) - 1)) * 0.5f;
			}

		case QuantileDefinition.R3:
			{
				float h = length * tau;
				return SelectInplace(data, RoundFloat(h) - 1);
			}

		case QuantileDefinition.R4:
			{
				float h = length * tau;
				float hf = RoundFloat(h);
				float lower = SelectInplace(data, hf - 1);
				float upper = SelectInplace(data, hf);
				return float(lower + (h - hf) * (upper - lower));
			}

		case QuantileDefinition.R5:
			{
				float h = length * tau + 0.5d;
				float hf = RoundFloat(h);
				float lower = SelectInplace(data, hf - 1);
				float upper = SelectInplace(data, hf);
				return float(lower + (h - hf) * (upper - lower));
			}

		case QuantileDefinition.R6:
			{
				float h = (length + 1) * tau;
				float hf = RoundFloat(h);
				float lower = SelectInplace(data, hf - 1);
				float upper = SelectInplace(data, hf);
				return float(lower + (h - hf) * (upper - lower));
			}

		case QuantileDefinition.R7:
			{
				float h = (length - 1) * tau + 1d;
				float hf = RoundFloat(h);
				float lower = SelectInplace(data, hf - 1);
				float upper = SelectInplace(data, hf);
				return float(lower + (h - hf) * (upper - lower));
			}

		case QuantileDefinition.R8:
			{
				float h = (length + 1 / 3d) * tau + 1 / 3d;
				float hf = RoundFloat(h);
				float lower = SelectInplace(data, hf - 1);
				float upper = SelectInplace(data, hf);
				return float(lower + (h - hf) * (upper - lower));
			}

		case QuantileDefinition.R9:
			{
				float h = (length + 0.25d) * tau + 0.375d;
				float hf = RoundFloat(h);
				float lower = SelectInplace(data, hf - 1);
				float upper = SelectInplace(data, hf);
				return float(lower + (h - hf) * (upper - lower));
			}

		default:
			throw new NotSupportedException();
	}
}

static float SelectInplacef(float[] workingData, int rank)
{
	// Numerical Recipes: select
	// http://en.wikipedia.org/wiki/Selection_algorithm
	if (rank <= 0)
	{
		return Minimum(workingData);
	}

	if (rank >= workinglength - 1)
	{
		return Maximum(workingData);
	}

	float[] a = workingData;
	int low = 0;
	int high = a.Length - 1;

	while (true)
	{
		if (high <= low + 1)
		{
			if (high == low + 1 && a[high] < a[low])
			{
				float tmp = a[low];
				a[low] = a[high];
				a[high] = tmp;
			}

			return a[rank];
		}

		int middle = (low + high) >> 1;

		float tmp1 = a[middle];
		a[middle] = a[low + 1];
		a[low + 1] = tmp1;

		if (a[low] > a[high])
		{
			float tmp = a[low];
			a[low] = a[high];
			a[high] = tmp;
		}

		if (a[low + 1] > a[high])
		{
			float tmp = a[low + 1];
			a[low + 1] = a[high];
			a[high] = tmp;
		}

		if (a[low] > a[low + 1])
		{
			float tmp = a[low];
			a[low] = a[low + 1];
			a[low + 1] = tmp;
		}

		int begin = low + 1;
		int end = high;
		float pivot = a[begin];

		while (true)
		{
			do
			{
				begin++;
			}
			while (a[begin] < pivot);

			do
			{
				end--;
			}
			while (a[end] > pivot);

			if (end < begin)
			{
				break;
			}

			float tmp = a[begin];
			a[begin] = a[end];
			a[end] = tmp;
		}

		a[low + 1] = a[end];
		a[end] = pivot;

		if (end >= rank)
		{
			high = end - 1;
		}

		if (end <= rank)
		{
			low = begin;
		}
	}
}

/// <summary>
/// Evaluates the rank of each entry of the unsorted data array.
/// The rank definition can be specified to be compatible
/// with an existing system.
/// WARNING: Works inplace and can thus causes the data array to be reordered.
/// </summary>
stock float[] RanksInplacef(float[] data, RankDefinition definition = RankDefinition.Default)
{
	float ranks = new float[length];
	float index = new int[length];
	for (int i = 0; i < index.Length; i++)
	{
		index[i] = i;
	}

	if (definition == RankDefinition.First)
	{
		Sorting.SortAll(data, index);
		for (int i = 0; i < ranks.Length; i++)
		{
			ranks[index[i]] = i + 1;
		}

		return ranks;
	}

	Sorting.Sort(data, index);
	int previousIndex = 0;
	for (int i = 1; i < length; i++)
	{
		if (FloatAbs(data[i] - data[previousIndex]) <= 0d)
		{
			continue;
		}

		if (i == previousIndex + 1)
		{
			ranks[index[previousIndex]] = i;
		}
		else
		{
			RanksTies(ranks, index, previousIndex, i, definition);
		}

		previousIndex = i;
	}

	RanksTies(ranks, index, previousIndex, length, definition);
	return ranks;
}

static void RanksTiesf(float[] ranks, int[] index, int a, int b, RankDefinition definition)
{
	// TODO: potential for PERF optimization
	float rank;
	switch (definition)
	{
		case RankDefinition.Average:
		{
			rank = (b + a - 1) / 2f + 1;
			break;
		}

		case RankDefinition.Min:
		{
			rank = a + 1;
			break;
		}

		case RankDefinition.Max:
		{
			rank = b;
			break;
		}

		default:
			throw new NotSupportedException();
	}

	for (int k = a; k < b; k++)
	{
		ranks[index[k]] = rank;
	}
}