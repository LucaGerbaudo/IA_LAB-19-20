package org.devalot.ialab.torta.inference.algorithms

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.proposition.AssignmentProposition
import org.devalot.ialab.torta.inference.BayesianVariableSorter
import org.devalot.ialab.torta.inference.IrrelevantVariablesFinder
import org.devalot.ialab.torta.inference.util.BayesianNetworkPruner
import org.devalot.ialab.torta.inference.util.makeFactor
import org.devalot.ialab.torta.inference.util.pointwiseProduct
import org.devalot.ialab.torta.inference.util.toMaxedOutFactor

open class MAPAsk(private val sorter: BayesianVariableSorter = BayesianVariableSorter.default,
                  private val ivFinder: IrrelevantVariablesFinder = IrrelevantVariablesFinder.default
) : QueryAlgorithm<List<AssignmentProposition>> {

    override fun ask(
            queryVariables: List<RandomVariable>,
            observedEvidence: List<AssignmentProposition>,
            bayesianNetwork: BayesianNetwork
    ): List<AssignmentProposition> {
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
        val endFactors = sorter.sort(prunedNetwork, queryVariables).fold(
                remainingFactors.map { it.toMaxedOutFactor() }
        ) { acc, rv ->
            val toBeMaxProdFacts = acc.filter { it.factor.contains(rv) }
            //println("to be maxed: (${toBeMaxProdFacts.map { it.factor.argumentVariables }}) $toBeMaxProdFacts")
            val newFact = toBeMaxProdFacts.pointwiseProduct().maxOut(rv)
            //println("$rv new facto: $newFact")
            (acc - toBeMaxProdFacts) + newFact
        }
        //println(endFactors)
        require(endFactors.all { it.factor.values.size == 1 })
        val result = endFactors.pointwiseProduct()
        //println(result)
        require(result.factor.values.size == 1)
        require(result.assignments.size == 1)
        return result.assignments.first()
    }

}
