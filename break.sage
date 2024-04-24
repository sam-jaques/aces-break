from pyaces import *


# Recovers x(arg=1) from the public information
def evaluated_key_recovery(f0,f1,intmod,vanmod,dim,tensor):
	# Iterate over indices to start with
	# The goal is to find x[start_index] as an eigenvalue
	for start_index in range(len(tensor)):
		Fq = GF(intmod)

		# Construct the first matrix
		lambda_1 = [tensor[start_index][j][:] for j in range(len(tensor[start_index]))]
		lambda_1 = Matrix(Fq,lambda_1)

		# We know that x[start_index] is an eigenvalue of lambda_1
		eigs = lambda_1.eigenvalues()

		# First filter: we know x[start_index] in F_q, so we 
		# reject any eigenvalues from an extension field
		es = []
		for e in eigs:
			eg = e.as_finite_field_element()[1]
			if eg.parent() == Fq:
				es.append(eg)

		# Now we construct eigenvectors
		# The secret vector is one of these eigenvectors
		# and we know that x[start_index] is the eigenvalue,
		# so we normalize all of them
		vecs = []
		for e in es:
			# The right_eigenvector() function throws errors 
			# but this works
			sub_mat = lambda_1 - e*matrix.identity(lambda_1.ncols())
			e_vec = vector(sub_mat.right_kernel()[1])
			if e_vec[start_index] != 0:
				vecs.append(e_vec*e/e_vec[start_index])


		# Second filter
		# We should have x[i]*x[j] = sum_k lambda[i][j][k]*x[k]
		# Thus, any eigenvectors not satisfying this
		# are removed
		surviving_vecs = []
		for vec in vecs:
			flag = True
			for i in range(len(tensor)):
				for j in range(len(tensor[i])):
					sum = 0
					for k in range(len(tensor[i][j])):
						sum += tensor[i][j][k]*vec[k]
					if sum != vec[i]*vec[j]:
						flag = False
			if flag:
				surviving_vecs.append(vec)

		# Third filter
		# We know that f1 = f0*x + e
		# and that e(1) = kp
		# for some k
		# Thus, we evaluate everything at 
		# 1 and check what works
		vecs = []
		# try with public key
		for vec in surviving_vecs:
			flag = True
			for i in range(len(f0)):
				sum = 0
				for j in range(len(f0[i])):
					sum += f0[i][j](arg=1)*vec[j]
				if (ZZ(f1[i](arg=1) - sum) % intmod) % vanmod != 0:
					flag = False
			if flag:
				vecs.append(vec)

		# Return the first value and hope for the best
		if len(vecs) > 0:
			return(vecs[0])



# Recovers a message given the evaluated secret
def evaluated_decrypt(intmod,vanmod,dim,secret, c):
    cTx = 0
    for i in range(dim):
      cTx = cTx + c.dec[i](arg=1) * secret[i]
    m_pre = c.enc(arg=1) -  cTx
    return ZZ( m_pre % intmod ) % vanmod



# Proof of concept

# Construct instance and encrypt
ac = ArithChannel(32,next_prime(10*32**5+1),10,2)
(f0,f1,vanmod,intmod,dim,N,u,tensor) = ac.publish(fhe = True)

# Recover key evaluated at 1
secret = evaluated_key_recovery(f0,f1,intmod,vanmod,dim,tensor)

# Check message recovery
bob = ACES(f0,f1,vanmod,intmod,dim,N,u)
for m in range(vanmod):
	enc, k = bob.encrypt(m)

	m_prime = evaluated_decrypt(intmod,vanmod,dim,secret,enc)

	print(m_prime==m,m_prime,m)
