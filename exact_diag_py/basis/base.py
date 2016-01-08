# python 2.7 modules
import operator as _op # needed to calculate n choose r in function ncr(n,r).
from numpy import int32 as _index_type
from numpy import array as _array
import numpy as _np

# local modules
from constructors import op_m,make_m_basis,SpinOp

# References:
# [1]: A. W. Sandvik, AIP Conf. Proc. 1297, 135 (2010)



class BasisError(Exception):
	# this class defines an exception which can be raised whenever there is some sort of error which we can
	# see will obviously break the code. 
	def __init__(self,message):
		self.message=message
	def __str__(self):
		return self.message


def ncr(n, r):
# this function calculates n choose r used to find the total number of basis states when the magnetization is conserved.
    r = min(r, n-r)
    if r == 0: return 1
    numer = reduce(_op.mul, xrange(n, n-r, -1))
    denom = reduce(_op.mul, xrange(1, r+1))
    return numer//denom

# Parent Class Basis: This class is the basic template for all other basis classes. It only has Magnetization symmetry as an option.
# all 'child' classes will inherit its functionality, but that functionality can be overwritten in the child class.
# Basis classes must have the functionality of finding the matrix elements built in. This way, the function for constructing 
# the hamiltonian is universal and the basis object takes care of constructing the correct matrix elements based on its internal symmetry. 
class base:
	def __init__(self,L,Nup=None):
		# This is the constructor of the class Basis:
		#		L: length of chain
		#		Nup: number of up spins if restricting magnetization sector.
		if L>30: raise BasisError("L must be less than 31") 
		self.L=L
		if type(Nup) is int:
			if Nup < 0 or Nup > L: raise BasisError("0 <= Nup <= %d" % L)
			self.Nup=Nup
			self.conserved="M"
			self.Ns=ncr(L,Nup) 
			s0=sum([2**i for i in xrange(0,Nup)])
			self.basis=make_m_basis(s0,self.Ns)
		else:
			self.conserved=""
			self.Ns=2**L
			self.basis=_array(xrange(self.Ns),dtype=_index_type)


	def Op(self,J,dtype,opstr,indx):
		row=_array(xrange(self.Ns),dtype=_index_type)
		if self.conserved:
			return op_m(self.basis,opstr,indx,J,dtype)
		else:
			return SpinOp(self.basis,opstr,indx,J,dtype)
			









