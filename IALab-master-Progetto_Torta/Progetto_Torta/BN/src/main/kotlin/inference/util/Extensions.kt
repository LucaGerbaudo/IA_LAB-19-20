@file:Suppress("UnstableApiUsage")

package org.devalot.ialab.torta.inference.util

import aima.core.probability.Factor
import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.bayes.FiniteNode
import aima.core.probability.bayes.Node
import aima.core.probability.proposition.AssignmentProposition
import aima.core.probability.util.ProbabilityTable
import com.google.common.graph.Graph
import com.google.common.graph.GraphBuilder
import com.google.common.graph.Graphs
import org.devalot.ialab.torta.inference.MaxedOutFactor

fun DoubleArray.normalize(rowSize: Int): DoubleArray = this.toList()
        .windowed(rowSize, rowSize, false)
        .flatMap { window ->
            val sum = window.sum()
            window.map { it / sum }
        }.toDoubleArray()

fun BayesianNetwork.toGraph(): Graph<RandomVariable> {
    val output = GraphBuilder.directed()
            .allowsSelfLoops(false)
            .expectedNodeCount(this.variablesInTopologicalOrder.size)
            .build<RandomVariable>()
    this.variablesInTopologicalOrder.forEach { output.addNode(it) }
    this.variablesInTopologicalOrder.map { this.getNode(it) }.forEach { node ->
        node.parents.forEach { parent -> output.putEdge(parent.randomVariable, node.randomVariable) }
    }
    return output
}

fun <N> Graph<N>.undirected(): Graph<N> = GraphBuilder.undirected().allowsSelfLoops(this.allowsSelfLoops())
        .expectedNodeCount(this.nodes().size).nodeOrder(this.nodeOrder()).build<N>().also {
            this.nodes().forEach { node -> it.addNode(node) }
            this.edges().forEach { edge -> it.putEdge(edge.nodeU(), edge.nodeV()) }
        }

fun <N> Graph<N>.moralize(): Graph<N> = Graphs.copyOf(this.undirected()).also { output ->
    this.nodes()
            .flatMap { node -> this.predecessors(node).toSet().twoSets() }
            .toSet()
            .map { it.toPair() }
            .forEach { pair ->
                output.putEdge(pair.first, pair.second)
            }
}

fun <E> Iterable<E>.forEachDiffentPair(f: (E, E) -> Unit): Unit =
        this.forEach { first ->
            this.forEach { second ->
                if (first != second) {
                    f(first, second)
                }
            }
        }

fun List<Factor>.pointwiseProduct(): Factor =
        this.reduce { acc, factor ->
            acc.pointwiseProduct(factor)
        }

fun List<MaxedOutFactor>.pointwiseProduct(): MaxedOutFactor =
        this.reduce { acc, maxedOutFactor ->
            acc.pointwiseProduct(maxedOutFactor)
        }

fun Factor.toMaxedOutFactor(): MaxedOutFactor =
        MaxedOutFactor(this as ProbabilityTable, this.values.map { emptyList<AssignmentProposition>() })

fun Node.makeFactor(observedEvidence: List<AssignmentProposition>): Factor {
    val node = this as? FiniteNode
            ?: throw IllegalArgumentException("This project only works with finite Nodes.")
    val evidence = observedEvidence.filter { node.cpt.contains(it.termVariable) }
    return node.cpt.getFactorFor(*evidence.toTypedArray())
}

fun <E> Set<E>.twoSets(): Set<TwoSet<E>> = this.flatMap { first ->
    this.filter { it != first }.map { second ->
        TwoSet(first, second)
    }.toSet()
}.toSet()

fun <E> List<List<E>>.combinations(): List<List<E>> = if (this.isEmpty()) {
    listOf(emptyList())
} else {
    this.first().flatMap { e ->
        this.drop(1).combinations().map { listOf(e) + it }
    }
}

fun BayesianNetwork.findRandomVariable(name: String): RandomVariable? =
        this.variablesInTopologicalOrder.find { it.name == name }
