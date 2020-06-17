package org.devalot.ialab.torta.inference.util

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.bayes.DynamicBayesianNetwork
import aima.core.probability.bayes.impl.DynamicBayesNet
import aima.core.probability.bayes.impl.FullCPTNode
import aima.core.probability.util.RandVar

object BayesianNetworkDynamizer {

    fun dynamize(network: BayesianNetwork, evidenceSelector: (RandomVariable) -> Boolean,
                 transactionModelDescriptor: (RandomVariable) -> Pair<List<RandomVariable>, DoubleArray>): DynamicBayesianNetwork {
        val x0Nodes = network.variablesInTopologicalOrder
                .filter { !evidenceSelector(it) }
                .map { network.getNode(it) as FullCPTNode }
                .fold(emptyList<FullCPTNode>()) { acc, node ->
                    acc + FullCPTNode(node.randomVariable,
                            node.makeFactor(emptyList()).values,
                            *node.parents.map { p ->
                                acc.find { it.randomVariable == p.randomVariable }!!
                            }.toTypedArray())
                }
        val x0Tox1Mapper: Map<RandomVariable, RandomVariable> = network.variablesInTopologicalOrder
                .filter { !evidenceSelector(it) }
                .map { Pair(it, RandVar("${it.name}_1", it.domain)) }
                .toMap()
        val x1Nodes = x0Tox1Mapper.entries
                .fold(emptyList<FullCPTNode>()) { acc, (oldRv, rv) ->
                    val (parentsX0, distribution) = transactionModelDescriptor(oldRv)
                    val parentsX1 = (parentsX0 + network.getNode(oldRv).parents.map { it.randomVariable }.map { x0Tox1Mapper[it]!! })
                    acc + FullCPTNode(rv, distribution, *parentsX1.map { p ->
                        (x0Nodes + acc).find { it.randomVariable == p }!!
                    }.toTypedArray())
                }
        val evidenceNodes = network.variablesInTopologicalOrder
                .filter(evidenceSelector)
                .map { network.getNode(it) as FullCPTNode }
                .map { node ->
                    FullCPTNode(node.randomVariable,
                            node.makeFactor(emptyList()).values,
                            *node.parents.map { p ->
                                x1Nodes.find { it.randomVariable == x0Tox1Mapper[p.randomVariable]!! }!!
                            }.toTypedArray())
                }
        return DynamicBayesNet(BayesianNetworkPruner.prune(network, network.variablesInTopologicalOrder.filter(evidenceSelector).toSet()),
                x0Tox1Mapper, evidenceNodes.map { it.randomVariable }.toSet(), *(x0Nodes + x1Nodes).filter { it.isRoot }.toTypedArray())
    }
}