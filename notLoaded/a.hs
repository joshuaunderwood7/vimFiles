module Pannomion where
import Data.List

data UtilityCurve = UtilityCurve { x_0        :: Double 
                                 , x_25       :: Double 
                                 , x_50       :: Double 
                                 , x_75       :: Double 
                                 , x_100      :: Double 
                                 , k_1        :: Double 
                                 , k_2        :: Double 
                                 , k_3        :: Double 
                                 , k_4        :: Double 
                                 , x_progress :: Double 
                                 , bounty     :: Double 
                                 , weight     :: Double 
                                 } deriving (Show)


--  A Cumulative Distribution Function.
--  Function is bound by [x_0, x_100]
--  x_50 is the midpoint, k_1 through k_4 are transforming 
--  variables.
--  x will be a value on [0.0, 1.0]
cdf :: UtilityCurve -> Double -> Double
cdf uc x 
   | x < (  x_0 uc) = 0.0
   | x > (x_100 uc) = 1.0
   | otherwise      = k4 + (nummerator / denominator)
      where k1  =  k_1 uc
            k2  =  k_2 uc
            k3  =  k_3 uc
            k4  =  k_4 uc
            x50 = x_50 uc
            ex  = exp $ -k2 * (x - x50)
            nummerator  = k3
            denominator = 1 + ex


--  the first derivative of a CDF function (margin)
cdf' :: UtilityCurve -> Double -> Double
cdf' uc x 
   | x < (  x_0 uc) = 0.0
   | x > (x_100 uc) = 1.0
   | otherwise      = numerator / denominator
      where k1      =  k_1 uc
            k2      =  k_2 uc
            k3      =  k_3 uc
            k4      =  k_4 uc
            x50     = x_50 uc
            x_dif   = x - x50
            numerator   =  k1 * k2 * k3 * exp(k2 * x_dif);
            denominator = (k1 + exp(k2 * x_dif))^2;
           


--  the second derivative of a CDF function (growth)
cdf'' :: UtilityCurve -> Double -> Double
cdf'' uc x 
   | x < (  x_0 uc) = 0.0
   | x > (x_100 uc) = 1.0
   | otherwise      = k3 * (v_0 - v_1)
      where k1    =  k_1 uc
            k2    =  k_2 uc
            k3    =  k_3 uc
            k4    =  k_4 uc
            x50   = x_50 uc
            x_dif = x - x50
            exk2d = exp((-k2) * x_dif)
            num_0 = 2 * k1^2 * k2^2 * exp((-2) * k2 * x_dif)
            den_0 =   (1 + k1 * exk2d )^3 
            num_1 = k1 * k2^2 * exk2d
            den_1 =   (1 + k1 * exk2d )^2
            v_0   = num_0 / den_0;
            v_1   = num_1 / den_1;


    
--  Calculate the error of a Cumulative Distribution Function from 
--  given x-points and k-transformers.
--  Returns the square root of the sum of the distances from CDF
--  to the x-points.
--  calcError :: UtilityCurve -> Double
calcError uc = (sqrt . sum) [ abs (cdf uc (  x_0 uc) - 0.00)
                            , abs (cdf uc ( x_25 uc) - 0.25)
                            , abs (cdf uc ( x_50 uc) - 0.50)
                            , abs (cdf uc ( x_75 uc) - 0.75)
                            , abs (cdf uc (x_100 uc) - 1.00)
                            ]


--  Calculate k_2 value, given a k_1, and x-points.
--  This takes the average of the inner-most x-points, in order
--  to make a more smooth CDF.
calcK2 :: Double -> Double -> Double -> Double -> Double
calcK2 x25 x50 x75 k1 = (k_2_1 + k_2_2) / 2.0
   where k_2_1 = (-log(k1 / 3.0)) / (x75 - x50)
         k_2_2 = (-log(k1 / 3.0)) / (x50 - x25)


--  This adjusts the ends so that they meet at the proper 
--  utility value at end points.
calcK3_4 :: Double -> Double -> Double -> Double -> Double -> (Double, Double)
calcK3_4 x0 x50 x100 k1 k2 = (k_3, k_4)
   where dnom_0 = 1 + (k1 * exp((-k2) * (x0   - x50)))
         dnom_1 = 1 + (k1 * exp((-k2) * (x100 - x50)))
         k_3 = if (dnom_0-dnom_1 == 0) then 0.0
            else (dnom_1 * dnom_0) / (dnom_0 - dnom_1);
         k_4 = if (dnom_0-dnom_1 == 0) then 0.0
            else (-k_3) / dnom_0;
    



--  Find the parameters for a CDF, using an iterative method.
--  This function finds a fit for the given x-points.
--  It returns the  first seven arguments to CDF as a tuple.
--  In general the CDF we are building is this:
--  CDF(x) = k_3 / (1 + (k_1 * e ** (-k_2 * (x - x_50)))) + k_4
--                         k_3
--  CDF(x) = -------------------------------- + k_4
--                        -k_2 * (x - x_50)
--             1 + k_1 * e 
generateCDF :: Double -> Double -> Double -> Double -> Double -> UtilityCurve 
generateCDF x0 x25 x50  x75 x100 =
    let 
        k1     = 1.0
        k1_d   = k1

        k2     = calcK2 x25 x50 x75 k1

        k3     = 1.0
        k4     = 0.0
        trialCurve = UtilityCurve{ x_0 = x0, x_25 = x25, x_50 = x50, x_75 = x75, 
         x_100 = x100, k_1 = k1, k_2 = k2, k_3 = k3, k_4 = k4, x_progress = 0.0, 
         bounty = 1.0, weight = 1.0 }
      in gcdf' trialCurve k1_d 13 
      where 
         gcdf' :: UtilityCurve -> Double -> Integer -> UtilityCurve 
         gcdf' tc _ 0 = tc 
         gcdf' tc k1_d iterations = 
            let error_value         = calcError tc
                k_1_low             = (k_1 tc) - k1_d
                k_2_low             = calcK2 (x_25 tc) (x_50 tc) (x_75 tc) k_1_low
                (k_3_low,k_4_low)   = calcK3_4 (x_0 tc) (x_50 tc) (x_100 tc) k_1_low k_2_low
                tc_low = UtilityCurve{ x_0 = (x_0 tc), x_25 = (x_25 tc)
                                     , x_50 = (x_50 tc) , x_75 = (x_75 tc)
                                     , x_100  = (x_100 tc), k_1 = k_1_low, k_2 = k_2_low
                                     , k_3 = k_3_low, k_4 = k_4_low, x_progress = 0.0
                                     , bounty = 1.0 , weight = 1.0 }
                error_low           = calcError tc_low
         
                k_1_high            = (k_1 tc) - k1_d
                k_2_high            = calcK2 (x_25 tc) (x_50 tc) (x_75 tc) k_1_high
                (k_3_high,k_4_high) = calcK3_4 (x_0 tc) (x_50 tc) (x_100 tc) k_1_high k_2_high
                tc_high = UtilityCurve{ x_0 = (x_0 tc), x_25 = (x_25 tc)
                                     , x_50 = (x_50 tc) , x_75 = (x_75 tc)
                                     , x_100  = (x_100 tc), k_1 = k_1_high, k_2 = k_2_high
                                     , k_3 = k_3_high, k_4 = k_4_high, x_progress = 0.0
                                     , bounty = 1.0 , weight = 1.0 }
                error_high          = calcError tc_high
                new_tc = if      and [error_high < error_low  , error_high < error_value] then tc_high 
                         else if and [error_low  < error_high , error_low  < error_value] then tc_low  
                                                                                          else tc
               in
                  gcdf' new_tc (k1_d / 2.0) (pred iterations)


makeUtilityCurve :: Double -> Double -> Double -> Double -> Double -> Double -> Double -> Double -> UtilityCurve
makeUtilityCurve x0 x25 x50 x75 x100 weight_ bounty_ progression =
   UtilityCurve{ x_0 = (x_0 uc), x_25 = (x_25 uc)
               , x_50 = (x_50 uc) , x_75 = (x_75 uc)
               , x_100  = (x_100 uc), k_1 = (k_1 uc), k_2 = (k_2 uc)
               , k_3 = (k_3 uc), k_4 = (k_4 uc)
               , x_progress = progression
               , bounty = bounty_
               , weight = weight_
               }
   where uc = generateCDF x0 x25 x50 x75 x100
   
utility :: UtilityCurve -> Double -> Double
utility uc x = (weight uc) * (bounty uc) * (cdf uc x)

marginalUtility :: UtilityCurve -> Double -> Double
marginalUtility uc x = (weight uc) * (bounty uc) * (cdf' uc x)

utilityGrowth :: UtilityCurve -> Double -> Double
utilityGrowth uc x = (weight uc) * (bounty uc) * (cdf'' uc x)


--  Given a constant margin (basemargin) as input,
--  This function returns the value x would be, where the margin 
--  of this UtilityCurve would fall below that basemargin.
getDiminishingMarginalPoint :: UtilityCurve -> Double -> Double
getDiminishingMarginalPoint uc basemargin 
   | marginalUtility uc (x_100 uc) > basemargin = (x_100 uc)
   | otherwise = gdmp' uc basemargin (x_50 uc) (x_100 uc) 1e-9 13
      where     
         gdmp' _ _ start _ _ 0 = start
         gdmp' uc basemargin start end tolerence iterations =
            let half        = (start + end) / 2.0
                half_margin = marginalUtility uc half in
               if      abs(half_margin - basemargin) < tolerence then half 
               else if half_margin > basemargin then 
                  gdmp' uc basemargin half end tolerence (pred iterations)
               else {-- half_margin <= basemargin --}
                  gdmp' uc basemargin start half tolerence (pred iterations)
         

--  Given a constant margin (basemargin) as input,
--  This function returns the value x would be, where the Utility
--  of this UtilityCurve would raise above the integration of that
--  basemargin (baseutil), assuming that baseutil starts at 0.
--  within the optional tolerence argument.
getAscendingIndifferencePoint :: UtilityCurve -> Double -> Double
getAscendingIndifferencePoint uc basemargin = let
   start = (x_0 uc)
   stop  = getDiminishingMarginalPoint uc basemargin 
   in gamp' uc basemargin start stop 1e-9 13
   where
      gamp' _ _ start _ _ 0 = start
      gamp' uc basemargin start end tolerence iterations =
         let half      = (start + end) / 2.0
             half_util = utility uc half
             base_util = basemargin * half in
            if      abs(half_util - base_util) < tolerence then half
            else if (half_util < base_util) then 
               gamp' uc basemargin half end tolerence (pred iterations)
            else {--(half_util <= base_util) --}
               gamp' uc basemargin start half tolerence (pred iterations)



combineAngles n ys []   = groupByN n [] ys 
combineAngles n [] xss  = combineAngles n (head xss) (tail xss)
combineAngles n ys xss  = 
   combineAngles n (head xss >>= \x -> ys >>= \y -> [x,y]) (tail xss)

groupByN n yss [] = yss
groupByN n []  xs = groupByN n [(take n xs)] (drop n xs) 
groupByN n yss xs = groupByN n ((take n xs) : yss) (drop n xs) 

convertHypersphereCoordinates radius thetaPair = 
   chc' [radius | _ <- [0..(length thetaPair)]] thetaPair
   where 
      chc' acc [] = acc
      chc' acc tp = let
         theta  = head tp
         sineP  = (head acc) * (sin theta)
         cosPs  = map (* (cos theta)) (tail acc)
         in sineP : chc' cosPs (tail tp)

getThetaFieldAndStep thetaMin thetaMax n dimensions =
   let thetaStep = (thetaMax - thetaMin) / n
       thetaCount = (dimensions - 1)
       theta = [[thetaMin + thetaStep * ii | ii <- [0..n]] | _ <- [1..thetaCount]]
       thetaField = combineAngles thetaCount [] theta 
   in (thetaField, thetaStep)

getCoordinates radius thetaPairs = let
       coordinates = map (convertHypersphereCoordinates radius) thetaPairs
   in coordinates

calculateUtility utilityCurves coordinates =
   sum $ zipWith utility utilityCurves coordinates 


getMSR' n centerTheta thetaStep radius utilityCurves = let
   thetaMin     = centerTheta - thetaStep
   thetaMax     = centerTheta + thetaStep
   dimensions   = length utilityCurves
   (thetaField, newThetaStep) = 
      getThetaFieldAndStep thetaMin thetaMax n dimensions
   coordinates  = getCoordinates radius thetaField
   utilityField = map (calculateUtility utilityCurves) coordinates
   maxUtility   = maximum utilityField
   index        = head $ elemIndices maxUtility utilityField
   in (maxUtility, newThetaStep, thetaField !! index, coordinates !! index)


--ok this isn't going to work at all--
{--
getMSR radius utilityCurves = let 
   tolerence   = 1e-9
   iterations  = 13
   centerTheta = pi / 4
   thetaStep   = pi / 4
   (gUtil, gTS, gCT, gCoord) = 
      getMSR' iterations centerTheta thetaStep radius utilityCurves

   calculateMSR lastUtil guessUtil guessTS guessCT guessCoord
      | abs(lastUtil - guessUtil) < tolerence   = (guessUtil, guessCoord)
      | otherwise = let 
         (newGuessUtil, newGuessThetaStep, newGuessCT, newGuessCoord) = 
               getMSR' iterations newGuessCT newGuessThetaStep radius utilityCurves
         in calculateMSR newGuessUtil newGuessThetaStep newGuessCT newGuessCoord

   in calculateMSR -1.0 gUtil gTS gCT gCoord
--}




sample1 = makeUtilityCurve 00 07 10 13 20 1 1 0
sample2 = makeUtilityCurve 00 11 12 13 20 1 1 0
sample3 = makeUtilityCurve 00 05 07 09 20 1 1 0

dataxy1 = zip [1.0..20.0] (map (cdf sample1) [1.0..20.0])
dataxy2 = zip [1.0..20.0] (map (cdf sample2) [1.0..20.0])

main = do
   print sample2
   print "---"
   print dataxy2
   print "---"
   print $ getDiminishingMarginalPoint sample1 0.01
   print $ getDiminishingMarginalPoint sample2 0.01
   print "---"
   print $ getAscendingIndifferencePoint sample1 0.01
   print $ getAscendingIndifferencePoint sample2 0.01
   print "---"
   print $ getMSR' 13 (pi/4) (pi / 2 / 13) 10 [sample1, sample2, sample3]
   -- mapM print $ getCoordinates 0 (pi/2) 13 [sample1, sample2, sample3] 1
   -- mapM print $ getCoordinates 0 (pi/8) 13 [sample1, sample2, sample3] 1
   putStrLn $ "bye."
