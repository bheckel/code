Descriptive statistics - procedures used to summarize, organize and simplify data

Inferential statistics - techniques that allow for generalizations about POPULATION
parameters based on SAMPLE statistics


Randomized Experiments (vs. Observational Studies - analysis of correlations):

POPULATION - entire collection of cases to which we want to generalize (e.g. all children
in the US)

SAMPLE - a subset of the population (e.g. 4K children from VA, not very representative)


Parameter - a numerical measure that describes a characteristic of a POPULATION

Statistic - a numerical measure that describes a characteristic of a SAMPLE (uses bar notation e.g. xbar)


Independent variable - manipulated by the experimenter (e.g. polio vaccine or placebo),
observational studies don't manipulate these

Quasi-independent variable - no random assigment to conditions (e.g. concussed
footballers)

Dependent variable - represents the aspect of the world that the experimenter predicts
will be *affected* by the independent variable (e.g. polio diagnosis in an individual
child, rate of polio in a group of children).  Outcome measures.

Confound - e.g. non-control group person goes to lab but does no memory
training but becomes more comfortable and scores higher as a result of that
comfort

Causality - requires true independent variables, random & representative samples, no 
confounds.  Weaker causality for Observational Studies.

---

Descriptive statistics (4 moments of the mean):

Mean, median, mode (peak of the histogram) are measures of location or central tendency

Stdev, IQR, variance are measures of spread / variability (how wide is the histogram)

Skewness & Kurtosis are measurements of non-normal distribution histogram shape.


Sigma is population standard deviation
s is sample standard deviation

Empirical rule Normal Distribution:  +/-1 sigma 68.3%  +/-2 sigma 95.5%  +/-3 sigma 99.7%
                   _from tables_
P(-1.0<=z<=+1.0) = 0.8413-0.1587 = 0.683

Mean, median & mode are same and fall at the bell curve peak
Asymptotic tails extend indefinitely, never quite touching the x axis

Skewness & kurtosis the closer to 0 the closer your data is to the normal distribution.
>+1.5 or <-1.5 indicates a non-normal distribution

Left/negative skew means left side has a long tail (lump on right side, data
trailing away on left side), therefore mean < median.  The mean is on the
left side of the peak.
E.g.:
Income distribution is right/positive skewed in histogram: /^^^\...
SAT scores at Princeton are left/negatively skewed in histogram: .../^^^\

Closer mean is to median, closer your data is to normal distribution

Median is preferred when there are extreme (or skewed) scores in the distribution

Kurtosis measures the peaked-ness of the data.  Light tailed has little or no
data in the tails, the peak is flatter than normal.

---

Linear regression is the “best guess” at using a set of data to make some kind of prediction.

E.g. A moderate positive correlation coefficient
age: 43, 21, 25, 42, 57, 59  glucose: 99, 65, 79, 75, 87, 81

 n=6                                 <---
 sum(x) = 247                        <---
 sum(y) = 486                        <---

 xy   43*99=4257, 21*65=1365, ...
 sum(xy) = 4257+1365+ ... = 20485    <---

 x^2  43^2=1849, 21^2=441, ...
  sum(x^2) = 1849+441+ ... = 11409   <---
 y^2  99^2=9801, 65^2=4225, ... 
  sum(y^2) 9801+4225+ ... = 40022    <---

r = 6(20485) – (247 × 486) / [√[[6(11409) – (247^2)] × [6(40022) – 486^2]]] = 0.5298


At r=1.0 everyone in the sample is on the regression line, a perfect model, r=0 is a terrible model for predicting.
At 0.5  graph arrow goes from SW corner to NE corner
At 0    graph arrow goes from W to E 
At -0.5 graph arrow goes from NW corner to SE corner


Alternatively:

Pearson r is degree to which X&Y vary TOGETHER relative to the degree to which they vary INDEPENDENTLY:
r = (covariance of X&Y) / (variance of X&Y)

Covariance (of X&Y) using raw scores:
                             "cross products"
     _________________________________________________________________________
SP = (the deviation scores on X) are multiplied by (the deviation scores on Y), then summed (i.e. SS XY)


Variance (of X&Y):
sqrt(SS of X multiplied by SS of Y)

r = SP of XY / VAR of XY

Can instead use Z-score to get covariance:
r = (sum of ZsubX and ZsubY) / N

Variance = MS = SS/N
Covariance = SP/N  (correlation becomes standardized: -1 thru 1)

---

categorical  - nominal                                 - drink type (beer, wine, gin)
categorical  - ordinal                                 - cup size (sm med lg)
quantitative - interval in a range, no true zero point - temperature (80F is NOT twice as warm as 40F)
quantitative - ratio, there are true zero points       - weight, salary, age (40YO is twice as old as a 20YO)

discrete: whole number resulting from COUNTING
continuous: any value within an interval resulting from MEASURING, e.g. weight, distance, speed, time

---

Hypothesis testing's purpose is to use sample information and make a statistical conclusion about
rejecting or not rejecting that conclusion based on that sample.  We never "accept" H0 because
our conclusions are based on a sample.  Like "not guilty" doesn't mean "innocent", just that there
wasn't enough evidence to convict.

1- state H0 & HA
2- determine level of significance
3- calc the test statistic
4- determine the critical z-value(s)
5- state your decision

H0 = null hypothesis (r=0) i.e. the population mean equals the hypothesized mean (i.e. the
lack of a difference in your study).  H0 is status quo.

HA = alternative hypothesis (r>0) i.e. the population mean differs from the hypothesized mean

A two-tailed test is used when the hypothesis is stated as an equality:

E.g. dean says college student credit card debt mu = $4100 (therefore a two-tailed hypothesis
test)

E.g. college student credit card debt mu != $4100

One-tailed (when HA is stated as "<" or ">" rather than two-tails' "="):
E.g. new super golf ball, inventor WANTS to reject H0 and may opt for a high alpha
H0 mu <= 20yd
HA mu > 20yd
Null is "<=" so therefore it's a one-tail (right side) hypothesis test
    ___
   /   \
 _/     \_  
-----0----- z
         |
         |reject H0
         |->

---

Significance level is alpha, a, the probability of making a Type I error. It
is usually set between 0.01 and 0.10 before we collect the sample.

p-value is the smallest level of significance at which the null will be
rejected, assuming H0 is true - sometimes called the observed level of significance

E.g. a two-tailed test, z-test statistic is found to be 1.19 and alpha is set at 0.05
0.05 / 2 = 0.025 is alpha in each tail
p = P(z <= +1.19) = 0.8830 from the tables
1 - 0.8830 = 0.117
0.117 * 2 = 0.234 total of both tails because two-tailed test
0.234 > 0.05 so we can't reject H0

"Statistically significant" is when your results likely did not happen by
chance.  I.e. p-value < alpha (alpha is often 0.05, 2.5% in each tail) - so
it's ok to reject H0.  Significance level of 0.05 indicates a 5% risk of
concluding that a difference exists when there is no actual difference.

For a significance level of 0.05, expect to obtain sample means in the
critical region 5% of the time when the null hypothesis is true. In these
cases, you won’t know that the null hypothesis is true but you’ll reject it
because the sample mean falls in the critical region. That’s why the
significance level is also referred to as an error rate!

Significance levels and p-values are important tools that help you quantify
and control this type of error in a hypothesis test. Using these tools to
decide when to reject the null hypothesis increases your chance of making the
correct decision.

E.g. Our sample mean (xbar 330.6) falls within the critical region (tail), which
indicates it is statistically significant at the 0.05 level.  So we REJECT the
null hypothesis given the significance level of 0.05.

"Statistically highly significant" is p < 0.001 ie. less than one in a thousand
chance of obtaining an effect at least as extreme as the one in your sample
data, assuming the truth of the null hypothesis.  We don't know whether the
null is true or not. Importantly, we don't know the probability of it being
true or not. However, we make this assumption in order to have a point of
comparison for a sample statistic.

p-value is the probability of obtaining these data (getting this outcome)
given H0. p-values address only one question: how likely are your data,
assuming a true null hypothesis?  It does not measure support for the
alternative hypothesis.  It is not an error rate.  In reality, p-value of
0.0027 can correspond to an error rate of at least 4.5%, which is close to the
rate that many mistakenly attribute to a p-value of 0.05!

For example, suppose that a vaccine study produced a p-value of 0.01. This
p-value indicates that if the vaccine had no effect, you’d obtain the observed
difference or more in only 1% of studies due to random sampling error.  It's
not a 1% chance of making a mistake!

A low p-value suggests that your sample provides enough evidence that you can
REJECT the null hypothesis for the entire population.  A low p-value indicates
that your data are unlikely assuming a true null hypothesis.

High p-values 50% 90% tell you to NOT reject H0.

---

Type I error is the false rejection of the null hypothesis - a false alarm
Type II error is the false acceptance of the null hypothesis - a miss
As an aid memoir: think that our cynical society rejects before it accepts.

---

The IQR (interquartile range) is the difference between the 25th and 75th
percentiles. It is not as likely to be affected by outliers and therefore is
more robust than the overall range.

50th percentile is the median

---

Variance - the average squared difference of observations from the mean, i.e.
the square of the SD

Standard deviation or sigma is how tightly or loosely the values are grouped around the
mean, a measure of consistency:
sigma = sqrt(SS/n-1)

---

Z-score - a standardized unit of measurement - the number of standard
deviations that any point is from the mean, negative is below mean, positive is
above

Z = (raw sample value - sample mean)/standard deviation
Z = (      X          -   xbar)     /sigma

Use tables or R to get Percentile Rank of Z
Probability is 1 minus Percentile Rank

Bell curve x axis scale changes to mu=0 and your actual value changes to Z when using Z-scores

Normal Distribution: bell-shaped and symmetrical around the mean, total area = 1.0, mu = 0 and sigma = 1
E.g. if mean is 60 oz (and sigma 5 oz) bug spray per season, then 64.3 is 0.86 sigma away from the mean
64.3-60 / 5 = 0.86
Use 0.86 to lookup probability in the Standard Normal Table, find .8051, the
(predominantly left) shaded area of the bell curve to the left of 64.3 is the
probability of using less than 64.3 oz
i.e. P(x<=64.3) = P(z<=0.86) = 0.8051

What are chances of using more than 62.5 oz?
Z = 62.5-60 / 5 = 0.5
So Standard Normal Table says 0.6915 but that's P(z<=.5) and we want P(z>=.5) so
use complement rule
1 - 0.6915 = 0.3085 the (slightly right) shaded area of the bell curve to the
right of 62.5 is the probability of using more than 62.5 oz
i.e. P(x>62.5) = P(z<=0.5) = 1 - P(z>0.5) = 0.3085

Can use Normal instead of Binomial if n * success probability>=5 and n * failure probability<=5
e.g. Select 15 students at random. 60% of class is female.  What is probability
this group will contain 8, 9 10 or 11 females i.e. P(x=8)+P(x=9)+P(x=10)+P(x=11)? 
Ok to use Normal because np = 15*0.6 = 9 and nq = 15*0.4 = 6

mu = np = 15*.06 = 9
sigma = sqrt(npq) = sqrt(15*0.6*0.4) = 1.897

---

Standard deviation example (see also readme.R.txt):

X:
455.05 + 459.3 + 462.04 + 448.26
=1824.65
./4
456.16  # population mean "mu"

(X-mu):
455.05-456.16 = -1.11  # deviation score  ( -1.11 + 3.14 + 5.88 + -7.9 = 0 )
459.3-456.16 = 3.14    # deviation score
462.04-456.16 = 5.88   # deviation score
448.26-456.16 = -7.90  # deviation score

(X-mu)^2:
-1.11^2 = 1.2321   # deviation score squared "squares"
 3.14^2 = 9.8596   # deviation score squared "squares"
 5.88^2 = 34.5744  # deviation score squared "squares"
-7.90^2 = 62.410   # deviation score squared "squares"

1.2321+9.8596+34.5744+62.4100
108.0761  # SS "sums of squares"

"Mean squares" is calculated by dividing the corresponding "sum of squares" by the degrees of freedom (DF), 3
108.0761/(4-1)
36.025  # variance or sigma^2 or mean of SS aka MS ("mean squares") - the estimate of population variance

sqrt(36.025)
6.00208297176905077812  # sigma


Z = (455.05-456.16)/6.00208297176905077812 = -.18493579732584722730
Z = (459.3-456.16) /6.00208297176905077812 = .52315171495780206643
Z = (462.04-456.16)/6.00208297176905077812 = .97965989934773125816
Z = (448.26-456.16)/6.00208297176905077812 = -1.31620972871548927542

-1.31620972871548927542+.97965989934773125816+.52315171495780206643+-.18493579732584722730 = 0

---

ANOVA can determine whether the means of three or more groups are different.

---

Degrees of Freedom (DF): number of free choices you have after something (e.g. the
mean) has been decided

E.g. if my sample size of 3 has a mean of 10, we can only vary 2 of the 3
values (i.e. n-1) otherwise the mean will have to change

---

Student's t-values and t-distributions work together to produce probabilities
when we have small, n<30, samples and sigma is unknown (and we can't use CLT's
standard normal distribution to find z-value).

You can compare a sample mean xbar to a hypothesized or target value using a
one-sample t-test. You can compare the means of two groups with a two-sample
t-test. If you have two groups with paired observations (e.g., before and
after measurements), use the paired t-test.  Those tests are based on
t-values.

The calculations behind t-values compare your sample mean(s) to H0 and
incorporates both the sample size and the variability in the data. A t-value
of 0 indicates that the sample results exactly equal the null hypothesis. As
the difference between the sample data and the null hypothesis increases, the
absolute value of the t-value increases.

We need a t-distribution to make sense of a t-value.  A specific
t-distribution is defined by its degrees of freedom (DF), a value closely
related to sample size.  T-distributions assume that you draw repeated random
samples from a population where the null hypothesis is true. You place the
t-value from your study in the t-distribution to determine how consistent your
results are with the null hypothesis.  The peak of the curve is 0.  It has a
mean of 0 just like Normal distribution but a variance >1.  Our
ultimate goal is to determine whether our t-value is unusual enough (far
enough away from 0) to warrant rejecting H0. 

The bell curve is "squeezed" as the DF increases (thicker tails, higher peak
at 0).  At 30+ DF it is almost identical to the Normal distribution.

---

An F-statistic (aka F critical value) is a ratio of two quantities that are
expected to be roughly equal under the null hypothesis, which produces an
F-statistic of approximately 1 in that case.  In order to reject the null
hypothesis that the group means are equal (reject meaning something is
significant), we need a high F-value.

An F-statistic is a value you get when you run an ANOVA test or a regression
analysis to find out if the means between two populations are significantly
different. It’s similar to a T-statistic from a T-test; A T-test will tell you
if a single variable is statistically significant, an F-test will tell you
if a group of variables are JOINTLY significant.

Is our F-value high enough? A single F-value is hard to interpret on its own.
We need to place our F-value into a larger context before we can interpret it.
To do that, we’ll use the F-distribution to calculate probabilities.

The probability that we want to calculate, p-value, is the probability of
observing an F-statistic that is at least as high as the value that our study
obtained.  That probability allows us to determine how common or rare our
F-value is under the assumption that the null hypothesis is true. If the
probability is low enough, we can conclude that our data is inconsistent with
the null hypothesis. The evidence in the sample data is strong enough to
reject the null hypothesis for the entire population.

The F-distribution graph displays the distribution of F-values that we'd
obtain if the null hypothesis is true and we repeat our study many times. The
shaded area in the tail represents the probability of observing an F-value
that is at least as large as the F-value our study obtained.

If, for example, the F-values fall within the shaded critical region tail
where alpha=0.03116 (3.1% of the time) when H0 is true, that probability is
low (rare) enough to reject H0 using the common significance level of 0.05.
We can then conclude that not all the group means are equal.  Reject H0!

---

A chi-square goodness of fit test determines if a sample data matches a
population.  A high value for the chi-square statistic means there is a high
correlation between your two sets of data.

A chi-square test for independence compares two variables in a contingency
table to see if they are related. In a more general sense, it test to see
whether distributions of categorical variables differ from each another.
A very small chi square test statistic means that your observed data fits your
expected data extremely well. In other words, there is a relationship.

---

P(A or B)

If mutually exclusive use P(A) + P(B)

If not use P(A) + P(B) - P(A and B)


P(A and B)

If independent use P(A) * P(B)

If not use P(A) * P(B|A)  # "P(B|A) is probability of A given B"


Bayes' Theorem

If randomly pick a student who is passing what is the probability that this
student is a female?  Given P(M) is .45, P(PS|M) is .75 and P(PS|F) is .80.
So P(F) is .55

.55*.80 / (.55*.8) + (.45*.75)
.44 / .7775
.57

---

Factorial
4! = 4 * 3 * 2 * 1
0! = 1  # for whatever reason

Combination: AB and BA are the same
Permutation: AB and BA are not the same


For the first 4 letters of the alphabet we get 6 combinations of 2 letters:
4! / 2!(4-2)!
4*3*2! / 2!*2!
4*3 / 2!
4*3 / 2*1
6

AB
AC BC
AD BD CD


For the first 4 letters of the alphabet we get 12 permutations of 2 letters:
4! / (4-2)!
4*3*2! / 2!
4*3
12

AB BA CA DA
AC BC CB DB
AD BD CD DC

---

Binomial probability distribution will calculate the probability of x successes
in n trials with p success probability and q failure probability (2 outcomes
only, success/failure probabilities are constant), each trial is independent of
any other trial in the experiment)

If a class has 5 students what is probability that 3 students will pass an
exam with a history of 60% pass rate?

P(3) = 5!/3!(5-3) * (.6^3) *(.4^(5-3))
       120/12 * .216 * .16 = .345

If we calculated P(0), P(1), ..., P(5) the sum would be 1.0

---
Poisson probability distribution - the number of x occurences in the interval of y

Random variable: the actual number of shoppers during the next (non-overlapping) hour period
Mean of 11 shoppers per hour applies to 8am-9am 9am-10am ...
6 shoppers entering at 9am-10am has no effect on 2pm-3pm ...


Chance of hitting exactly 7 fairways during the next round if mean is 5:
P(x=7) = 5^7 * 2.71828^-5 / 7!
         78125*.006738 / 7*6*5*4*3*2*1 = .10
a 10% chance of hitting 7


P(x=0) + P(x=1) + P(x=2) ... P(x=infinity) = 1.0
so e.g. must use the complement rule since we can't calc all probabilities
P(x>=3) = 1 - (P(x=0) + P(x=1) + P(x=2))

Can use Poisson instead of Binomial if success probability<=0.05 and n>=20

---

Cluster sampling e.g. randomly chosen university classrooms participate in a
survey, in each class chosen randomly every student would be selected  Strata
are subsets of the population and have nothing in common.

Stratified sampling e.g. 20% of students are grad students so stratify random sample
to make sure 20% of the final sample are grad students.  Strata have something in common
but are mutually exclusive.


Sampling distribution of the sample means - the mean of each sample is the
measurement of interest.

E.g. Population 5 students with 90, 88, 86, 84, 82

All possible samples when sample size n=2:

Sample  Sample Mean a.k.a. xbar (25 combinations)
______  __
90  90  90
90  88  89
90  86  88
90  84  87
90  82  86
88  90  89
88  88  88
88  86  87
...
82  84  83
82  82  82


Mean of the Sampling distribution of the sample means

xbar Freq  Probability xbar*P(xbar)
__   __    ___________ ____________
82   1     0.04        3.28
83   2     0.08        6.64
84   3     0.12        10.08
...
90   1     0.04        3.6

mu xbar = 3.28+6.64+10.08+...+3.6 = 86
so the mean of the sampling distribution of the sample means is the same as the population mean

Standard error of the mean is the standard deviation of sample means

Standard error of the sampling distribution of the sample means:

xbar Freq  Probability ((xbar-mu^2) * P(xbar))
__   __    ___________ _______________________
82   1     0.04        0.64
83   2     0.08        0.72
84   3     0.12        0.48
...
90   1     0.04        0.64

sigma^2 xbar = 0.64+0.72+0.48+...+0.64 = 4
sigma xbar = sqrt(4) = 2

so the sigma of the sampling distribution of the sample means (a.k.a. the
standard error of the mean) is the same as the population sigma

---

Central Limit Theory (CLT) - with a sample size >= 30 the sample mean will be normally
distributed regardless of the population distribution.

Confidence level (CL) - probability (95%, 99% etc) that the interval estimate will include the
population parameter e.g. the mean.  Alpha (a.k.a. level of significance) is
the other 5% or 1%, probability of Type I error.  a = 1 - confidence level

Confidence interval (CI) - a range of values used to estimate a population parameter and is
associated with a specific confidence level

There is a 95% probability that any given confidence interval from a random
sample will contain the true population mean (mu).  IT IS NOT A 95% probability
that the mu is within the interval.

Common critical two-tail z-values (sigma is known, othewise use t-test statistic)
At 99% CL around the mean: z of alpha / 2 = +-2.58
At 95% CL around the mean: z of alpha / 2 = +-1.96 (a=0.05 so 0.05/2=0.025 in each tail for two-tail test)
At 90% CL around the mean: z of alpha / 2 = +-1.65

Margin of Error (ME) = critical z-value * sigma of xbar

E.g. we sample 30 cereals find 29g is sample mean (xbar) and 8.74g is
population standard deviation (sigma).  At 95% CL:
Standard error = 8.74/sqrt(30) = 1.5957  # you can lower it, and ME, by increasing sample size from 30
Lower limit ME = 29 - 1.96(1.5957) = 25.87
Upper limit ME = 29 + 1.96(1.5957) = 32.13
ME = 25.87-29 and 29-32.13 = 3.13

so confidence interval is:

  |        3.13           |           3.13           |
  |-----------------------|--------------------------|
 25.87                    29                        32.13
 xbar-ME                 xbar                       xbar+ME
 (-2 sigma)                                        (+2 sigma)

Most of samples like this one align under the centerline of the bell curve.  If any part of the
dashed line isn't under the bell curve's centerline (doesn't contain mu), it is part of one of the
tails


Determine appropriate sample size for the population mean:
E.g. we want 95% CI that has ME +-3g when sigma is 8.74g:
n = (1.96^2 * 8.74^2) / 3^2 = 33
so a CI 29-3=26 thru 29+3=32 requires a sample size of 33 cereals
