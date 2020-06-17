@file:Suppress("UnstableApiUsage")

package org.devalot.ialab.torta.inference

import aima.core.probability.RandomVariable
import com.google.common.graph.Graph
import org.devalot.ialab.torta.inference.util.twoSets

interface EvaluationMetric<in N> {
    operator fun <M : N> invoke(graph: Graph<M>, markedNodes: Set<M>, evaluationTarget: M): Int
}

object MinNeighbors : EvaluationMetric<Any> {
    override fun <M : Any> invoke(graph: Graph<M>, markedNodes: Set<M>, evaluationTarget: M): Int =
            graph.adjacentNodes(evaluationTarget).count()
}

object MinWeight : EvaluationMetric<RandomVariable> {
    override fun <M : RandomVariable> invoke(graph: Graph<M>, markedNodes: Set<M>, evaluationTarget: M): Int =
            graph.adjacentNodes(evaluationTarget).map {
                it.domain.size()
            }.fold(1, Int::times)
}

object MinFill : EvaluationMetric<Any> {
    override fun <M : Any> invoke(graph: Graph<M>, markedNodes: Set<M>, evaluationTarget: M): Int =
            graph.adjacentNodes(evaluationTarget)
                    .twoSets()
                    .map { it.toPair() }
                    .filter { !graph.hasEdgeConnecting(it.first, it.second) }
                    .count()
}

object WeightedMinFill : EvaluationMetric<RandomVariable> {
    override fun <M : RandomVariable> invoke(graph: Graph<M>, markedNodes: Set<M>, evaluationTarget: M): Int =
            graph.adjacentNodes(evaluationTarget)
                    .twoSets()
                    .map { it.toPair() }
                    .filter { !graph.hasEdgeConnecting(it.first, it.second) }
                    .map { edge ->
                        listOf(edge.first, edge.second).map { MinWeight(graph, markedNodes, it) }
                                .fold(1, Int::times)
                    }
                    .sum()
}
