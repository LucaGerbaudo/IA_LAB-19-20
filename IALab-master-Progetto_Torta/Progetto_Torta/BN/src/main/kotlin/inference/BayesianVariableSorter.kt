package org.devalot.ialab.torta.inference

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork

interface BayesianVariableSorter {
    companion object {
        val default: BayesianVariableSorter = object : BayesianVariableSorter {
            override fun sort(bayesianNetwork: BayesianNetwork, vars: List<RandomVariable>): List<RandomVariable> =
                    bayesianNetwork.variablesInTopologicalOrder.reversed().intersect(vars).toList()
        }
    }

    fun sort(bayesianNetwork: BayesianNetwork, vars: List<RandomVariable>): List<RandomVariable>
}
