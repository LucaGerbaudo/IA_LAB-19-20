@file:Suppress("UnstableApiUsage")

package org.devalot.ialab.torta.inference

import com.google.common.graph.Graph
import com.google.common.graph.Graphs
import org.devalot.ialab.torta.inference.util.forEachDiffentPair

object GreedyOrderer {
    fun <N> order(graph: Graph<N>, nodesToBeOrdered: Set<N>, evaluationMetric: () -> EvaluationMetric<N>): List<N> {
        require(!graph.isDirected)
        require(!graph.allowsSelfLoops())
        val mutableGraph = Graphs.copyOf(graph)
        val markedNodes = mutableSetOf<N>()
        val notMarkedNodes = mutableGraph.nodes().toMutableSet()
        return (1..nodesToBeOrdered.size).fold(emptyList()) { acc, _ ->
            val currentMetric = evaluationMetric()
            acc + (notMarkedNodes
                    .filter { it in nodesToBeOrdered }
                    .minBy { currentMetric(mutableGraph, markedNodes, it) }!!
                    .also { min ->
                        markedNodes.add(min)
                        notMarkedNodes.remove(min)
                        mutableGraph.adjacentNodes(min).forEachDiffentPair { first, second ->
                            mutableGraph.putEdge(first, second)
                        }
                    })
        }
    }
}
