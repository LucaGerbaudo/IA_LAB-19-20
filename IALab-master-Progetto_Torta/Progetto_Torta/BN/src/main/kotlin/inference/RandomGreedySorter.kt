package org.devalot.ialab.torta.inference

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import org.devalot.ialab.torta.inference.util.moralize
import org.devalot.ialab.torta.inference.util.toGraph

object RandomGreedySorter : BayesianVariableSorter {
    private val availableEvaluationMetrics = listOf(MinNeighbors, MinWeight, MinFill, WeightedMinFill)

    override fun sort(bayesianNetwork: BayesianNetwork, vars: List<RandomVariable>): List<RandomVariable> =
            GreedyOrderer.order(bayesianNetwork.toGraph().moralize(), vars.toSet()) { availableEvaluationMetrics.random() }

}
