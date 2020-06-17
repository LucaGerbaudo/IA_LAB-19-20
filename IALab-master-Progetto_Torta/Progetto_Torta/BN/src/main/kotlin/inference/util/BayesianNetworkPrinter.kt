package org.devalot.ialab.torta.inference.util

import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.bayes.Node
import aima.core.probability.domain.FiniteDomain
import aima.core.probability.util.ProbabilityTable

object BayesianNetworkPrinter {
    fun print(bayesianNetwork: BayesianNetwork) {
        bayesianNetwork.variablesInTopologicalOrder.map { bayesianNetwork.getNode(it) }.forEach {
            printNode(it)
        }
    }

    fun printNode(node: Node) {
        val nodeInfo = "Node: $node | " + if (node.parents.isNotEmpty()) {
            "${node.parents.joinToString(", ")} --> "
        } else {
            ""
        }
        println(nodeInfo)
        println("Domain: ${(node.randomVariable.domain as FiniteDomain).possibleValues.joinToString(",")}")
        printNodeTable(node)
    }

    fun printProbabilityTable(table: ProbabilityTable) {
        val parentValues = table.argumentVariables.map { it.domain as FiniteDomain }.map { it.possibleValues.toList() }
        parentValues.combinations().forEach { values ->
            println(if (values.isNotEmpty()) {
                "${values.zip(table.argumentVariables) { v, arg ->
                    "$arg=$v"
                }.joinToString(",")} -> "
            } else {
                ""
            } + " | ${
            table.getValue(*values.toTypedArray())}")
        }
    }

    fun printProbabilityTableComparison(table1: ProbabilityTable, table2: ProbabilityTable) {
        val parentValues = table1.argumentVariables.map { it.domain as FiniteDomain }.map { it.possibleValues.toList() }
        parentValues.combinations().forEach { values ->
            println(if (values.isNotEmpty()) {
                "${values.zip(table1.argumentVariables) { v, arg ->
                    "$arg=$v"
                }.joinToString(",")} -> "
            } else {
                ""
            } + " | ${table1.getValue(*values.toTypedArray())} | ${table2.getValue(*values.toTypedArray())}")
        }
    }

    private fun printNodeTable(node: Node) {
        val parentValues = node.parents.map { it.randomVariable.domain as FiniteDomain }.map { it.possibleValues.toList() }
        parentValues.combinations().forEach { values ->
            (node.randomVariable.domain as FiniteDomain).possibleValues.forEach { value ->
                println(if (values.isNotEmpty()) {
                    "${values.joinToString(",")} -> "
                } else {
                    ""
                } + "$value | ${
                node.cpd.getValue(*values.toTypedArray(), value)}")
            }
        }
    }
}