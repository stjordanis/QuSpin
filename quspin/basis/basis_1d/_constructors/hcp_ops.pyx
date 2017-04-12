#!python
#cython: boundscheck=False
#cython: wraparound=False
# distutils: language=c++


cimport numpy as _np
from libc.math cimport sin,cos,sqrt

from types cimport *


import numpy as _np
from scipy.misc import comb

cdef extern from "glibc_fix.h":
    pass

_np.import_array()

include "sources/hcp_bitops.pyx"
include "sources/refstate.pyx"
include "sources/op_templates.pyx"
include "sources/hcp_ops.pyx"

