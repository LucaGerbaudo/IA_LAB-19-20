package org.devalot.ialab.torta.abstracts

import org.devalot.ialab.torta.inference.BayesianVariableSorter
import org.devalot.ialab.torta.inference.IrrelevantVariablesFinder
import org.devalot.ialab.torta.inference.algorithms.EliminationAsk
import org.devalot.ialab.torta.inference.algorithms.QueryAlgorithm

interface EliminationAskTest : BayesianNetworkTest {
    override val algorithm: (BayesianVariableSorter, IrrelevantVariablesFinder) -> QueryAlgorithm<*>
        get() = ::EliminationAsk
}
