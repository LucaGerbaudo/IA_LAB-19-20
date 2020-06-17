package org.devalot.ialab.torta.inference.util

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.bayes.FiniteNode
import aima.core.probability.bayes.Node
import aima.core.probability.bayes.impl.BayesNet
import aima.core.probability.bayes.impl.FullCPTNode

object BayesianNetworkPruner {
    fun prune(bayesianNetwork: BayesianNetwork, prunedVariables: Set<RandomVariable>): BayesianNetwork {
        val newNodes: Map<RandomVariable, Node> = bayesianNetwork.variablesInTopologicalOrder
                .filter { !prunedVariables.contains(it) }
                .fold(emptyMap()) { map, rv ->
                    val oldNode = bayesianNetwork.getNode(rv) as FiniteNode
                    val newParents = oldNode.parents
                            .map { it.randomVariable }
                            .map { map[it] }
                            .filter { it != null }
                            .toTypedArray()
                    map + Pair(rv, FullCPTNode(rv, computePrunedCPT(oldNode, prunedVariables), *newParents))
                }
        return BayesNet(*newNodes.values.filter { it.isRoot }.toTypedArray())
    }

    private fun computePrunedCPT(oldNode: FiniteNode, irrelevantVariables: Set<RandomVariable>): DoubleArray =
            oldNode.cpt
                    .getFactorFor()
                    .sumOut(*irrelevantVariables
                            .filter { irrVar -> oldNode.parents.map { it.randomVariable }.contains(irrVar) }
                            .toTypedArray())
                    .values.normalize(oldNode.randomVariable.domain.size()).also {
                //println("pruned: $oldNode, new CPT: ${it.joinToString(", ")}")
            }
}