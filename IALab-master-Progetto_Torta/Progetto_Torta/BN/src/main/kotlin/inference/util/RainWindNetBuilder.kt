package org.devalot.ialab.torta.inference.util

import aima.core.probability.RandomVariable
import aima.core.probability.bayes.DynamicBayesianNetwork
import aima.core.probability.domain.BooleanDomain
import aima.core.probability.util.RandVar
import aima.core.probability.bayes.impl.DynamicBayesNet
import aima.core.probability.example.ExampleRV
import java.util.HashSet
import java.util.HashMap
import aima.core.probability.bayes.impl.FullCPTNode
import aima.core.probability.bayes.impl.BayesNet

object RainWindNetBuilder {
    val WIND_tm1_RV = RandVar("Wind_t-1",
            BooleanDomain())
    val WIND_t_RV = RandVar("Wind_t",
            BooleanDomain())

    fun build(): DynamicBayesianNetwork {
        val prior_rain_tm1 = FullCPTNode(ExampleRV.RAIN_tm1_RV,
                doubleArrayOf(0.5, 0.5))
        val prior_wind_tm1 = FullCPTNode(WIND_tm1_RV,
                doubleArrayOf(0.5, 0.5))

        val priorNetwork = BayesNet(prior_rain_tm1, prior_wind_tm1)

        // Prior belief state
        val rain_tm1 = FullCPTNode(ExampleRV.RAIN_tm1_RV,
                doubleArrayOf(0.5, 0.5))
        val wind_tm1 = FullCPTNode(WIND_tm1_RV,
                doubleArrayOf(0.5, 0.5))


        // Transition Model
        val rain_t = FullCPTNode(ExampleRV.RAIN_t_RV, doubleArrayOf(
                // R_t-1 = true, W_t-1 = true, R_t = true
                0.6,
                // R_t-1 = true, W_t-1 = true, R_t = false
                0.4,
                // R_t-1 = true, W_t-1 = false, R_t = true
                0.8,
                // R_t-1 = true, W_t-1 = false, R_t = false
                0.2,
                // R_t-1 = false, W_t-1 = true, R_t = true
                0.4,
                // R_t-1 = false, W_t-1 = true, R_t = false
                0.6,
                // R_t-1 = false, W_t-1 = false, R_t = true
                0.2,
                // R_t-1 = false, W_t-1 = false, R_t = false
                0.8), rain_tm1, wind_tm1)

        val wind_t = FullCPTNode(WIND_t_RV, doubleArrayOf(
                // W_t-1 = true, W_t = true
                0.7,
                // W_t-1 = true, W_t = false
                0.3,
                // W_t-1 = false, W_t = true
                0.3,
                // W_t-1 = false, W_t = false
                0.7), wind_tm1)

        // Sensor Model
        val umbrealla_t = FullCPTNode(ExampleRV.UMBREALLA_t_RV,
                doubleArrayOf(
                        // R_t = true, U_t = true
                        0.9,
                        // R_t = true, U_t = false
                        0.1,
                        // R_t = false, U_t = true
                        0.2,
                        // R_t = false, U_t = false
                        0.8), rain_t)

        val X_0_to_X_1 = HashMap<RandomVariable, RandomVariable>()
        X_0_to_X_1[ExampleRV.RAIN_tm1_RV] = ExampleRV.RAIN_t_RV
        X_0_to_X_1[WIND_tm1_RV] = ExampleRV.RAIN_t_RV
        X_0_to_X_1[WIND_tm1_RV] = WIND_t_RV
        val E_1 = HashSet<RandomVariable>()
        E_1.add(ExampleRV.UMBREALLA_t_RV)
        return DynamicBayesNet(priorNetwork, X_0_to_X_1, E_1, rain_tm1, wind_tm1)
    }

}