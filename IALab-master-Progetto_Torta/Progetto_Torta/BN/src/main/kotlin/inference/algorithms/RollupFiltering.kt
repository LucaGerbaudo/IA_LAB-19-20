package org.devalot.ialab.torta.inference.algorithms

import aima.core.probability.CategoricalDistribution
import aima.core.probability.Factor
import aima.core.probability.RandomVariable
import aima.core.probability.bayes.DynamicBayesianNetwork
import aima.core.probability.proposition.AssignmentProposition
import aima.core.probability.util.ProbabilityTable
import org.devalot.ialab.torta.inference.BayesianVariableSorter
import org.devalot.ialab.torta.inference.util.makeFactor
import org.devalot.ialab.torta.inference.util.pointwiseProduct

class RollupFiltering(
        private val sorter: BayesianVariableSorter = BayesianVariableSorter.default
) : DynamicQueryAlgorithm {
    companion object {
        private val identity = ProbabilityTable(doubleArrayOf(1.0))
    }

    override fun run(network: DynamicBayesianNetwork,
                     evidence: List<List<AssignmentProposition>>,
                     queryVariables: List<RandomVariable>): CategoricalDistribution {
        val order = sorter.sort(network.priorNetwork, network.x_0.toList()) // TODO think more about this
        val remainingFactors: List<Factor> = evidence.fold(initialFactor(network)) { acc, currentEvidence ->
            val allFactors = acc + (network.x_1 + network.e_1).map { network.getNode(it) }.map { it.makeFactor(currentEvidence) }
            val factorsLeft = order.fold(allFactors) { factors, rv ->
                val toBeSumProdFacts = factors.filter { it.contains(rv) }
                val newFact = toBeSumProdFacts.pointwiseProduct().sumOut(rv)
                (factors - toBeSumProdFacts) + newFact
            }
            factorsLeft.map { x1Factor ->
                ProbabilityTable(
                        (x1Factor as ProbabilityTable).values,
                        *x1Factor.argumentVariables.map { network.x_1_to_X_0[it] }.toTypedArray()
                )
            }
        }
        val queryFactors = sorter.sort(network.priorNetwork,
                network.priorNetwork.variablesInTopologicalOrder - queryVariables).fold(remainingFactors) { acc, rv ->
            val toBeSumProdFacts = acc.filter { it.contains(rv) }
            val newFact = toBeSumProdFacts.pointwiseProduct().sumOut(rv)
            (acc - toBeSumProdFacts) + newFact
        }
        return (queryFactors
                .pointwiseProduct()
                .pointwiseProductPOS(identity, *queryVariables.toTypedArray()) as ProbabilityTable)
                .normalize()
    }

    private fun initialFactor(network: DynamicBayesianNetwork): List<Factor> =
            network.priorNetwork.variablesInTopologicalOrder.map { network.priorNetwork.getNode(it) }
                    .map { it.makeFactor(emptyList()) }
}
