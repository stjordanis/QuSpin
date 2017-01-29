

cdef basis_type shift(basis_type I,int shift,int period,void *pars):
# this functino is used to shift the bits of an integer by 'shift' bits.
# it is used when constructing the momentum states
	cdef basis_type Imax = ((1llu << period) -1 if period < 64 else ~0llu)
	cdef int l1,l2
	if I==0 or I==Imax:
		return I
	else:
		l1 = shift%period
		l2 = period - l1
		return ((I << l1) & Imax) | ((I & Imax) >> l2)

"""
cdef basis_type shift_spf(basis_type I,int shift_by,int length,void *pars):
	cdef basis_type I1 = I & ( (1llu<<length)-1 )
	cdef basis_type I2 = I >> length
	I1 = shift(I1,shift_by,length,pars)
	I2 = shift(I2,shift_by,length,pars)
	return I1+( I2 << length )
"""



cdef NP_INT8_t bit_count(basis_type I, int length):
	cdef NP_INT8_t out = 0
	cdef int i
	for i in range(length):
		out += ((I >> i) & 1) 

	return out




cdef basis_type fliplr(basis_type I, int length,void *pars):
# this function flips the bits of an integer around the centre, e.g. 1010 -> 0101
# (generator of) parity symmetry
	cdef basis_type out = 0
	cdef int i
	cdef basis_type j
	j = 1
	for i in range(length):
		out += ((I >> (length-1-i)) & 1 )*j
		j <<= 1
		
	return out

"""
cdef basis_type fliplr_spf(basis_type I, int length,void *pars):
	cdef basis_type I1 = I & ( (1llu<<length)-1 )
	cdef basis_type I2 = I >> length
	I1 = fliplr(I1,length,pars)
	I2 = fliplr(I2,length,pars)
	return I1+( I2 << length)	
"""


cdef basis_type flip_all(basis_type I, int length,void *pars):
#	 flip all bits
	cdef basis_type Imax = ((1llu << length) -1 if length < 64 else ~0ull)
	return I^(Imax & (~0llu))


cdef basis_type flip_sublat_A(basis_type I, int length,void *pars):
#	 flip all even bits: sublat A
#	 6148914691236517205 = Sum[2^i, (i, 0, 63, 2)]
	cdef basis_type Imax = ((1llu << length) -1 if length < 64 else ~0ull)
	return I^(Imax&6148914691236517205llu)
	

cdef basis_type flip_sublat_B(basis_type I, int length,void *pars):
#	 flip all odd bits: sublat B
#	 12297829382473034410 = Sum[2^i, (i, 1, 63, 2)]
	cdef basis_type Imax = ((1llu << length) -1 if length < 64 else ~0ull)
	return I^(Imax&12297829382473034410llu)



cdef basis_type next_state_pcon_hcb(basis_type v,void *pars):
	if v == 0:
		return v

	cdef basis_type t = (v | (v - 1)) + 1
	return t | ((((t & -t) / (v & -v)) >> 1) - 1)



cdef basis_type next_state_inc_1(basis_type v,void *pars):
	return v + 1



"""
cdef basis_type next_state_inc_1_spf(basis_type v, void *pars):
	cdef basis_type *p = <basis_type *> pars
	cdef basis_type L = p[0]
	cdef basis_type s1 = v & ( (1llu<<L)-1 )
	cdef basis_type s2 = v >> L

	s1 = (s1 + 1) % (1llu<<L)
	if s1 == 0: s2 += 1

	return s1+(s2<<L)



cdef basis_type next_state_pcon_spf(basis_type v, void *pars):
	cdef basis_type *p = <basis_type *> pars
	cdef basis_type L = p[0]
	cdef basis_type MAX1 = p[1]
	cdef basis_type MIN1 = p[2]

	cdef basis_type s1 = v & ( (1llu<<L)-1 )
	cdef basis_type s2 = v >> L

	if s1 < MAX1:
		s1 = next_state_pcon_hcb(s1,NULL)
	else:
		s2 = next_state_pcon_hcb(s2,NULL)
		s1 = MIN1

	return s1+(s2<<L)




cdef basis_type next_state_pcon_spf(basis_type v, void *pars):
	cdef basis_type *p = <basis_type *> pars
	cdef basis_type L = p[0]
	cdef basis_type MAX1 = p[1]
	cdef basis_type MIN1 = p[2]
	cdef basis_type s1 = v & ( (1llu<<L)-1 )
	cdef basis_type s2 = v >> L
	if s1 < MAX1:
		s1 = next_state_pcon_hcb(s1,NULL)
	else:
		s2 = next_state_pcon_hcb(s2,NULL)
		s1 = MIN1
	return s1+(s2<<L)





cdef int count_bosons(basis_type s,int length,int m):
	cdef int M=1
	cdef int count = 0
	cdef int i
	for i in range(length):
		count += (s/M)%m
		M *= m

	return count


cdef basis_type next_state_pcon_b(basis_type s, void *pars):
	cdef basis_type *p = <basis_type *> pars
	cdef int L = p[0]
	cdef int m = p[1]

	cdef int N_goal = count_bosons(s,L,m)

	s += 1
	cdef int N = count_bosons(s,L,m)
	while(N != N_goal):
		s += 1
		N = count_bosons(s,L,m)

	return s

"""


