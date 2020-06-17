package org.devalot.ialab.torta.inference

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.proposition.AssignmentProposition

interface IrrelevantVariablesFinder {
    companion object {
        val default: IrrelevantVariablesFinder = object : IrrelevantVariablesFinder {
            override fun findIrrelevantVariables(
                    queryVariables: List<RandomVariable>,
                    observedEvidence: List<AssignmentProposition>,
                    bayesianNetwork: BayesianNetwork
            ): Set<RandomVariable> = emptySet()
        }
    }

    fun findIrrelevantVariables(
            queryVariables: List<RandomVariable>,
            observedEvidence: List<AssignmentProposition>,
            bayesianNetwork: BayesianNetwork
    ): Set<RandomVariable>
}
