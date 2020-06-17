package org.devalot.ialab.torta.inference.algorithms

import aima.core.probability.CategoricalDistribution
import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.proposition.AssignmentProposition
import aima.core.probability.util.ProbabilityTable
import org.devalot.ialab.torta.inference.BayesianVariableSorter
import org.devalot.ialab.torta.inference.IrrelevantVariablesFinder
import org.devalot.ialab.torta.inference.util.BayesianNetworkPruner
import org.devalot.ialab.torta.inference.util.makeFactor
import org.devalot.ialab.torta.inference.util.pointwiseProduct

class EliminationAsk(private val sorter: BayesianVariableSorter = BayesianVariableSorter.default,
                     private val ivFinder: IrrelevantVariablesFinder = IrrelevantVariablesFinder.default
) : QueryAlgorithm<CategoricalDistribution> {
    companion object {
        private val identity = ProbabilityTable(doubleArrayOf(1.0))
    }

    override fun ask(
            queryVariables: List<RandomVariable>,
            observedEvidence: List<AssignmentProposition>,
            bayesianNetwork: BayesianNetwork
    ): CategoricalDistribution {
        val irrelevantVariables = ivFinder.findIrrelevantVariables(queryVariables, observedEvidence, bayesianNetwork)
        val prunedNetwork = BayesianNetworkPruner.prune(bayesianNetwork, irrelevantVariables)
        val observedVariables = observedEvidence.flatMap { it.scope }
        val hidden = prunedNetwork.variablesInTopologicalOrder - (queryVariables + observedVariables)
        val factors = prunedNetwork.variablesInTopologicalOrder.map { prunedNetwork.getNode(it).makeFactor(observedEvidence) }
        val remainingFactors = sorter.sort(prunedNetwork, hidden).fold(factors) { acc, rv ->
            val toBeSumProdFacts = acc.filter { it.contains(rv) }
            val newFact = toBeSumProdFacts.pointwiseProduct().sumOut(rv)
            (acc - toBeSumProdFacts) + newFact
        }
        // return NORMALIZE(POINTWISE-PRODUCT(factors))
        val product = remainingFactors.pointwiseProduct()
        // Note: Want to ensure the order of the product matches the
        // query variables
        return (product.pointwiseProductPOS(identity, *queryVariables.toTypedArray()) as ProbabilityTable)
                .normalize()
    }
}
