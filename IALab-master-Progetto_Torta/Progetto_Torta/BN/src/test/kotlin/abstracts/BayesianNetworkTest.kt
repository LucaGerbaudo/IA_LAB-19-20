package org.devalot.ialab.torta.abstracts

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.proposition.AssignmentProposition
import org.devalot.ialab.torta.inference.BayesianVariableSorter
import org.devalot.ialab.torta.inference.IrrelevantVariablesFinder
import org.devalot.ialab.torta.inference.ProjectIrrelevantFinder
import org.devalot.ialab.torta.inference.RandomGreedySorter
import org.devalot.ialab.torta.inference.algorithms.QueryAlgorithm
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test
import java.time.Duration

interface BayesianNetworkTest {
    val bayesianNetwork: BayesianNetwork
    val queryVariables: (BayesianNetwork) -> List<RandomVariable>
    val evidence: (BayesianNetwork) -> List<AssignmentProposition>
    val repetitions: Int
        get() = 100
    val timeout: Duration
        get() = Duration.ofSeconds(3)
    val algorithm: (BayesianVariableSorter, IrrelevantVariablesFinder) -> QueryAlgorithm<*>

    @Test()
    fun `with no sorting and with all irrelevant variables`() {
        algorithm(BayesianVariableSorter.default, IrrelevantVariablesFinder.default).run()
    }

    @Test
    fun `with random greedy sorter and with all irrelevant variables`() {
        algorithm(RandomGreedySorter, IrrelevantVariablesFinder.default).run()
    }

    @Test
    fun `with no sorting and with pruning`() {
        algorithm(BayesianVariableSorter.default, ProjectIrrelevantFinder).run()
    }

    @Test
    fun `with random greedy sorter and with pruning`() {
        algorithm(RandomGreedySorter, ProjectIrrelevantFinder).run()
    }

    private fun QueryAlgorithm<*>.run() {
        assertTimeoutPreemptively(timeout) {
            val output = (1..repetitions).fold(null as Any?) { _, _ ->
                this.ask(queryVariables(bayesianNetwork), evidence(bayesianNetwork), bayesianNetwork)
            }
            println("Result: $output")
        }
    }

}
