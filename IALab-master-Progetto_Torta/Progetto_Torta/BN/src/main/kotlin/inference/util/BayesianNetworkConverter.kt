package org.devalot.ialab.torta.inference.util

import aima.core.probability.RandomVariable
import org.encog.ml.bayesian.BayesianNetwork as EncogBayesianNetwork
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.bayes.Node
import aima.core.probability.bayes.impl.BayesNet
import aima.core.probability.bayes.impl.FullCPTNode
import aima.core.probability.domain.ArbitraryTokenDomain
import aima.core.probability.domain.Domain
import aima.core.probability.util.RandVar
import org.encog.ml.bayesian.BayesianEvent
import org.encog.ml.bayesian.table.BayesianTable

object BayesianNetworkConverter {
    fun convert(encogBayesianNetwork: EncogBayesianNetwork): BayesianNetwork =
            expandFrontier(encogBayesianNetwork.events.filter { !it.hasParents() }.toSet(), emptyMap())

    private tailrec fun expandFrontier(bayesianEvents: Set<BayesianEvent>, alreadyConvertedNodes: Map<BayesianEvent, Node>): BayesianNetwork =
            if (bayesianEvents.isEmpty()) {
                BayesNet(*alreadyConvertedNodes.values.filter { it.isRoot }.toTypedArray())
            } else {
                val (frontier, openNodes) = bayesianEvents.partition { isFrontier(it, alreadyConvertedNodes) }
                val (newOpenNodes, newConvertedNodes) = frontier.fold(Pair(openNodes.toSet(), alreadyConvertedNodes)) { acc, event ->
                    Pair(acc.first + event.children, acc.second + Pair(event, convertEvent(event, acc.second)))
                }
                expandFrontier(newOpenNodes, newConvertedNodes)
            }

    private fun isFrontier(bayesianEvent: BayesianEvent, alreadyConvertedNodes: Map<BayesianEvent, Node>): Boolean =
            bayesianEvent.parents.all { it in alreadyConvertedNodes }

    private fun convertEvent(event: BayesianEvent, alreadyConvertedNodes: Map<BayesianEvent, Node>): Node {
        val parents = event.parents.map { alreadyConvertedNodes[it]!! }
        val randomVariable = getRandomVariableFromEvent(event)
        return FullCPTNode(randomVariable,
                convertProbabilityTable(event.table,
                        randomVariable.domain,
                        parents.map { it.randomVariable.domain })
                , *parents.toTypedArray())
    }

    private fun getRandomVariableFromEvent(event: BayesianEvent): RandomVariable =
            RandVar(event.label, ArbitraryTokenDomain(*event.choices.map { it.label }.toTypedArray()))

    private fun convertProbabilityTable(bayesianTable: BayesianTable, currentDomain: Domain, parentsDomain: List<Domain>): DoubleArray =
            genAllIndexCombinations(parentsDomain.map { 0 until it.size() }).flatMap { comb ->
                (0 until currentDomain.size()).map { result ->
                    bayesianTable.findLine(result, comb.toIntArray()).probability
                }
            }.toDoubleArray()

    private fun genAllIndexCombinations(ranges: List<IntRange>): List<List<Int>> =
            if (ranges.isEmpty()) {
                listOf(emptyList())
            } else {
                addRangeToCombinations(ranges.first(), genAllIndexCombinations(ranges.drop(1)))
            }

    private fun addRangeToCombinations(range: IntRange, combinations: List<List<Int>>): List<List<Int>> =
            range.flatMap { index ->
                combinations.map { listOf(index) + it }
            }
}
