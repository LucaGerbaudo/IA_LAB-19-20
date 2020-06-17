package org.devalot.ialab.torta.abstracts

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork

interface MpeTest : MAPAskTest {
    override val queryVariables: (BayesianNetwork) -> List<RandomVariable>
        get() = { bn ->
            bn.variablesInTopologicalOrder - evidence(bn).map { it.termVariable }
        }
}
