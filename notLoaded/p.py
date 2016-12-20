import itertools
import PyGnuplot as gp
import numpy as np
import sys
import a as cdf

def take(N, Iterable):
    return [next(Iterable) for n in range(N)]


def pSeries(P):
    base = ((1. - P) ** n * P for n in itertools.count())
    result = 0.
    while True:
        result += next(base)
        yield result


def npSeries(N, P):
    base = [pSeries(P) for _ in range(N)]
    for ii in range(N): 
        for _ in range(ii): next(base[ii])
    while True:
        yield reduce(lambda x,y: x*y, map(next, base), 1)


def tryAndProb(N, P):
    for ii in range(N): 
        yield (ii,0.)
    result = npSeries(N, P)
    ii = N
    while True:
        yield ii, next(result)
        ii += 1


def splitdiff(target, prv, nxt):
    rise = nxt[1] - prv[1]
    run  = nxt[0] - prv[0]
    delta = target - prv[0]
    y_minus_b = (target - prv[1])
    m_inverse = run / rise
    x_delta   = y_minus_b * m_inverse
    return prv[0] + x_delta


def makeUtilityCurveFromProbabilityAndCount(Prob, Count):
    result = list(itertools.takewhile(lambda (_,y): y < 0.9999, tryAndProb(Count,Prob)))
    for prv, nxt in zip(result[:-1], result[1:]):
        if prv[1] <= 0.00 and nxt[1] > 0.00: x_0  = prv[0]
        if prv[1] <= 0.25 and nxt[1] > 0.25: x_25 = splitdiff(0.25, prv, nxt)
        if prv[1] <= 0.50 and nxt[1] > 0.50: x_50 = splitdiff(0.50, prv, nxt)
        if prv[1] <= 0.75 and nxt[1] > 0.75: x_75 = splitdiff(0.75, prv, nxt)
        if nxt[1] < 1.0 : x_100 = nxt[0]
    uc = cdf.UtilityCurve(x_0, x_25, x_50, x_75, x_100)
    return uc

def plot3dMSR(uc_3):

    hyperPoints = cdf.getMSR_ND(uc_s, N=190)

    gp.s(np.transpose(hyperPoints), filename="plot3dMSR.dat")
    gp.c('set ticslevel 0')
    gp.c('unset key')
    gp.figure('0')
    c_plot = 'splot "plot3dMSR.dat" with lines ' 
    print c_plot                   
    gp.c(c_plot)


uc_1 = makeUtilityCurveFromProbabilityAndCount(0.02,10)
uc_2 = makeUtilityCurveFromProbabilityAndCount(0.08,5)
uc_3 = makeUtilityCurveFromProbabilityAndCount(0.042,7)

uc_s = [uc_1, uc_2, uc_3]
plot3dMSR(uc_s)


