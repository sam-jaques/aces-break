from aces import *


# Evaluates a polynomial at omega = 1
def evaluate(poly,intmod):
	return sum(poly.coefs) % intmod

# Evaluates each matrix element at omega=1 
# for a k x 1 matrix (i.e., a list of polynomials)
def matrix_eval(matrix,intmod):
		mat_eval = []
		for mat_row in matrix:
			mat_eval.append(evaluate(mat_row,intmod))
		return mat_eval


def recover_message(ciphertext, f0,f1, intmod,dim):
	f1_eval = evaluate(f1,intmod)

	c_eval = (matrix_eval(c_a[0],intmod),evaluate(c_a[1],intmod))

	# recover b
	b = 0
	for i in range(dim):
		f0_eval = evaluate(f0[i],intmod)
		if gcd(f0_eval,intmod) == 1:
			b = f0_eval.inverse_mod(intmod)*c_eval[0][i]
			break

	# recompute b*f1
	recovered_m = c_eval[1] - b*f1_eval % intmod
	# fix issues with %
	if recovered_m < 0:
		recovered_m += intmod
	return recovered_m


ac = ArithChannel(27,10)

(f0,f1,intmod,dim,u,tensor) = ac.publish(fhe = True)


bob = ACES(f0,f1,intmod,dim,u)



m_a = 3
for m_a in range(intmod):
	c_a = bob.encrypt(m_a)
	recovered_m = recover_message(c_a,f0,f1,intmod,dim)
	

	print(m_a,recovered_m, m_a==recovered_m)

