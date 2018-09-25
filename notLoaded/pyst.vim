from math import e, log, sqrt
from ast import literal_eval

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class UtilityCurveFunction():
    """
    A function-object wrapper for GenerateCDFConstructor(...)
    """
    def __init__(self, x_0, x_25, x_50, x_75, x_100):
        ( self.x_0 , self.x_50 , self.x_100 , self.k_1 , self.k_2 , self.k_3, 
            self.k_4 ) = GenerateCDFConstructor(x_0, x_25, x_50, x_75, x_100)

    def __call__(self, x):
        return CDF(self.x_0, self.x_50, self.x_100, self.k_1, 
                   self.k_2, self.k_3, self.k_4, x)


#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class UtilityCurve(UtilityCurveFunction):
    """
    UtilityCurve is the Utility Curve representation that will be used.
    Although the underlying Utility Function can be called
    directly, it's preferred that value(deltaX) be called, and that when 
    arbitration is final that the progressByDeltaX(...) is used to advance
    the progression along the Utility Curve.
    """
    def __init__( self, x_0, x_25, x_50, x_75, x_100
                , calculate=True
                , weight=1.0
                , bounty=1.0
                ):
        """
        Initialize UtilityCurve.
        calculate may be set to false to bypass CDF generation,
        in which case x-points arguments are ignored and k-points are 
        not calculated.  They must be set before use, but this can
        be used to prevent recalculating UtilityCurveFunction at runtime.
        """
        if calculate:
            UtilityCurveFunction.__init__(self, x_0, x_25, x_50, x_75, x_100)
        self.x = 0.0
        self.bounty = bounty
        self.weight = weight
        self.previousBaseMargin = False
        self.aip = False
        self.dmp = False
        self.inflectionP = False

    def reset(self):
        """
        Set progression to 0.0
        """
        self.x = 0.0
        return self

    def setBounty(self, bounty):
        self.bounty = bounty
        return self

    def setWeight(self, weight):
        self.weight = weight
        return self

    def setPoints(self, x_0, x_50, x_100, k_1, k_2, k_3, k_4, x):
        """
        Bypass the recalculating of UtilityCurveFunction, and set
        the values yourself.
        """
        self.x_0   = x_0
        self.x_50  = x_50
        self.x_100 = x_100
        self.k_1   = k_1
        self.k_2   = k_2
        self.k_3   = k_3
        self.k_4   = k_4
        self.x     = x
        return self

    def setPointsFromDict(self, inDict):
        return self.setPoints( inDict['x_0'], inDict['x_50'], inDict['x_100']
                             , inDict['k_1'], inDict['k_2'], inDict['k_3']
                             , inDict['k_4'], inDict['x'] )

    def setPointsFromStr(self, inputDictStr):
        inDict = literal_eval(inputDictStr)
        return self.setPointsFromDict(inDict)
    
    def progressByDeltaX(self, deltaX):
        """
        Advance the progression along Utility Curve by deltaX
        """
        self.x += deltaX
        return self

    def marginalValue(self, deltaX=0.0, fromOrigin=False):
        """
        Returns Marginal Utility of deltaX, with respect to 
        the current progression
        affected by weight, and bounty
        """
        if fromOrigin: x_value = deltaX
        else         : x_value = self.x + deltaX

        return CDF_prime(self.x_0, self.x_50, self.x_100, self.k_1, self.k_2, 
                self.k_3, self.k_4, x_value) * self.weight * self.bounty

    def value(self, deltaX=0.0, fromOrigin=False):
        """
        Returns value of UtilityCurve at current progression, or 
        at current progression + deltaX
        affected by weight, and bounty
        """
        if fromOrigin: x_value = deltaX
        else         : x_value = self.x + deltaX

        return CDF(self.x_0, self.x_50, self.x_100, self.k_1, self.k_2, 
                self.k_3, self.k_4, x_value) * self.weight * self.bounty

    def raw_utility(self, x):
        """
        Returns Utility at x
        """
        return CDF(self.x_0, self.x_50, self.x_100, self.k_1, self.k_2, 
                self.k_3, self.k_4, x)

    def raw_margin(self, x):
        """
        Returns first derivative (Martin) at x
        """
        return CDF_prime(self.x_0, self.x_50, self.x_100, self.k_1, self.k_2, 
                self.k_3, self.k_4, x)

    def raw_growth(self, x):
        """
        Returns second derivative (Growth) at x
        """
        return CDF_prime_prime(self.x_0, self.x_50, self.x_100, self.k_1, 
                self.k_2, self.k_3, self.k_4, x)

    def getDiminishingMarginalPoint(self, basemargin, tolerence=0.0001):
        """
        Given a constant margin (basemargin) as input,
        This function returns the value x would be, where the margin 
        of this UtilityCurve would fall below that basemargin
        within the optional tolerence argument.
        This function fully recacluates DMP every call.
        """
        start = self.x_50
        end   = self.x_100
        if self.marginalValue(end, fromOrigin=True) > basemargin: return end
        for _ in xrange(13):
            half = (start + end) / 2.0
            halfmargin = self.marginalValue(half, fromOrigin=True)
            if   abs(halfmargin - basemargin) < tolerence: return half
            elif halfmargin > basemargin: start = half
            elif halfmargin < basemargin: end = half
        return start

    def getAscendingIndifferencePoint(self, basemargin, tolerence=0.0001):
        """
        Given a constant margin (basemargin) as input,
        This function returns the value x would be, where the Utility
        of this UtilityCurve would raise above the integration of that
        basemargin (baseutil), assuming that baseutil starts at 0.
        within the optional tolerence argument.
        This function fully recacluates DMP every call.
        This function fully recacluates AIP every call.
        """
        start = self.x_0
        end   = self.getDiminishingMarginalPoint(basemargin)
        for _ in xrange(13):
            half = (start + end) / 2.0
            halfutil = self.value(half, fromOrigin=True)
            baseutil = half * basemargin
            if   abs(halfutil - baseutil) < tolerence: return half
            elif halfutil < baseutil: start = half
            elif halfutil > baseutil: end   = half
        return start

    def isRiskSeaking(self, basemargin, tolerence=0.0001):
        """
        Given a constant margin (basemargin) as input,
        This method returns True if the UtilityCurve progression
        has not yet exceeded the Acending Indifference Point, and therefore
        we should be risk seaking.
        This method caches AIP.
        """
        # do we need to calculate AIP?
        if (    not self.previousBaseMargin  
             or not self.aip 
             or self.previousBaseMargin != basemargin ):
            self.aip = self.getAscendingIndifferencePoint(basemargin, tolerence)
        return self.x <= self.aip

    def isWorthwhile(self,basemargin,tolerence=0.0001):
        """
        Given a constant margin (basemargin) as input,
        This method returns True if the UtilityCurve value at the 
        Diminishing Marginal Point is greater than the integration of 
        the basemargin (baseutil), assuming that baseutil starts at 0.
        This method caches DMP.
        """
        # do we need to calculating dmp?
        if (    not self.previousBaseMargin  
             or not self.dmp 
             or self.previousBaseMargin != basemargin ):
            self.dmp = self.getDiminishingMarginalPoint(basemargin, tolerence)
        return self.value(self.dmp, fromOrigin=True) > basemargin * self.dmp

    def shouldExecute(self, basemargin, deltaX, tolerence=0.0001):
        """
        Given a constant margin (basemargin) as input,
        This method returns True if the UtilityCurve is 
        Worthwhile  and Risk Seaking.
        This method caches DMP.
        """
        return (   self.isWorthwhile(basemargin, tolerence) 
               and self.x + deltaX < self.dmp ) 

    def getInflectionPoint(self, tolerence=0.0001, maxIterations=27):
        """
        Return the inflection point where the Utility Curve goes from
        concave up, to concave down.
        This method caches inflectionP.
        """
        if self.inflectionP: return self.inflectionP
        start = self.x_0
        end   = self.x_100  
        for _ in range(maxIterations):
            half  = (start + end) / 2.0
            halfgrowth = self.raw_growth(half)
            if  abs(halfgrowth) < tolerence:
                self.inflectionP = half
                return half
            elif halfgrowth > 0: start = half
            elif halfgrowth < 0: end   = half
        return half

    def getValuePoint(self, value, tolerence=0.0001, maxIterations=27):
        """
        Get the point where the UtilityCurve has a given value.
        The value must be beyond the inflection point.
        This method caches inflectionP.
        """
        start = self.getInflectionPoint()
        end   = self.x_100  
        for _ in xrange(13):
            half = (start + end) / 2.0
            halfutil = self.value(half, fromOrigin=True)
            if   abs(halfutil - value) < tolerence: return half
            elif halfutil < value: start = half
            elif halfutil > value: end   = half
        return start
    
    def getIndifferenceCurve(self, uc_2, value):
        def x2InTermsOfx1(x_1):
            return log( (( ((value - self.k_4 - uc_2.k_4 - (self.k_3 / (1 + self.k_1 * e ** (self.k_2 * (x_1 - self.x_50))))) - 1) / uc_2.k_3 ) - 1 ) / uc_2.k_1 ) / uc_2.k_2 + uc_2.x_50
        return x2InTermsOfx1



    def getDict(self):
        return dict([ ('x_0'  , self.x_0),   ('x_50' , self.x_50)
                    , ('x_100', self.x_100), ('k_1'  , self.k_1 )
                    , ('k_2'  , self.k_2 ),  ('k_3'  , self.k_3 )
                    , ('k_4'  , self.k_4 ),  ('x'    , self.x) ])

    def __repr__(self):
            return str(self.getDict())
                       
                       
                       



#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

def CDF(x_0, x_50, x_100, k_1, k_2, k_3, k_4, x):
    """
    A Cumulative Distribution Function.
    Function is bound by [x_0, x_100]
    x_50 is the midpoint, k_1 through k_4 are transforming 
    variables.
    x will be a value on [0.0, 1.0]
    """
    if   x < x_0  : return 0.0
    elif x > x_100: return 1.0
    return k_3 / (1 + (k_1 * e ** (-k_2 * (x - x_50)))) + k_4

def CDF_prime(x_0, x_50, x_100, k_1, k_2, k_3, k_4, x):
    """
    the first derivative of a CDF function (margin)
    """
    if   x < x_0  : return 0.0
    elif x > x_100: return 0.0
    numerator =  k_1 * k_2 * k_3 * e ** (k_2 * (x - x_50))
    denominator = (k_1 + e ** (k_2 * (x - x_50))) ** 2
    return numerator / denominator

def CDF_prime_prime(x_0, x_50, x_100, k_1, k_2, k_3, k_4, x):
    """
    the second derivative of a CDF function (growth)
    """
    if   x < x_0  : return 0.0
    elif x > x_100: return 0.0
    num_0 = 2 * k_1 ** 2 * k_2 ** 2 * e ** (-2 * k_2 * (x - x_50))
    den_0 = (1 + k_1 * e ** (-k_2 * (x - x_50))) ** 3
    num_1 = k_1 * k_2 ** 2 * e ** (-k_2 * (x - x_50))
    den_1 = (1 + (k_1 * e ** (-k_2 * (x - x_50)))) ** 2
    v_0 = num_0 / den_0
    v_1 = num_1 / den_1
    return k_3 * (v_0 - v_1)

def calcError(x_0, x_25, x_50, x_75, x_100, k_1, k_2, k_3, k_4):
    """
    Calculate the error of a Cumulative Distribution Function from 
    given x-points and k-transformers.
    Returns the square root of the sum of the distances from CDF
    to the x-points.
    """
    error = sqrt( sum( map( lambda (x,y) : abs(x-y)
        , zip( map( lambda x: CDF(x_0, x_50, x_100, k_1, k_2, k_3, k_4, x)
                , [x_0, x_25, x_50, x_75, x_100] )
                , [0.0, 0.25, 0.50, 0.75, 1.0] ))))
    return error

def calcK2(x_25, x_50, x_75, k_1):
    """
    Calculate k_2 value, given a k_1, and x-points.
    This takes the average of the inner-most x-points, in order
    to make a more smooth CDF.
    """
    if k_1 <=0: return 0
    k_2_1 = -log(k_1/3) / (x_75 - x_50)
    k_2_2 = -log(k_1/3) / (x_50 - x_25)
    k_2   = (k_2_1 + k_2_2) / 2
    return k_2

def calcK3_4(x_0, x_50, x_100, k_1, k_2):
    """
    This adjusts the ends so that they meet at the proper 
    utility value at end points.
    """
    dnom_0 = 1 + (k_1 * e ** (-k_2 * (x_0   - x_50)))
    dnom_1 = 1 + (k_1 * e ** (-k_2 * (x_100 - x_50)))
    
    if dnom_0-dnom_1 == 0: return 0.0, 0.0
    k_3 = (dnom_1 * dnom_0) / (dnom_0 - dnom_1)
    k_4 = (-k_3) / dnom_0

    return k_3, k_4


def GenerateCDFConstructor(x_0, x_25, x_50, x_75, x_100, iterations=13):
    """
    Find the parameters for a CDF, using an iterative method.
    This function finds a fit for the given x-points.
    It returns the  first seven arguments to CDF as a tuple.

    In general the CDF we are building is this:

    CDF(x) = k_3 / (1 + (k_1 * e ** (-k_2 * (x - x_50)))) + k_4


                           k_3
    CDF(x) = -------------------------------- + k_4
                          -k_2 * (x - x_50)
               1 + k_1 * e 

    iterations is a fail-safe, for how many iterations should be done 
    if an steady error cannot be approached.
    """
    k_1     = 1.0
    k_1_d   = k_1

    k_2 = calcK2(x_25, x_50, x_75, k_1)

    k_1_ret = k_1
    k_2_ret = k_2

    k_3 = 1.0
    k_4 = 0.0

    error = calcError(x_0, x_25, x_50, x_75, x_100, k_1, k_2, k_3, k_4)

    ii, jj = 0, 0
    while ii < iterations:
        k_1_low          = k_1 - k_1_d
        k_2_low          = calcK2(x_25, x_50, x_75, k_1_low)
        k_3_low, k_4_low = calcK3_4(x_0, x_50, x_100, k_1_low, k_2_low)
        error_low        = calcError( x_0, x_25, x_50, x_75, x_100
                                    , k_1_low, k_2_low, k_3_low, k_4_low)

        k_1_high           = k_1 + k_1_d
        k_2_high           = calcK2(x_25, x_50, x_75, k_1_high)
        k_3_high, k_4_high = calcK3_4(x_0, x_50, x_100, k_1_high, k_2_high)
        error_high         = calcError( x_0, x_25, x_50, x_75, x_100 
                                      , k_1_high, k_2_high, k_3_high, k_4_high)


        error_old = error

        if error_high > error_low:
            error = error_low
            k_1   = k_1_low
            k_2   = k_2_low
            k_3   = k_3_low
            k_4   = k_4_low
            ii = 0
        elif error_low > error_high:
            error = error_high
            k_1   = k_1_high
            k_2   = k_2_high
            k_3   = k_3_high
            k_4   = k_4_high
            ii = 0

        if error_old == error : break

        k_1_d = k_1_d / 2
        ii += 1
        jj += 1


    return (x_0, x_50, x_100, k_1, k_2, k_3, k_4)

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

