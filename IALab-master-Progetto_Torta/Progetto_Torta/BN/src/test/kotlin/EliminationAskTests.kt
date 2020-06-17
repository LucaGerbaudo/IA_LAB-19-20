package org.devalot.ialab.torta

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.BayesianNetwork
import aima.core.probability.example.BayesNetExampleFactory
import aima.core.probability.proposition.AssignmentProposition
import org.devalot.ialab.torta.abstracts.EliminationAskTest
import org.devalot.ialab.torta.abstracts.FileTest
import org.devalot.ialab.torta.inference.util.findRandomVariable
import java.time.Duration

class `Elimination Ask on BurglaryAlarm network with alarm query and mary call evidence` : EliminationAskTest {
    override val bayesianNetwork: BayesianNetwork = BayesNetExampleFactory.constructBurglaryAlarmNetwork()
    override val queryVariables: (BayesianNetwork) -> List<RandomVariable> = {
        listOf(it.findRandomVariable("Alarm")!!)
    }
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("MaryCalls")!!, true))
    }
}

class `Elimination Ask on ToothacheWeather network with cavity query and toothache evidence` : EliminationAskTest {
    override val bayesianNetwork: BayesianNetwork = BayesNetExampleFactory.constructToothacheCavityCatchWeatherNetwork()
    override val queryVariables: (BayesianNetwork) -> List<RandomVariable> = {
        listOf(it.findRandomVariable("Cavity")!!)
    }
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("Toothache")!!, true))
    }
}

class `Elimination Ask on Insurance network with drivingSkill and antilock query and accident evidence` : FileTest("insurance"), EliminationAskTest {
    override val repetitions: Int
        get() = 1
    override val queryVariables: (BayesianNetwork) -> List<RandomVariable> = {
        listOf(it.findRandomVariable("DrivingSkill")!!, it.findRandomVariable("Antilock")!!)
    }
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("Accident")!!, "Severe"))
    }
}

class `Elimination Ask on Link network with n27_d_g query and d0_51_d_p evidence` : FileTest("link"), EliminationAskTest {
    override val repetitions: Int
        get() = 1
    override val queryVariables: (BayesianNetwork) -> List<RandomVariable> = {
        listOf(it.findRandomVariable("N27_d_g")!!)
    }
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("D0_51_d_p")!!, "a"))
    }
}

class `Elimination Ask on win95pts network with prtFile query and Problem3 evidence` : FileTest("win95pts"), EliminationAskTest {
    override val repetitions: Int
        get() = 1
    override val queryVariables: (BayesianNetwork) -> List<RandomVariable> = {
        listOf(it.findRandomVariable("PrtFile")!!)
    }
    override val evidence: (BayesianNetwork) -> List<AssignmentProposition> = {
        listOf(AssignmentProposition(it.findRandomVariable("Problem3")!!, "Yes"))
    }
}