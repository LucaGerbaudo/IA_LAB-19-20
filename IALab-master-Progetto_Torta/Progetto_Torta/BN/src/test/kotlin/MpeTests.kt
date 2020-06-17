package org.devalot.ialab.torta

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.example.BayesNetExampleFactory
import aima.core.probability.proposition.AssignmentProposition
import org.devalot.ialab.torta.abstracts.MpeTest
import org.devalot.ialab.torta.inference.util.findRandomVariable

class `MPE on BurglaryAlarm network with mary call evidence` : MpeTest {
    override val bayesianNetwork: BayesianNetwork = BayesNetExampleFactory.constructBurglaryAlarmNetwork()
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("MaryCalls")!!, true))
    }
}

class `MPE on ToothacheWeather network with toothache evidence` : MpeTest {
    override val bayesianNetwork: BayesianNetwork = BayesNetExampleFactory.constructToothacheCavityCatchWeatherNetwork()
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("Toothache")!!, true))
    }
}
