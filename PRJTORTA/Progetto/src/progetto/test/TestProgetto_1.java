package progetto.test;

import bnparser.BifReader;
import probability.CategoricalDistribution;
import probability.RandomVariable;
import probability.bayes.BayesianNetwork;
import probability.bayes.exact.EliminationAsk;
import probability.domain.ArbitraryTokenDomain;
import probability.proposition.AssignmentProposition;
import progetto.ordinamenti.MinDegreeOrder;
import progetto.ordinamenti.MinFillOrder;
import progetto.pruning.Pruning;

import java.util.*;
import java.util.concurrent.TimeUnit;

public class TestProgetto_1 {

    public static void main(String[] args) {
        test7();
    }

    public static void runTest(BayesianNetwork bn, RandomVariable [] qrv, AssignmentProposition [] ap, HashMap<String, RandomVariable> rvsmap, boolean irrilevant1, boolean irrilevant2, boolean irrilevant3) {
        System.out.println("Query Variable : " + Arrays.asList(qrv).toString());
        System.out.println("Evidence : " + Arrays.asList(ap).toString());

        /*********************************************** Nodi irrilevanti ********************************************/

        System.out.println("Nodi irrilevanti ancestors : " + irrilevant1);
        if(irrilevant1) Pruning.nodiIrrilevanti1(bn, qrv, ap);

        /***************************************** Nodi irrilevanti Moral Graph *****************************/

        System.out.println("Nodi irrilevanti moralgraph : " + irrilevant2);
        if(irrilevant2) Pruning.nodiIrrilevantiMoralGraph(bn, qrv, ap);

        /************************************************* Archi irrilevanti********************************************/

        System.out.println("Archi irrilevanti : " + irrilevant3);
        if(irrilevant3) Pruning.archiIrrilevanti(bn, ap);

        /******************************************* V.E. con ORDINAMENTI ************************************************************/

        runTestRusselNorvig(bn, qrv, ap);

        // Topologico Inverso e V.E di Dalwiche
        EliminationAsk eliminationAsk = new EliminationAsk();
        System.out.println("Simple query con " + eliminationAsk.getClass());
        long startTime = System.nanoTime();
        List<RandomVariable> order = new ArrayList<>(bn.getVariablesInTopologicalOrder());
        Collections.reverse(order);
        CategoricalDistribution cd = eliminationAsk.eliminationAsk(bn, qrv, ap, order);
        long stopTime = System.nanoTime();
        System.out.println(cd + ": " + TimeUnit.MILLISECONDS.convert((stopTime - startTime), TimeUnit.NANOSECONDS));

        // MinDegree
        System.out.println("Simple query con MinDegreeOrder");
        startTime = System.nanoTime();
        order = MinDegreeOrder.minDegreeOrder(bn);
        cd = eliminationAsk.eliminationAsk(bn, qrv, ap, order);
        stopTime = System.nanoTime();
        System.out.println(cd + ": " + TimeUnit.MILLISECONDS.convert((stopTime - startTime), TimeUnit.NANOSECONDS));
        System.out.println("MinDegreeOrder : " + order);

        // MinFill
        startTime = System.nanoTime();
        order = MinFillOrder.minFillOrder(bn);
        System.out.println("Simple query con MinFillOrder");
        cd = eliminationAsk.eliminationAsk(bn, qrv, ap, order);
        stopTime = System.nanoTime();
        System.out.println(cd + ": " + TimeUnit.MILLISECONDS.convert((stopTime - startTime), TimeUnit.NANOSECONDS));
        System.out.println("MinFillOrder : " + order);
    }

     /**
     * Test su V.E. di Russel e Norvig con ordinamento topologico inverso
     */
    static void runTestRusselNorvig(BayesianNetwork bn, RandomVariable [] qrv, AssignmentProposition [] ap) {
        // Topologico Inverso
        EliminationAsk eliminationAsk = new EliminationAsk();
        System.out.println("[Russel&Norvig] Simple query con " + eliminationAsk.getClass());
        long startTime = System.nanoTime();
        CategoricalDistribution cd = eliminationAsk.eliminationAsk(qrv, ap, bn);
        long stopTime = System.nanoTime();
        System.out.println(cd + ": " + TimeUnit.MILLISECONDS.convert((stopTime - startTime), TimeUnit.NANOSECONDS));
    }


    /***********************************************************************************************************/

    /**
     * Semplice test1 Asia
     * Usando l'algoritmo irrilevanti_ancestor, con meno evidenze troviamo più nodi
     */
    public static void test1() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/asia.xml");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Asia");

        AssignmentProposition[] ap = new AssignmentProposition[1];
        ap[0] = new AssignmentProposition(rvsmap.get("Either"), "Yes");
        runTest(bn,qrv,ap,rvsmap, true, true, true);
    }

    /**
     * Semplice test2 Asia
     * Proviamo con più evidenze, i metodi nodi_irrilevanti con moralgraph e archi irrilevanti sono ora più efficienti
     */
    public static void test2() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/asia.xml");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Asia");

        AssignmentProposition[] ap = new AssignmentProposition[2];
        ap[0] = new AssignmentProposition(rvsmap.get("Lung"), "Yes");
        ap[1] = new AssignmentProposition(rvsmap.get("Bronc"), "Yes");
        runTest(bn,qrv,ap,rvsmap, false, true, true);
    }


    /**
     * Qui mettiamo in evidenza le prestazioni degli ordinamenti
     * Quello di russel e norvig classico è notevolemente peggiore dei 2 implementati con l'algortimo di Darviche
     */
    public static void test3() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Age");

        AssignmentProposition[] ap = new AssignmentProposition[1];
        ap[0] = new AssignmentProposition(rvsmap.get("MedCost"), "Thousand");
        runTest(bn,qrv,ap,rvsmap, false, false, false);
    }

    /**
     * Poche evidenze e rete di grandi dimensioni, i pruning non sono efficienti a parte il primo degli ancestor
     */
    public static void test4() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Age");

        AssignmentProposition[] ap = new AssignmentProposition[1];
        ap[0] = new AssignmentProposition(rvsmap.get("MedCost"), "Thousand");
        runTest(bn,qrv,ap,rvsmap, false, true, true);
    }

    /**
     * Più evidenze -> tempo inferenza minore
     */
    public static void test5() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Age");

        AssignmentProposition[] ap = new AssignmentProposition[4];
        ap[0] = new AssignmentProposition(rvsmap.get("MakeModel"), "SportsCar");
        ap[1] = new AssignmentProposition(rvsmap.get("Mileage"), "FiveThou");
        ap[2] = new AssignmentProposition(rvsmap.get("HomeBase"), "Suburb");
        ap[3] = new AssignmentProposition(rvsmap.get("PropCost"), "Million");
        runTest(bn,qrv,ap,rvsmap, false, true, true);
    }

    /**
     * Esempio relazione pag. 3, 7
     */
    public static void test6() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Cushioning");


        AssignmentProposition[] ap = new AssignmentProposition[6];
        ap[0] = new AssignmentProposition(rvsmap.get("ThisCarDam"), "Mild");
        ap[1] = new AssignmentProposition(rvsmap.get("MedCost"), "Thousand");
        ap[2] = new AssignmentProposition(rvsmap.get("ILiCost"), "Thousand");
        ap[3] = new AssignmentProposition(rvsmap.get("OtherCarCost"), "Thousand");
        ap[4] = new AssignmentProposition(rvsmap.get("ThisCarCost"), "Thousand");
        ap[5] = new AssignmentProposition(rvsmap.get("Theft"), "False");
        runTest(bn,qrv,ap,rvsmap, false, false, false);
    }

    /**
     * Esempio relazione pag. 4
     */
    public static void test7() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Age");


        AssignmentProposition[] ap = new AssignmentProposition[2];
        ap[0] = new AssignmentProposition(rvsmap.get("SocioEcon"), "Prole");
        ap[1] = new AssignmentProposition(rvsmap.get("GoodStudent"), "True");
        runTest(bn,qrv,ap,rvsmap, true, false, false);
    }

    /**
     * Test
     */
    public static void test8() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("MakeModel");

        Random rn = new Random(); int min = 0;
        AssignmentProposition[] ap = new AssignmentProposition[3];
        ap[0] = new AssignmentProposition(rvsmap.get("Age"),((ArbitraryTokenDomain)rvsmap.get("Age").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("Age").getDomain().size()-1 - min) + 1) + min]);
        ap[1] = new AssignmentProposition(rvsmap.get("SocioEcon"), ((ArbitraryTokenDomain)rvsmap.get("SocioEcon").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("SocioEcon").getDomain().size()-1 - min) + 1) + min]);
        ap[2] = new AssignmentProposition(rvsmap.get("RiskAversion"), ((ArbitraryTokenDomain)rvsmap.get("RiskAversion").getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get("RiskAversion").getDomain().size()-1 - min) + 1) + min]);
        runTest(bn,qrv,ap,rvsmap, false, false, true);
    }

    /**
     * Test
     */
    public static void test8bis() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Age");

        Random rn = new Random(); int min = 0;
        String [] evidenze = new String[]{"MedCost", "ILiCost", "PropCost"};

        AssignmentProposition[] ap = new AssignmentProposition[evidenze.length];
        for (int i = 0; i < evidenze.length; i++) {
            ap[i] = new AssignmentProposition(rvsmap.get(evidenze[i]),((ArbitraryTokenDomain)rvsmap.get(evidenze[i]).getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get(evidenze[i]).getDomain().size()-1 - min) + 1) + min]);
        }

        runTest(bn,qrv,ap,rvsmap, true, false, false);
    }


    /**
     * Test relazione pag. 4
     */
    public static void test9() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("polyTree50nodes.xml");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Node10");

        Random rn = new Random(); int min = 0;
        String [] evidenze = new String[]{"Node15", "Node48"};

        AssignmentProposition[] ap = new AssignmentProposition[evidenze.length];
        for (int i = 0; i < evidenze.length; i++) {
            ap[i] = new AssignmentProposition(rvsmap.get(evidenze[i]),((ArbitraryTokenDomain)rvsmap.get(evidenze[i]).getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get(evidenze[i]).getDomain().size()-1 - min) + 1) + min]);
        }

        runTest(bn,qrv,ap,rvsmap, true, false, false);
    }

    /**
     * Test relazione pag.7
     */
    public static void test10() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("polyTree50nodes.xml");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Node10");

        Random rn = new Random(); int min = 0;
        String [] evidenze = new String[]{"Node15", "Node48"};

        AssignmentProposition[] ap = new AssignmentProposition[evidenze.length];
        for (int i = 0; i < evidenze.length; i++) {
            ap[i] = new AssignmentProposition(rvsmap.get(evidenze[i]),((ArbitraryTokenDomain)rvsmap.get(evidenze[i]).getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get(evidenze[i]).getDomain().size()-1 - min) + 1) + min]);
        }

        runTest(bn,qrv,ap,rvsmap, false, false, true);
    }

    /**
     * Test conclusioni relazione
     */
    public static void test11() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/andes.xml");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("TRY15");

        Random rn = new Random(); int min = 0;
        String [] evidenze = new String[]{"NEED1"};

        AssignmentProposition[] ap = new AssignmentProposition[evidenze.length];
        for (int i = 0; i < evidenze.length; i++) {
            ap[i] = new AssignmentProposition(rvsmap.get(evidenze[i]),((ArbitraryTokenDomain)rvsmap.get(evidenze[i]).getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get(evidenze[i]).getDomain().size()-1 - min) + 1) + min]);
        }

        runTest(bn,qrv,ap,rvsmap, false, false, false);
    }

    /**
     * Test
     */
    public static void test12() {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("Age");

        Random rn = new Random(); int min = 0;
        String [] evidenze = new String[]{"SocioEcon", "GoodStudent"};

        AssignmentProposition[] ap = new AssignmentProposition[evidenze.length];
        for (int i = 0; i < evidenze.length; i++) {
            ap[i] = new AssignmentProposition(rvsmap.get(evidenze[i]),((ArbitraryTokenDomain)rvsmap.get(evidenze[i]).getDomain()).getPossibleValues().toArray()[rn.nextInt((rvsmap.get(evidenze[i]).getDomain().size()-1 - min) + 1) + min]);
        }

        runTest(bn,qrv,ap,rvsmap, false, false, true);
    }
}
