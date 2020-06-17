package org.devalot.ialab.torta

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.example.BayesNetExampleFactory
import aima.core.probability.proposition.AssignmentProposition
import org.devalot.ialab.torta.abstracts.FileTest
import org.devalot.ialab.torta.abstracts.MAPAskTest
import org.devalot.ialab.torta.inference.util.findRandomVariable

class `MAP on BurglaryAlarm network with alarm query and mary call evidence` : MAPAskTest {
    override val bayesianNetwork: BayesianNetwork = BayesNetExampleFactory.constructBurglaryAlarmNetwork()
    override val queryVariables: (BayesianNetwork) -> List<RandomVariable> = {
        listOf(it.findRandomVariable("Alarm")!!)
    }
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("MaryCalls")!!, true))
    }
}

class `MAP on ToothacheWeather network with cavity query and toothache evidence` : MAPAskTest {
    override val bayesianNetwork: BayesianNetwork = BayesNetExampleFactory.constructToothacheCavityCatchWeatherNetwork()
    override val queryVariables: (BayesianNetwork) -> List<RandomVariable> = {
        listOf(it.findRandomVariable("Cavity")!!)
    }
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("Toothache")!!, true))
    }
}

class `MAP on Win95pts network with AppData DataFile query and Problem2 OK evidence` : FileTest("win95pts"), MAPAskTest {
    override val repetitions: Int
        get() = 100
    override val queryVariables: (BayesianNetwork) -> List<RandomVariable> = {
        listOf(it.findRandomVariable("AppData")!!, it.findRandomVariable("DataFile")!!)
    }
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("Problem2")!!, "OK"))
    }
}
