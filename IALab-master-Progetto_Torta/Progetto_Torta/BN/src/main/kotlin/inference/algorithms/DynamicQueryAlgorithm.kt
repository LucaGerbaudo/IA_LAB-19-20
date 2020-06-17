package org.devalot.ialab.torta.inference.algorithms

import aima.core.probability.CategoricalDistribution
import aima.core.probability.RandomVariable
import aima.core.probability.bayes.DynamicBayesianNetwork
import aima.core.probability.proposition.AssignmentProposition

interface DynamicQueryAlgorithm {
    fun run(
            network: DynamicBayesianNetwork,
            evidence: List<List<AssignmentProposition>>,
            queryVariables: List<RandomVariable> = network.priorNetwork.variablesInTopologicalOrder
    ): CategoricalDistribution
}