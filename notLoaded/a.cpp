#include <cmath>
#include <vector>

#include <iostream>
#include <string>
#include <sstream>

typedef struct {
        double x_0;
        double x_25;
        double x_50;
        double x_75;
        double x_100;
        double k_1;
        double k_2;
        double k_3;
        double k_4;
        double x;
        double bounty;
        double weight;
} UtilityCurve ;

typedef struct {
    double left; 
    double right;
} PairOfDoubles ;

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

double CDF( const UtilityCurve & uc
          , const double         x
          )
{
    /*
    A Cumulative Distribution Function.
    Function is bound by [x_0, x_100]
    x_50 is the midpoint, k_1 through k_4 are transforming 
    variables.
    x will be a value on [0.0, 1.0]
    */
    if      ( x < uc.x_0   ) { return 0.0; }
    else if ( x > uc.x_100 ) { return 1.0; }
    return uc.k_3 / (1 + (uc.k_1 * exp(-uc.k_2 * (x - uc.x_50)))) + uc.k_4;
}

double CDF_prime( const UtilityCurve & uc
                , const double         x
                )
{
    /*
    the first derivative of a CDF function (margin)
    */
    if      ( x < uc.x_0   ) { return 0.0; }
    else if ( x > uc.x_100 ) { return 0.0; }

    double numerator =  uc.k_1 * uc.k_2 * uc.k_3 * exp(uc.k_2 * (x - uc.x_50));
    double denominator = pow((uc.k_1 + exp(uc.k_2 * (x - uc.x_50))), 2);
    return numerator / denominator;
}

double CDF_prime_prime( const UtilityCurve & uc
                      , const double         x
                      )
{
    /*
    the second derivative of a CDF function (growth)
    */
    if      ( x < uc.x_0   ) { return 0.0; }
    else if ( x > uc.x_100 ) { return 0.0; }

    double num_0 = 2 * pow(uc.k_1, 2) * pow(uc.k_2, 2) * exp(-2 * uc.k_2 * (x - uc.x_50));
    double den_0 = pow((1 + uc.k_1 * exp(-uc.k_2 * (x - uc.x_50))), 3);
    double num_1 = uc.k_1 * pow(uc.k_2, 2) * exp(-uc.k_2 * (x - uc.x_50));
    double den_1 = pow((1 + (uc.k_1 * exp(-uc.k_2 * (x - uc.x_50)))), 2);
    double v_0 = num_0 / den_0;
    double v_1 = num_1 / den_1;

    return uc.k_3 * (v_0 - v_1);
}

double calcError(const UtilityCurve & uc)
{
    /*
    Calculate the error of a Cumulative Distribution Function from 
    given x-points and k-transformers.
    Returns the square root of the sum of the distances from CDF
    to the x-points.
    */
    double error = 0.0;

    error += std::abs(CDF(uc,   uc.x_0) - 0.00);
    error += std::abs(CDF(uc,  uc.x_25) - 0.25);
    error += std::abs(CDF(uc,  uc.x_50) - 0.50);
    error += std::abs(CDF(uc,  uc.x_75) - 0.75);
    error += std::abs(CDF(uc, uc.x_100) - 1.00);

    return sqrt(error);
}

double calcK2( const double x_25
             , const double x_50
             , const double x_75
             , const double k_1
             )
{
    /*
    Calculate k_2 value, given a k_1, and x-points.
    This takes the average of the inner-most x-points, in order
    to make a more smooth CDF.
    */
    if (k_1 <= 0.0) { return 0.0; }

    double k_2_1 = -log(k_1/3) / (x_75 - x_50);
    double k_2_2 = -log(k_1/3) / (x_50 - x_25);
    double k_2   = (k_2_1 + k_2_2) / 2;
    return k_2;
}

PairOfDoubles calcK3_4( const double x_0
                      , const double x_50
                      , const double x_100
                      , const double k_1
                      , const double k_2
                      )
{
    /*
    This adjusts the ends so that they meet at the proper 
    utility value at end points.
    */
    double dnom_0 = 1 + (k_1 * exp(-k_2 * (x_0   - x_50)));
    double dnom_1 = 1 + (k_1 * exp(-k_2 * (x_100 - x_50)));
    
    if (dnom_0-dnom_1 == 0) { return (PairOfDoubles) {0.0, 0.0}; }
    double k_3 = (dnom_1 * dnom_0) / (dnom_0 - dnom_1);
    double k_4 = (-k_3) / dnom_0;

    return (PairOfDoubles) {k_3, k_4};
}


UtilityCurve GenerateCDF( const double x_0
                        , const double x_25
                        , const double x_50
                        , const double x_75
                        , const double x_100
                        )
{
    /*
    Find the parameters for a CDF, using an iterative method.
    This function finds a fit for the given x-points.
    It returns the  first seven arguments to CDF as a tuple.

    In general the CDF we are building is this:

    CDF(x) = k_3 / (1 + (k_1 * e ** (-k_2 * (x - x_50)))) + k_4


                           k_3
    CDF(x) = -------------------------------- + k_4
                          -k_2 * (x - x_50)
               1 + k_1 * e 

    */

    const int ITERATIONS = 13;
    /*
    ITERATIONS is a fail-safe, for how many iterations should be done 
    if an steady error cannot be approached.
    */

    // forward declarations of accumulators
    double k_1     = 1.0;
    double k_1_d   = k_1;

    double k_2 = calcK2(x_25, x_50, x_75, k_1);

    double k_1_ret = k_1;
    double k_2_ret = k_2;

    double k_3 = 1.0;
    double k_4 = 0.0;

    // A UtilityCurve that can be used to Calculate errors
    UtilityCurve  trialCurve;
    trialCurve.x_0    = x_0;
    trialCurve.x_25   = x_25;
    trialCurve.x_50   = x_50;
    trialCurve.x_75   = x_75;
    trialCurve.x_100  = x_100;
    trialCurve.k_1    = k_1;
    trialCurve.k_2    = k_2;
    trialCurve.k_3    = k_3;
    trialCurve.k_4    = k_4;
    trialCurve.x      = 0.0;
    trialCurve.bounty = 1.0;
    trialCurve.weight = 1.0;

    double error = calcError(trialCurve);

    // forward declarations of loop variables
    PairOfDoubles retVal;
    double k_1_low;
    double k_2_low;
    double k_3_low;
    double k_4_low;
    double error_low;

    double k_1_high;
    double k_2_high;
    double k_3_high;
    double k_4_high;
    double error_high;

    double error_old;

    int ii = 0;
    while (ii < ITERATIONS)
    {
        k_1_low          = k_1 - k_1_d;
        k_2_low          = calcK2(x_25, x_50, x_75, k_1_low);
        retVal           = calcK3_4(x_0, x_50, x_100, k_1_low, k_2_low); 
        k_3_low          = retVal.left;
        k_4_low          = retVal.right;
        trialCurve.k_1   = k_1_low;
        trialCurve.k_2   = k_2_low;
        trialCurve.k_3   = k_3_low;
        trialCurve.k_4   = k_4_low;
        error_low        = calcError(trialCurve);

        k_1_high         = k_1 + k_1_d;
        k_2_high         = calcK2(x_25, x_50, x_75, k_1_high);
        retVal           = calcK3_4(x_0, x_50, x_100, k_1_high, k_2_high);
        k_3_high          = retVal.left;
        k_4_high          = retVal.right;
        trialCurve.k_1   = k_1_high;
        trialCurve.k_2   = k_2_high;
        trialCurve.k_3   = k_3_high;
        trialCurve.k_4   = k_4_high;
        error_high       = calcError(trialCurve);

        error_old = error;

        if (error_high > error_low)
        {
            error = error_low;
            k_1   = k_1_low;
            k_2   = k_2_low;
            k_3   = k_3_low;
            k_4   = k_4_low;
            ii = 0;
        }

        else if (error_low > error_high)
        {
            error = error_high;
            k_1   = k_1_high;
            k_2   = k_2_high;
            k_3   = k_3_high;
            k_4   = k_4_high;
            ii = 0;
        }

        if (error_old == error) { break; }

        k_1_d = k_1_d / 2;
        ii += 1;

    }

    
    trialCurve.x_0          = x_0;
    trialCurve.x_25         = x_25;
    trialCurve.x_50         = x_50;
    trialCurve.x_75         = x_75;
    trialCurve.x_100        = x_100;
    trialCurve.k_1          = k_1;
    trialCurve.k_2          = k_2;
    trialCurve.k_3          = k_3;
    trialCurve.k_4          = k_4;
    trialCurve.x            = 0.0;
    trialCurve.bounty       = 1.0;
    trialCurve.weight       = 1.0;
    return trialCurve;

}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

std::string CDFToString(const UtilityCurve & uc)
{
    std::stringstream retVal;
    retVal << "{"
        << " x_0:"    << uc.x_0
        << " x_25:"   << uc.x_25
        << " x_50:"   << uc.x_50
        << " x_75:"   << uc.x_75
        << " x_100:"  << uc.x_100
        << " k_1:"    << uc.k_1
        << " k_2:"    << uc.k_2
        << " k_3:"    << uc.k_3
        << " k_4:"    << uc.k_4
        << " x:"      << uc.x
        << " bounty:" << uc.bounty
        << " weight:" << uc.weight
        << "}";
    return retVal.str();
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

UtilityCurve makeUtilityCurve( const double x_0
                             , const double x_25
                             , const double x_50
                             , const double x_75
                             , const double x_100
                             , const double weight
                             , const double bounty
                             , const double progression
                             )
{
    UtilityCurve retVal = GenerateCDF(x_0, x_25, x_50, x_75, x_100);
    retVal.weight = weight;
    retVal.bounty = bounty;
    retVal.x      = progression;
    return retVal;
}

double Utility(const UtilityCurve & uc)           { return CDF(uc, uc.x) * uc.weight * uc.bounty; }
double Utility(const UtilityCurve & uc, double x) { return CDF(uc, x) * uc.weight * uc.bounty; }

double MarginalUtility(const UtilityCurve & uc)           { return CDF_prime(uc, uc.x) * uc.weight * uc.bounty; }
double MarginalUtility(const UtilityCurve & uc, double x) { return CDF_prime(uc, x)    * uc.weight * uc.bounty; }

double UtilityGrowth(const UtilityCurve & uc)             { return CDF_prime_prime(uc, uc.x) * uc.weight * uc.bounty; }
double UtilityGrowth(const UtilityCurve & uc, double x)   { return CDF_prime_prime(uc, x)    * uc.weight * uc.bounty; }

double GetDiminishingMarginalPoint( const UtilityCurve & uc
                                  , const double         basemargin
                                  )
{
    /*
    Given a constant margin (basemargin) as input,
    This function returns the value x would be, where the margin 
    of this UtilityCurve would fall below that basemargin.
    This function fully recacluates DMP every call.
    */
    double TOLERENCE = 1e-9;
    double start     = uc.x_50;
    double end       = uc.x_100;

    if (MarginalUtility(uc, end) > basemargin) { return end; }

    double half;
    double halfmargin;
    for (int i = 0; i < 13; ++i)
    {
        half = (start + end) / 2.0;
        halfmargin = MarginalUtility(uc, half);
        if (std::abs(halfmargin - basemargin) < TOLERENCE) { return half; }
        else if (halfmargin > basemargin) { start = half; }
        else if (halfmargin < basemargin) { end = half; }
    }
    return start;
}

double GetAscendingIndifferencePoint( const UtilityCurve & uc
                                    , const double         basemargin
                                    )
{
    /*
    Given a constant margin (basemargin) as input,
    This function returns the value x would be, where the Utility
    of this UtilityCurve would raise above the integration of that
    basemargin (baseutil), assuming that baseutil starts at 0.
    within the optional tolerence argument.
    This function fully recacluates DMP every call.
    This function fully recacluates AIP every call.
    */
    double TOLERENCE = 1e-9;
    double start = uc.x_0;
    double end   = GetDiminishingMarginalPoint(uc, basemargin);

    double half;
    double halfutil;
    double baseutil;
    for (int i = 0; i < 13; ++i)
    {
        half = (start + end) / 2.0;
        halfutil = Utility(uc, half);
        baseutil = half * basemargin;
        if (std::abs(halfutil - baseutil) < TOLERENCE) { return half; }
        else if (halfutil < baseutil) { start = half; }
        else if (halfutil > baseutil) { end   = half; }
    }
    return start;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

std::vector<std::vector<double> > combineAngles( 
        const std::vector<std::vector<double> > & xs
      , const std::vector<double> & ys
      )
{
    //Create all the combinations of angles from the current lists, and
    //the input list.
    //xs : [[angles]]
    //ys :  [angles]

    std::vector<std::vector<double> > result;
    for (int x=0; x<xs.size(); ++x)
    {
        for (int y=0; y<ys.size(); ++y)
        {
            std::vector<double> newPoints = xs[x];
            newPoints.push_back(ys[y]);
            result.push_back(newPoints);
        }
    }
    return result;
}


std::vector<double> convertHyperSperetoCoordinates(
                                        const double                radius
                                      , const std::vector<double> & thetaPairs)
{
    /*
    a = r * sin(theta_1)
    b = r * cos(theta_1) * sin(theta_2)
    c = r * cos(theta_1) * cos(theta_2) * sin(theta_3)
    d = r * cos(theta_1) * cos(theta_2) * cos(theta_3) * sin(theta_4)
    e = r * cos(theta_1) * cos(theta_2) * cos(theta_3) * cos(theta_4)

    Note here: 4 angles makes 5 points.
    */
    std::vector<double> points;
    for (int _unused_ = 0; _unused_ <= thetaPairs.size(); ++_unused_)
    {
        points.push_back(radius);
    }

    for (int ii=0; ii<thetaPairs.size(); ++ii)
    {
        points[ii] *= sin(thetaPairs[ii]); 
        for (int jj=ii+1; jj<points.size(); ++jj)
        {
            points[jj] *= cos(thetaPairs[ii]);
        }
    }

    return points;

}

std::vector<double> 
getMSR_ND_hyperShpere_prime( const std::vector<UtilityCurve> & uc_s
                           , const double                      radius
                           , const int                         N
                           , const std::vector<double>       & centerThetas
                           , const bool                        resultInTheta
                           , const double                      thetaRange
                           ){
    //if not centerThetas: centerThetas = [(pi/4.0) for _ in uc_s[1:]]
    double                            thetaStep = thetaRange / N;
    std::vector<std::vector<double> > thetas;
    std::vector<std::vector<double> > thetaPairs;

    double              value;
    double              maxValue = -1;
    std::vector<double> points;
    std::vector<double> bestPoints;
    std::vector<double> bestThetas;

    for (int ii = 0; ii < centerThetas.size(); ++ii)
    {
        std::vector<double> theta;
        for (int jj = 0; jj <= N; ++jj)
        {
            double step = (thetaStep * (jj - (N/2)));
            theta.push_back(centerThetas[ii] + step);
            if(ii==0) 
            {
                std::vector<double> transposer;
                transposer.push_back(centerThetas[ii] + step);
                thetaPairs.push_back(transposer); //add first one to thetaPairs
            }
        }
        thetas.push_back(theta);
    }

    // for every UtilityCurve after the first, add thetas for combinations
    // N UtilityCurves require N-1 angles to describe. also, the first
    // one has already been done.
    for(int ii=1; ii<thetas.size(); ++ii)
    {
        thetaPairs = combineAngles(thetaPairs, thetas[ii]);
    }

    //get the Best Cartesian points for Maximum Utility value
    for(int ii=0; ii<thetaPairs.size(); ++ii)
    {
        value = 0.0;
        points = convertHyperSperetoCoordinates(radius, thetaPairs[ii]);
        for (int jj=0; jj<points.size(); ++jj)
        {
            value += Utility(uc_s[jj], points[jj]);
        }
        if (value > maxValue) 
        {
            maxValue   = value;
            bestPoints = points;
            bestThetas = thetaPairs[ii];
        }
        
    }
   
    if (resultInTheta) return bestThetas;
    return bestPoints;
}

std::vector<double> getMSR_ND_hyperShpere( const std::vector<UtilityCurve> & uc_s
                                         , const double                      radius
                                         , const int                         N
                                         , const double                      minStep
                                         )
{
    /*
    Use a hypsersphere to find the optional progression values
    for the input Utility Curves (uc_s) for a given amount of 
    effort (radius) over N evenly spaced test points.
    uc_s    : The Utility Curves that are to be optimized.
    radius  : The effort (distance from the origin, also radius of the
              hypsersphere) to test the Utility Curves.
    N       : The number of angles to test the hypsersphere at.
    minStep : The minimum theta range to check.

    Keep in mind the complexity of this function is along O(N^|uc_s|).
    */

    double               thetaRange = M_PI / 2.0;
    std::vector<double>  thetas; 
    for(int ii = 1; ii < uc_s.size(); ++ii)
    {
        thetas.push_back(M_PI/4.0);
    }

    while(thetaRange > minStep)
    {
        thetas = getMSR_ND_hyperShpere_prime( uc_s, radius, N, thetas
                                            , true, thetaRange );
        thetaRange = 2 * thetaRange / N;

        /*
         *std::cout << radius << std::endl;
         *for(int ii = 0; ii < thetas.size(); ++ii) 
         *    std::cout << thetas[ii]-thetaRange  << " "
         *              << thetas[ii]  << " "
         *              << thetaRange+thetas[ii]  << " "
         *              << std::endl;
         *std::cout << std::endl << std::endl;;
         */
        
    }

    return convertHyperSperetoCoordinates(radius, thetas);
}

std::vector<std::vector<double> > getMSR_ND(
                                    const std::vector<UtilityCurve> & uc_s
                                  , const int                         N
                                  , const double                      MINSTEP=1e-12
                                  , const int                         DIVISIONS=13
                                  )
{
    /*
    get the MSR curve for an N-dimensional option set, represented by
    the Utility Curves (uc_s).  The result will be the optimized progression
    for the Utility Curves for a given effort, not the sequence that should
    be followed.

    Keep in mind the complexity of this function is along O(N^(|uc_s|+1)).
    */

    std::vector<std::vector<double> > points;
    double radiusStep;
    double radiusMin = 0.0;
    double radiusMax = 0.0;
    for (int ii=0; ii < uc_s.size(); ++ii)
    {
        radiusMax += pow(uc_s[ii].x_100, 2);
    }
    radiusMax = sqrt(radiusMax);
    radiusStep = (radiusMax - radiusMin) / N;

    for (double radii=radiusMin; radii<=radiusMax; radii += radiusStep)
    {
        points.push_back(getMSR_ND_hyperShpere(uc_s, radii, DIVISIONS, MINSTEP));
    }
    
    return points;
}

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

bool ANALYSIS = false;
int main(int argc, char** argv)
{
    UtilityCurve uc_1 = makeUtilityCurve( 0, 7,10,13,20, 1.0, 100.0, 0);
    UtilityCurve uc_2 = makeUtilityCurve( 0, 9,11,15,20, 1.0, 100.0, 0);
    UtilityCurve uc_3 = makeUtilityCurve( 0, 3, 5,10,20, 1.0, 100.0, 0);
    UtilityCurve uc_4 = makeUtilityCurve( 0, 7, 9,12,20, 1.0, 100.0, 0);
    UtilityCurve uc_5 = makeUtilityCurve( 0,10,13,15,20, 1.0, 100.0, 0);

    //uc_1.weight = 0.3;
    //uc_2.weight = 0.5;
    //uc_2.weight = 0.2;

    std::vector<std::vector<double> > msrCurve;
    std::vector<UtilityCurve> uc_s;
    uc_s.push_back(uc_1);
    uc_s.push_back(uc_2);
    uc_s.push_back(uc_3);
    uc_s.push_back(uc_4);
    uc_s.push_back(uc_5);

    double realEffort;
    double totalUtil;

    msrCurve = getMSR_ND(uc_s, 100);
    for (double i=0; i < msrCurve.size(); ++i)
    {
        realEffort = 0.0;
        totalUtil  = 0.0;
        for(int j=0; j < msrCurve[i].size(); ++j)
        {
            std::cout << msrCurve[i][j] << '\t';
            realEffort += msrCurve[i][j];
            totalUtil  += Utility(uc_s[j], msrCurve[i][j]);
        }
        if (ANALYSIS) std::cout << realEffort << "\t" << totalUtil;
        std::cout << std::endl;
    }

    return 0;
}

