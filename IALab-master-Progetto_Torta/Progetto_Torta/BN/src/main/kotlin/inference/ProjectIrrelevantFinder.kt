package org.devalot.ialab.torta.inference

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.bayes.Node
import aima.core.probability.proposition.AssignmentProposition
import inference.MReductor

object ProjectIrrelevantFinder : IrrelevantVariablesFinder {
    override fun findIrrelevantVariables(
            queryVariables: List<RandomVariable>,
            observedEvidence: List<AssignmentProposition>,
            bayesianNetwork: BayesianNetwork): Set<RandomVariable> =
            getEvidenceVariableSet(observedEvidence).let { evidenceVariables ->
                bayesianNetwork.variablesInTopologicalOrder - findRelevantVariables(queryVariables.toSet(), evidenceVariables, bayesianNetwork)
            }.toSet()


    private fun findRelevantVariables(
            queryVariables: Set<RandomVariable>,
            evidenceVariables: Set<RandomVariable>,
            bayesianNetwork: BayesianNetwork
    ): Collection<RandomVariable> =
            (queryVariables
                    + queryVariables.flatMap { getAncestor(bayesianNetwork.getNode(it)) }.map { it.randomVariable }
                    + evidenceVariables
                    + evidenceVariables.flatMap { getAncestor(bayesianNetwork.getNode(it)) }.map { it.randomVariable }
                    ).intersect(MReductor.reduce(queryVariables, evidenceVariables, bayesianNetwork) + evidenceVariables)

    private fun getAncestor(node: Node): Set<Node> = node.parents + node.parents.flatMap { getAncestor(it) }

    private fun getEvidenceVariableSet(e: List<AssignmentProposition>) = e.toSet().flatMap { it.scope }.toSet()

}
