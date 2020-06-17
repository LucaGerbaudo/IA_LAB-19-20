@file:Suppress("UnstableApiUsage")

package inference

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import com.google.common.graph.Graphs
import org.devalot.ialab.torta.inference.util.moralize
import org.devalot.ialab.torta.inference.util.toGraph

object MReductor {
    fun reduce(queryVariables: Set<RandomVariable>,
               evidenceVariables: Set<RandomVariable>,
               bayesianNetwork: BayesianNetwork
    ): Set<RandomVariable> {
        val graph = Graphs.copyOf(bayesianNetwork.toGraph().moralize())
        evidenceVariables.forEach { graph.removeNode(it) }
        return queryVariables.flatMap { Graphs.reachableNodes(graph, it) }.toSet()
    }
}