package org.devalot.ialab.torta.abstracts

import org.devalot.ialab.torta.inference.BayesianVariableSorter
import org.devalot.ialab.torta.inference.IrrelevantVariablesFinder
import org.devalot.ialab.torta.inference.algorithms.MAPAsk
import org.devalot.ialab.torta.inference.algorithms.QueryAlgorithm

interface MAPAskTest : BayesianNetworkTest {
    override val algorithm: (BayesianVariableSorter, IrrelevantVariablesFinder) -> QueryAlgorithm<*>
        get() = ::MAPAsk
}
