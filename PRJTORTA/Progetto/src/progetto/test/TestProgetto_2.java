package progetto.test;

import probability.CategoricalDistribution;
import probability.RandomVariable;
import probability.bayes.BayesianNetwork;
import probability.bayes.exact.EliminationAsk;
import probability.domain.ArbitraryTokenDomain;
import probability.example.ExampleRV;
import probability.proposition.AssignmentProposition;
import progetto.UmbrellaParticle;
import progetto.dynamic_networks.MyEliminationAskRollupFiltering;
import progetto.pruning.Pruning;
import progetto.dynamic_networks.ExamplesDBN;
import progetto.dynamic_networks.MyDynamicBayesianNetwork;
import progetto.ordinamenti.MinDegreeOrder;
import progetto.ordinamenti.MinFillOrder;

import java.util.*;
import java.util.concurrent.TimeUnit;

public class TestProgetto_2 {
    public static void main(String[] args) { test4(); }

    /**
     * Esecuzione test con i 3 ordinamenti e con/senza pruning
     * @param irrilevant -> 0 : nessun pruning, 1 : irrilevanti ancestor, 2 : irrilevanti moralgraph, 3 : archi irrilevanti
     */
    public static void runTest(MyDynamicBayesianNetwork bn, RandomVariable [] qrv, AssignmentProposition [][] ap, Map<String,RandomVariable> rvsmap, int irrilevant) {
        System.out.println("Query Variable : " + Arrays.asList(qrv).toString());
        System.out.println("Evidence : " + Arrays.asList(ap[0]).toString());

        MyEliminationAskRollupFiltering myEliminationAsk = new MyEliminationAskRollupFiltering();
        System.out.println("Query con ordine topologico inverso");
        CategoricalDistribution cd = myEliminationAsk.eliminationAskRollupFiltering(qrv, ap, bn, rvsmap, bn.getVariablesInTopologicalOrder(),irrilevant);

        System.out.println("Simple query con MinDegreeOrder");
        cd = myEliminationAsk.eliminationAskRollupFiltering(qrv, ap, bn, rvsmap, MinDegreeOrder.minDegreeOrder(bn),irrilevant);

        System.out.println("Simple query con MinFillOrder");
        cd = myEliminationAsk.eliminationAskRollupFiltering(qrv, ap, bn, rvsmap, MinFillOrder.minFillOrder(bn),irrilevant);
    }

    /**
     * Test confronto con ParticleFiltering su Umbrella
     */
    public static void test1() {
        Random rn = new Random();
        int max = 1; int min = 0;

        MyDynamicBayesianNetwork bn = ExamplesDBN.getRainWindNet();
        Map<String, RandomVariable> rvsmap = new HashMap<>();

        for (RandomVariable var: bn.getVariablesInTopologicalOrder()) {
            rvsmap.put(var.getName(), var);
        }

        AssignmentProposition[][] aps = null;
        int m = 5;
        if (m > 0) {
            aps = new AssignmentProposition[m][1];
            for (int i = 0; i < m; i++) {
                aps[i][0] = new AssignmentProposition(ExampleRV.UMBREALLA_t_RV, Boolean.TRUE);
            }
        }

        RandomVariable[] X;
        System.out.println("Stato Rain, Wind");
        X = new RandomVariable[] { ExampleRV.RAIN_t_RV, UmbrellaParticle.WIND_t_RV };
        runTest(bn, X, aps , rvsmap, 0);
    }



    /**
     * Test relazione pag 10
     */
    public static void test2() {
        Random rn = new Random();
        int max = 1; int min = 0;

        MyDynamicBayesianNetwork bn = ExamplesDBN.getDynamicAlarmNet();
        Map<String, RandomVariable> rvsmap = new HashMap<>();

        for (RandomVariable var: bn.getVariablesInTopologicalOrder()) {
            rvsmap.put(var.getName(), var);
        }

        AssignmentProposition[][] aps = null;
        int m = 5;
        if (m > 0) {
            aps = new AssignmentProposition[m][2];
            for (int i = 0; i < m; i++) {
                aps[i][0] = new AssignmentProposition(ExampleRV.JOHN_CALLS_RV, (rn.nextInt((max - min) + 1) + min)==0 ? Boolean.FALSE : Boolean.TRUE);
                aps[i][1] = new AssignmentProposition(ExampleRV.MARY_CALLS_RV, (rn.nextInt((max - min) + 1) + min)==0 ? Boolean.FALSE : Boolean.TRUE);
            }
        }

        RandomVariable[] X;
        System.out.println("Stato Burglary, Earthquake, Alarm");
        X = new RandomVariable[] { ExampleRV.BURGLARY_RV, ExampleRV.EARTHQUAKE_RV, ExampleRV.ALARM_RV };
        runTest(bn, X, aps , rvsmap, 0);
    }

    /**
     * Test relazione pag 10
     */
    public static void test3() {
        Random rn = new Random();
        int max = 1; int min = 0;

        MyDynamicBayesianNetwork bn = ExamplesDBN.getInsuranceNetwork();
        Map<String, RandomVariable> rvsmap = new HashMap<>();

        for (RandomVariable var: bn.getVariablesInTopologicalOrder()) {
            rvsmap.put(var.getName(), var);
        }

        AssignmentProposition[][] aps = null;
        int m = 5;
        if (m > 0) {
            aps = new AssignmentProposition[m][3];
            for (int i = 0; i < m; i++) {
                aps[i][0] = new AssignmentProposition(rvsmap.get("MedCost"), ((ArbitraryTokenDomain)rvsmap.get("MedCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("MedCost").getDomain().size()-1 - min) + 1) + min]);
                aps[i][1] = new AssignmentProposition(rvsmap.get("ILiCost"), ((ArbitraryTokenDomain)rvsmap.get("ILiCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("ILiCost").getDomain().size()-1 - min) + 1) + min]);
                aps[i][2] = new AssignmentProposition(rvsmap.get("PropCost"), ((ArbitraryTokenDomain)rvsmap.get("PropCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("PropCost").getDomain().size()-1 - min) + 1) + min]);
            }
        }

        RandomVariable[] X;
        System.out.println("Stato Age");
        X = new RandomVariable[] { rvsmap.get("Age") };
        runTest(bn, X, aps , rvsmap, 0);
    }

    /**
     * Test relazione pag 11
     */
    public static void test4() {
        Random rn = new Random();
        int max = 1; int min = 0;

        MyDynamicBayesianNetwork bn = ExamplesDBN.getInsuranceNetwork();
        Map<String, RandomVariable> rvsmap = new HashMap<>();

        for (RandomVariable var: bn.getVariablesInTopologicalOrder()) {
            rvsmap.put(var.getName(), var);
        }

        AssignmentProposition[][] aps = null;
        int m = 5;
        if (m > 0) {
            aps = new AssignmentProposition[m][3];
            for (int i = 0; i < m; i++) {
                aps[i][0] = new AssignmentProposition(rvsmap.get("MedCost"), ((ArbitraryTokenDomain)rvsmap.get("MedCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("MedCost").getDomain().size()-1 - min) + 1) + min]);
                aps[i][1] = new AssignmentProposition(rvsmap.get("ILiCost"), ((ArbitraryTokenDomain)rvsmap.get("ILiCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("ILiCost").getDomain().size()-1 - min) + 1) + min]);
                aps[i][2] = new AssignmentProposition(rvsmap.get("PropCost"), ((ArbitraryTokenDomain)rvsmap.get("PropCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("PropCost").getDomain().size()-1 - min) + 1) + min]);
            }
        }

        RandomVariable[] X;
        System.out.println("Stato Age, MakeModel, CarValue");
        X = new RandomVariable[] { rvsmap.get("Age"), rvsmap.get("MakeModel"), rvsmap.get("CarValue") };
        runTest(bn, X, aps , rvsmap, 0);
    }

    /**
     * Test
     */
    public static void test5() {
        Random rn = new Random();
        int max = 1; int min = 0;

        MyDynamicBayesianNetwork bn = ExamplesDBN.getInsuranceNetworkMoreEvidences();
        Map<String, RandomVariable> rvsmap = new HashMap<>();

        for (RandomVariable var: bn.getVariablesInTopologicalOrder()) {
            rvsmap.put(var.getName(), var);
        }

        AssignmentProposition[][] aps = null;
        int m = 5;
        if (m > 0) {
            aps = new AssignmentProposition[m][6];
            for (int i = 0; i < m; i++) {
                aps[i][0] = new AssignmentProposition(rvsmap.get("MedCost"), ((ArbitraryTokenDomain)rvsmap.get("MedCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("MedCost").getDomain().size()-1 - min) + 1) + min]);
                aps[i][1] = new AssignmentProposition(rvsmap.get("ILiCost"), ((ArbitraryTokenDomain)rvsmap.get("ILiCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("ILiCost").getDomain().size()-1 - min) + 1) + min]);
                aps[i][2] = new AssignmentProposition(rvsmap.get("PropCost"), ((ArbitraryTokenDomain)rvsmap.get("PropCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("PropCost").getDomain().size()-1 - min) + 1) + min]);
                aps[i][3] = new AssignmentProposition(rvsmap.get("Theft"), ((ArbitraryTokenDomain)rvsmap.get("Theft").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("Theft").getDomain().size()-1 - min) + 1) + min]);
                aps[i][4] = new AssignmentProposition(rvsmap.get("HomeBase"), ((ArbitraryTokenDomain)rvsmap.get("HomeBase").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("HomeBase").getDomain().size()-1 - min) + 1) + min]);
                aps[i][5] = new AssignmentProposition(rvsmap.get("OtherCarCost"), ((ArbitraryTokenDomain)rvsmap.get("OtherCarCost").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("OtherCarCost").getDomain().size()-1 - min) + 1) + min]);
            }
        }

        RandomVariable[] X;
        System.out.println("Stato Age, MakeModel, CarValue");
        X = new RandomVariable[] { rvsmap.get("Age"), rvsmap.get("MakeModel"), rvsmap.get("CarValue") };
        runTest(bn, X, aps , rvsmap, 2);
    }
}
