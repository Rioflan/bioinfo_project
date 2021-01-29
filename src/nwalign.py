#!/usr/bin/python3

import sys
import argparse
from const_defaults import *

# Parsing

parser = argparse.ArgumentParser(description='Projet bioinfo')
parser.add_argument('cmd', type=toCmd)
parser.add_argument('x')
parser.add_argument('y')
parser.add_argument('--gamma')
arguments = parser.parse_args()

if arguments.gamma:
    gamma = [int(x) for x in arguments.gamma.split(',')]
else:
    gamma = [-1, 0]


input_type = None

if adn_reg.fullmatch(arguments.x) and adn_reg.fullmatch(arguments.y):
    input_type = Adn()
elif arn_req.fullmatch(arguments.x) and arn_req.fullmatch(arguments.y):
    input_type = Arn()
elif prot_reg.match(arguments.x) and prot_reg.fullmatch(arguments.y):
    input_type = Protein()
else:
    print('Sequence is not matching pattern')
    exit(1)

score_matrix = [[0 for j in range(len(arguments.y) + 1)]
                    for i in range(len(arguments.x) + 1)]

backtrack_matrix = [[(0,0) for j in range(len(arguments.y) + 1)]
                    for i in range(len(arguments.x) + 1)]

for j in range(len(arguments.y)):
    score_matrix[0][j] = j * gamma[0] + gamma[1]

for i in range(len(arguments.x)):
    score_matrix[i][0] = i * gamma[0] + gamma[1]

# Best K, used for step 3, defaults to 1 to keep step 2
for i in range(1, len(arguments.x) + 1):
    for j in range(1, len(arguments.y) + 1):
        substitution = input_type.matrix[input_type.map[arguments.x[i-1]]] \
            [input_type.map[arguments.y[j-1]]] + score_matrix[i-1][j-1]
        # Step 2 case, also used for defaut step 3 (with k=1)
        insertion = gamma[1] + gamma[0] + score_matrix[i-1][j]
        deletion = gamma[1] + gamma[0] + score_matrix[i][j-1]
        # Insertion Best K and Deletion Best K, used for step 3
        bik, bdk = 1, 1
        if gamma[1] != 0:
            for k in range(2, len(arguments.x) + 1):
                ninsertion = gamma[1] + gamma[0] * k + score_matrix[i-k][j]
                if ninsertion > insertion:
                    insertion = ninsertion
                    bik = k
            for k in range(2, len(arguments.y) + 1):
                ndeletion = gamma[1] + gamma[0] * k + score_matrix[i][j-k]
                if ndeletion > deletion:
                    deletion = ndeletion
                    bdk = k
        score_matrix[i][j] = substitution
        backtrack_matrix[i][j] = (i-1, j-1)
        if score_matrix[i][j] < insertion:
            score_matrix[i][j] = insertion
            backtrack_matrix[i][j] = (i-bik, j)
        if score_matrix[i][j] < deletion:
            score_matrix[i][j] = deletion
            backtrack_matrix[i][j] = (i, j-bdk)


if arguments.cmd == Cmd.ALIGN:
    ax, ay = '', ''
    (u, v) = (len(arguments.x), len(arguments.y))
    while u != 0 or v != 0:
        (nu, nv) = backtrack_matrix[u][v]
        if nu == u - 1 and nv == v - 1:
            ax = arguments.x[u - 1] + ax
            ay = arguments.y[v - 1] + ay
        elif nv == v:
            k = u - nu
            ax = arguments.x[u-k:u] + ax
            ay = '-' * k + ay
        elif nu == u:
            k = v - nv
            ax = '-' * k + ax
            ay = arguments.y[v-k:v] + ay
        u, v = nu, nv
    print(ax)
    print(ay)

if arguments.cmd == Cmd.SCORE:
    print(f"{ score_matrix[-1][-1] }.0")