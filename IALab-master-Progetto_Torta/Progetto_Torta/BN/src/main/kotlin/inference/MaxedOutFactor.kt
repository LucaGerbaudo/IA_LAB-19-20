package org.devalot.ialab.torta.inference

import aima.core.probability.RandomVariable
import aima.core.probability.domain.FiniteDomain
import aima.core.probability.proposition.AssignmentProposition
import aima.core.probability.util.ProbabilityTable

class MaxedOutFactor(val factor: ProbabilityTable, val assignments: List<List<AssignmentProposition>>) {
    fun maxOut(randomVariable: RandomVariable): MaxedOutFactor {
        val soutVars = factor.argumentVariables - randomVariable
        val output = ProbabilityTable(soutVars)
        val outputAssignments = output.values.map { emptyList<AssignmentProposition>() }.toMutableList()
        if (output.values.size == 1) { // DO I ACTUALLY NEED THIS?
            val max = factor.values.withIndex().maxBy { it.value }!!
            output.values[0] = max.value
            outputAssignments[0] = listOf(
                    AssignmentProposition(randomVariable,
                            (randomVariable.domain as FiniteDomain).getValueAt(max.index))
            ) + assignments[max.index]
        } else {
            factor.iterateOverTable { possibleAssignment, probability ->
                val index = output.getIndex(*output.argumentVariables.map { possibleAssignment[it]!! }.toTypedArray())
                if (output.values[index] < probability) {
                    output.values[index] = probability
                    outputAssignments[index] = assignments[
                            factor.getIndex(*factor.argumentVariables.map { possibleAssignment[it] }.toTypedArray())
                    ] + AssignmentProposition(randomVariable, possibleAssignment[randomVariable])
                }
            }
        }
        return MaxedOutFactor(output, outputAssignments)
    }

    fun pointwiseProduct(multiplier: MaxedOutFactor): MaxedOutFactor {
        val prodVarOrder: List<RandomVariable> = (factor.argumentVariables + multiplier.factor.argumentVariables).toList()
        val output = ProbabilityTable(*prodVarOrder.toTypedArray())
        val outputAssignment = output.values.map { emptyList<AssignmentProposition>() }.toMutableList()
        if (output.values.size == 1) { // DO I ACTUALLY NEED THIS?
            output.values[0] = factor.values[0] * multiplier.factor.values[0]
            outputAssignment[0] = assignments[0] + multiplier.assignments[0]
        } else {
            output.iterateOverTable { possibleAssignment, _ ->
                val term1index = factor.getIndex(*factor.argumentVariables.map { possibleAssignment[it] }.toTypedArray())
                val term2index = multiplier.factor.getIndex(*multiplier.factor.argumentVariables.map { possibleAssignment[it] }.toTypedArray())
                val outputIndex = output.getIndex(*output.argumentVariables.map { possibleAssignment[it] }.toTypedArray())
                output.values[outputIndex] = factor.values[term1index] * multiplier.factor.values[term2index]
                outputAssignment[outputIndex] = assignments[term1index] + multiplier.assignments[term2index]
            }
        }
        return MaxedOutFactor(output, outputAssignment)
    }

    override fun toString(): String =
            factor.values.zip(assignments).toString()

}