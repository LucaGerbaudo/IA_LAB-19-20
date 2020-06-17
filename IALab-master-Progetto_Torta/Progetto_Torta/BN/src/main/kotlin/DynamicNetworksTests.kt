package org.devalot.ialab.torta

import aima.core.probability.example.BayesNetExampleFactory
import aima.core.probability.example.DynamicBayesNetExampleFactory
import aima.core.probability.example.ExampleRV
import aima.core.probability.proposition.AssignmentProposition
import aima.core.probability.util.ProbabilityTable
import org.devalot.ialab.torta.inference.RandomGreedySorter
import org.devalot.ialab.torta.inference.algorithms.RollupFiltering
import org.devalot.ialab.torta.inference.util.*
import org.encog.ml.bayesian.bif.BIFUtil
import java.io.File
import java.lang.IllegalStateException

object DynamicNetworksTests {
    fun basicTestOnUmbrella() {
        val umbrella = DynamicBayesNetExampleFactory.getUmbrellaWorldNetwork()
        val assignments = (1..2).map { listOf(AssignmentProposition(ExampleRV.UMBREALLA_t_RV, true)) }
        val output = RollupFiltering().run(umbrella, assignments)
        BayesianNetworkPrinter.printProbabilityTableComparison(
                output as ProbabilityTable,
                ParticleFilteringAdapter(10000).run(umbrella, assignments) as ProbabilityTable
        )
    }

    fun longUmbrella() {
        val umbrella = DynamicBayesNetExampleFactory.getUmbrellaWorldNetwork()
        val assignments = (1..200).map { listOf(AssignmentProposition(ExampleRV.UMBREALLA_t_RV, true)) }
        val output = RollupFiltering().run(umbrella, assignments)
        BayesianNetworkPrinter.printProbabilityTableComparison(
                output as ProbabilityTable,
                ParticleFilteringAdapter(1000).run(umbrella, assignments) as ProbabilityTable
        )
    }

    fun convertInsurance() {
        val network =
                BayesianNetworkConverter.convert(
                        BIFUtil.readBIF(File(IALabTortaBN.javaClass.getResource("bifNets/insurance.xbif").toURI()))
                )
        val dN = BayesianNetworkDynamizer.dynamize(network,
                evidenceSelector = { rv ->
                    when (rv.name) {
                        "MedCost", "ILiCost", "PropCost" -> true
                        else -> false
                    }
                },
                transactionModelDescriptor = { rv ->
                    when (rv.name) {
                        "Age" -> Pair(listOf(network.findRandomVariable("Age")!!),
                                doubleArrayOf(0.79, 0.2, 0.01, 0.01, 0.89, 0.1, 0.01, 0.01, 0.98))
                        "Mileage" -> Pair(listOf(network.findRandomVariable("Mileage")!!),
                                doubleArrayOf(0.4, 0.4, 0.1, 0.1, 0.01, 0.4, 0.4, 0.19, 0.01, 0.01, 0.5, 0.48, 0.01, 0.01, 0.01, 0.97))
                        else -> Pair(emptyList(), network.getNode(rv).makeFactor(emptyList()).values)
                    }
                })
        val assList = listOf(
                listOf(
                        AssignmentProposition(network.findRandomVariable("MedCost"), "Thousand"),
                        AssignmentProposition(network.findRandomVariable("ILiCost"), "TenThou"),
                        AssignmentProposition(network.findRandomVariable("PropCost"), "Thousand")
                ),
                listOf(
                        AssignmentProposition(network.findRandomVariable("MedCost"), "Thousand"),
                        AssignmentProposition(network.findRandomVariable("ILiCost"), "Thousand"),
                        AssignmentProposition(network.findRandomVariable("PropCost"), "Thousand")
                ),
                listOf(
                        AssignmentProposition(network.findRandomVariable("MedCost"), "TenThou"),
                        AssignmentProposition(network.findRandomVariable("ILiCost"), "HundredThou"),
                        AssignmentProposition(network.findRandomVariable("PropCost"), "TenThou")
                ),
                listOf(
                        AssignmentProposition(network.findRandomVariable("MedCost"), "Thousand"),
                        AssignmentProposition(network.findRandomVariable("ILiCost"), "Thousand"),
                        AssignmentProposition(network.findRandomVariable("PropCost"), "Thousand")
                ),
                listOf(
                        AssignmentProposition(network.findRandomVariable("MedCost"), "Thousand"),
                        AssignmentProposition(network.findRandomVariable("ILiCost"), "TenThou"),
                        AssignmentProposition(network.findRandomVariable("PropCost"), "Thousand")
                )
        )
        BayesianNetworkPrinter.printProbabilityTable(RollupFiltering(RandomGreedySorter).run(dN,
                assList, listOf(network.findRandomVariable("Age")!!)) as ProbabilityTable)
    }

    fun convertedBurglary() {
        val network = BayesNetExampleFactory.constructBurglaryAlarmNetwork()
        val dN = BayesianNetworkDynamizer.dynamize(network,
                evidenceSelector = { rv ->
                    rv == ExampleRV.MARY_CALLS_RV || rv == ExampleRV.JOHN_CALLS_RV
                },
                transactionModelDescriptor = { rv ->
                    when (rv) {
                        ExampleRV.ALARM_RV -> Pair(emptyList(), network.getNode(rv).makeFactor(emptyList()).values)
                        ExampleRV.BURGLARY_RV -> Pair(listOf(ExampleRV.BURGLARY_RV, ExampleRV.EARTHQUAKE_RV),
                                doubleArrayOf(0.0005, 0.9995, 0.0001, 0.9999, 0.05, 0.95, 0.001, 0.999))
                        ExampleRV.EARTHQUAKE_RV -> Pair(listOf(ExampleRV.EARTHQUAKE_RV),
                                doubleArrayOf(0.7, 0.3, 0.002, 0.998))
                        else -> throw IllegalStateException()
                    }
                })
        val assList = listOf(
                listOf(
                        AssignmentProposition(ExampleRV.MARY_CALLS_RV, false),
                        AssignmentProposition(ExampleRV.JOHN_CALLS_RV, false)
                ),
                listOf(
                        AssignmentProposition(ExampleRV.MARY_CALLS_RV, true),
                        AssignmentProposition(ExampleRV.JOHN_CALLS_RV, false)
                ),
                listOf(
                        AssignmentProposition(ExampleRV.MARY_CALLS_RV, true),
                        AssignmentProposition(ExampleRV.JOHN_CALLS_RV, true)
                ),
                listOf(
                        AssignmentProposition(ExampleRV.MARY_CALLS_RV, false),
                        AssignmentProposition(ExampleRV.JOHN_CALLS_RV, true)
                )
        )
        BayesianNetworkPrinter.printProbabilityTableComparison(
                RollupFiltering(RandomGreedySorter).run(dN,
                        assList) as ProbabilityTable,
                ParticleFilteringAdapter(10000).run(dN,
                        assList) as ProbabilityTable
        )
    }

    fun rainWindNet() {
        BayesianNetworkPrinter.printProbabilityTableComparison(
                RollupFiltering().run(RainWindNetBuilder.build(),
                        (1..20).map { listOf(AssignmentProposition(ExampleRV.UMBREALLA_t_RV, true)) }
                ) as ProbabilityTable,
                ParticleFilteringAdapter(10000).run(RainWindNetBuilder.build(),
                        (1..20).map { listOf(AssignmentProposition(ExampleRV.UMBREALLA_t_RV, true)) }
                ) as ProbabilityTable
        )
    }
}