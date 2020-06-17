package org.devalot.ialab.torta.inference.util

import aima.core.probability.CategoricalDistribution
import aima.core.probability.RandomVariable
import aima.core.probability.bayes.DynamicBayesianNetwork
import aima.core.probability.bayes.approx.ParticleFiltering
import aima.core.probability.proposition.AssignmentProposition
import aima.core.probability.util.ProbabilityTable
import org.devalot.ialab.torta.inference.algorithms.DynamicQueryAlgorithm

class ParticleFilteringAdapter(private val sampleSize: Int) : DynamicQueryAlgorithm {
    override fun run(network: DynamicBayesianNetwork,
                     evidence: List<List<AssignmentProposition>>,
                     queryVariables: List<RandomVariable>): CategoricalDistribution {
        val original = ParticleFiltering(sampleSize, network)::particleFiltering
        val sampledAssignments = evidence.map {
            original(it.toTypedArray())
        }.last()
        return buildSample(sampledAssignments.map {
            it.map { a -> AssignmentProposition(network.x_1_to_X_0[a!!.termVariable]!!, a.value) }.toList()
        }, queryVariables)
    }

    private fun buildSample(S: List<List<AssignmentProposition>>, queryVariables: List<RandomVariable>): CategoricalDistribution {
        val probabilities = S.fold(emptyMap<List<Any>, Int>()) { acc, ass ->
            val assValues = ass.filter { queryVariables.contains(it.termVariable) }.map { it.value }
            acc + Pair(assValues, (acc[assValues] ?: 0) + 1)
        }.mapValues { it.value.toDouble() / S.size.toDouble() }
        val output = ProbabilityTable(*queryVariables.toTypedArray())
        probabilities.forEach { (assignments, prob) ->
            output.values[output.getIndex(*assignments.toTypedArray())] = prob
        }
        return output
    }
}
