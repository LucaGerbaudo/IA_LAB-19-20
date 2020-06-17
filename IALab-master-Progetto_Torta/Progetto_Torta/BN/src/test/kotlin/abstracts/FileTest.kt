package org.devalot.ialab.torta.abstracts

import aima.core.probability.bayes.BayesianNetwork
import org.devalot.ialab.torta.IALabTortaBNTest
import org.devalot.ialab.torta.inference.util.BayesianNetworkConverter
import org.encog.ml.bayesian.bif.BIFUtil
import java.io.File

abstract class FileTest(resourceName: String) : BayesianNetworkTest {
    override val bayesianNetwork: BayesianNetwork =
            BayesianNetworkConverter.convert(
                    BIFUtil.readBIF(File(IALabTortaBNTest.javaClass.getResource("bifNets/$resourceName.xbif").toURI()))
            )
}