package org.devalot.ialab.torta.inference.algorithms

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.proposition.AssignmentProposition

interface QueryAlgorithm<T> {
    fun ask(
            queryVariables: List<RandomVariable>,
            observedEvidence: List<AssignmentProposition>,
            bayesianNetwork: BayesianNetwork
    ): T
}