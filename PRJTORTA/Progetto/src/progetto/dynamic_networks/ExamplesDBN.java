package progetto.dynamic_networks;

import probability.CategoricalDistribution;
import probability.RandomVariable;
import probability.bayes.BayesianNetwork;
import probability.bayes.FiniteNode;
import probability.bayes.Node;
import probability.bayes.impl.BayesNet;
import probability.bayes.impl.FullCPTNode;
import probability.domain.ArbitraryTokenDomain;
import probability.example.ExampleRV;
import probability.proposition.AssignmentProposition;
import bnparser.BifReader;
import probability.util.RandVar;
import progetto.UmbrellaParticle;
import progetto.dynamic_networks.MyDynamicBayesNet;
import progetto.dynamic_networks.MyDynamicBayesianNetwork;
import progetto.dynamic_networks.MyEliminationAskRollupFiltering;

import java.util.*;

public class ExamplesDBN {

    public static void main(String[] args) {
        MyDynamicBayesianNetwork bn = getRainWindNet();
        Map<String, RandomVariable> rvsmap = new HashMap<>();
        for (RandomVariable var: bn.getVariablesInTopologicalOrder()) {
            rvsmap.put(var.getName(), var);
        }

        AssignmentProposition[][] aps = null;
        int n = Integer.parseInt(args[0]);

        int m = args.length - 1;
        if (m > 0) {
            aps = new AssignmentProposition[m][1];
            for (int i = 0; i < m; i++) {
            aps[i][0] = new AssignmentProposition(ExampleRV.UMBREALLA_t_RV,
                    Integer.parseInt(args[i+1])==0 ? Boolean.FALSE : Boolean.TRUE);
            }
        }
    }

    /************************************** DynamicBayesianNetworks ***************************************************/

    public static MyDynamicBayesianNetwork getRainWindNet() {
        FiniteNode prior_rain_tm1 = new FullCPTNode(ExampleRV.RAIN_tm1_RV,
                new double[]{0.5, 0.5});
        FiniteNode prior_wind_tm1 = new FullCPTNode(UmbrellaParticle.WIND_tm1_RV,
                new double[]{0.5, 0.5});

        BayesNet priorNetwork = new BayesNet(prior_rain_tm1, prior_wind_tm1);

        // Prior belief state
        FiniteNode rain_tm1 = new FullCPTNode(ExampleRV.RAIN_tm1_RV,
                new double[]{0.5, 0.5});
        FiniteNode wind_tm1 = new FullCPTNode(UmbrellaParticle.WIND_tm1_RV,
                new double[]{0.5, 0.5});


        // Transition Model
        FiniteNode rain_t = new FullCPTNode(ExampleRV.RAIN_t_RV, new double[]{
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
                0.8
        }, rain_tm1, wind_tm1);

        FiniteNode wind_t = new FullCPTNode(UmbrellaParticle.WIND_t_RV, new double[]{
                // W_t-1 = true, W_t = true
                0.7,
                // W_t-1 = true, W_t = false
                0.3,
                // W_t-1 = false, W_t = true
                0.3,
                // W_t-1 = false, W_t = false
                0.7}, wind_tm1);

        // Sensor Model
        @SuppressWarnings("unused")
        FiniteNode umbrealla_t = new FullCPTNode(ExampleRV.UMBREALLA_t_RV,
                new double[]{
                        // R_t = true, U_t = true
                        0.9,
                        // R_t = true, U_t = false
                        0.1,
                        // R_t = false, U_t = true
                        0.2,
                        // R_t = false, U_t = false
                        0.8}, rain_t);

        Map<RandomVariable, List<RandomVariable>> X_0_to_X_1 = new HashMap<RandomVariable, List<RandomVariable>>();
        List<RandomVariable> list = new ArrayList<>();
        list.add(ExampleRV.RAIN_t_RV);
        X_0_to_X_1.put(ExampleRV.RAIN_tm1_RV, list);
        List<RandomVariable> list2 = new ArrayList<>();
        list2.add(ExampleRV.RAIN_t_RV);
        list2.add(UmbrellaParticle.WIND_t_RV);
        X_0_to_X_1.put(UmbrellaParticle.WIND_tm1_RV, list2);
        Set<RandomVariable> E_1 = new HashSet<RandomVariable>();
        E_1.add(ExampleRV.UMBREALLA_t_RV);;

        return new MyDynamicBayesNet(priorNetwork, X_0_to_X_1, E_1, rain_tm1, wind_tm1);
    }

    public static MyDynamicBayesianNetwork getDynamicAlarmNet() {

        FiniteNode burglary_prior = new FullCPTNode(ExampleRV.BURGLARY_RV1,
                new double[] { 0.001, 0.999 });
        FiniteNode earthquake_prior = new FullCPTNode(ExampleRV.EARTHQUAKE_RV1,
                new double[] { 0.002, 0.998 });

        BayesNet priorNetwork = new BayesNet(burglary_prior, earthquake_prior);

        //Prior belief state
        FiniteNode burglary_tm1 = new FullCPTNode(ExampleRV.BURGLARY_RV1,
                new double[] { 0.001, 0.999 });
        FiniteNode earthquake_tm1 = new FullCPTNode(ExampleRV.EARTHQUAKE_RV1,
                new double[] { 0.002, 0.998 });

        //Transition Model
        FiniteNode burglary = new FullCPTNode(ExampleRV.BURGLARY_RV,
                new double[] { 0.0005, 0.9995, 0.0001, 0.9999, 0.05, 0.95, 0.001, 0.999 }, burglary_tm1, earthquake_tm1);
        FiniteNode earthquake = new FullCPTNode(ExampleRV.EARTHQUAKE_RV,
                new double[] { 0.7, 0.3, 0.002, 0.998 }, earthquake_tm1);

        FiniteNode alarm = new FullCPTNode(ExampleRV.ALARM_RV, new double[] {
                // B=true, E=true, A=true
                0.95,
                // B=true, E=true, A=false
                0.05,
                // B=true, E=false, A=true
                0.94,
                // B=true, E=false, A=false
                0.06,
                // B=false, E=true, A=true
                0.29,
                // B=false, E=true, A=false
                0.71,
                // B=false, E=false, A=true
                0.001,
                // B=false, E=false, A=false
                0.999 }, burglary, earthquake);
        @SuppressWarnings("unused")
        FiniteNode johnCalls = new FullCPTNode(ExampleRV.JOHN_CALLS_RV,
                new double[] {
                        // A=true, J=true
                        0.90,
                        // A=true, J=false
                        0.10,
                        // A=false, J=true
                        0.05,
                        // A=false, J=false
                        0.95 }, alarm);
        @SuppressWarnings("unused")
        FiniteNode maryCalls = new FullCPTNode(ExampleRV.MARY_CALLS_RV,
                new double[] {
                        // A=true, M=true
                        0.70,
                        // A=true, M=false
                        0.30,
                        // A=false, M=true
                        0.01,
                        // A=false, M=false
                        0.99 }, alarm);

        Map<RandomVariable, List<RandomVariable>> X_0_to_X_1 = new HashMap<RandomVariable, List<RandomVariable>>();
        List<RandomVariable> list = new ArrayList<>();
        list.add(ExampleRV.BURGLARY_RV);
        list.add(ExampleRV.EARTHQUAKE_RV);
        X_0_to_X_1.put(ExampleRV.EARTHQUAKE_RV1, list);

        List<RandomVariable> list2 = new ArrayList<>();
        list2.add(ExampleRV.BURGLARY_RV);
        X_0_to_X_1.put(ExampleRV.BURGLARY_RV1, list2);

        List<RandomVariable> list3 = new ArrayList<>();
        //list3.add(ExampleRV.ALARM_RV);
        X_0_to_X_1.put(ExampleRV.ALARM_RV, list3);

        Set<RandomVariable> E_1 = new HashSet<RandomVariable>();
        E_1.add(ExampleRV.JOHN_CALLS_RV);
        E_1.add(ExampleRV.MARY_CALLS_RV);

        return new MyDynamicBayesNet(priorNetwork, X_0_to_X_1, E_1, burglary_tm1, earthquake_tm1);
    }

    public static MyDynamicBayesianNetwork getInsuranceNetwork() {
        //Evidences : "MedCost", "ILiCost", "PropCost"

        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }

        RandomVariable rnage = new RandVar("Age_tm-1", new ArbitraryTokenDomain("Adolescent", "Adult", "Senior"));
        RandomVariable rnmileage = new RandVar("Mileage_tm-1", new ArbitraryTokenDomain("FiveThou", "TwentyThou", "FiftyThou", "Domino"));
        FiniteNode age_tm1 = new FullCPTNode(rnage, new double[] { 0.2, 0.6, 0.2 });
        FiniteNode mileage_tm1 = new FullCPTNode(rnmileage, new double[] { 0.1, 0.4, 0.4, 0.1 });

        BayesNet priorNetwork = new BayesNet(age_tm1, mileage_tm1);


        //Prior belief state
        RandomVariable rnage_prior = new RandVar("Age_tm-1", new ArbitraryTokenDomain("Adolescent", "Adult", "Senior"));
        RandomVariable rnmileage_prior = new RandVar("Mileage_tm-1", new ArbitraryTokenDomain("FiveThou", "TwentyThou", "FiftyThou", "Domino"));
        FiniteNode age_tm1_prior = new FullCPTNode(rnage_prior, new double[] { 0.2, 0.6, 0.2 });
        FiniteNode mileage_tm1_prior = new FullCPTNode(rnmileage_prior, new double[] { 0.1, 0.4, 0.4, 0.1 });

        //Transition Model
        Set<Node> ageChildren = bn.getNode(rvsmap.get("Age")).getChildren();
        Set<Node> mileageChildren = bn.getNode(rvsmap.get("Mileage")).getChildren();
        bn.setNode(rvsmap.get("Age"), new FullCPTNode(rvsmap.get("Age"), new double[]{0.79, 0.2, 0.01, 0.01, 0.89, 0.1, 0.01, 0.01, 0.98}, age_tm1_prior));
        bn.getNode(rvsmap.get("Age")).setChildren(ageChildren);
        bn.setNode(rvsmap.get("Mileage"), new FullCPTNode(rvsmap.get("Mileage"), new double[]{ 0.4, 0.4, 0.1, 0.1, 0.01, 0.4, 0.4, 0.19, 0.01, 0.01, 0.5, 0.48, 0.01, 0.01, 0.01, 0.97}, mileage_tm1_prior));
        bn.getNode(rvsmap.get("Mileage")).setChildren(mileageChildren);

        bn.addNode(rnage_prior, age_tm1_prior);
        bn.addNode(rnmileage_prior, mileage_tm1_prior);

        bn.removeRoot(bn.getNode(rvsmap.get("Age")));
        bn.removeRoot(bn.getNode(rvsmap.get("Mileage")));

        bn.addRoot(age_tm1_prior);
        bn.addRoot(mileage_tm1_prior);

        Map<RandomVariable, List<RandomVariable>> X_0_to_X_1 = new HashMap<RandomVariable, List<RandomVariable>>();
        List<RandomVariable> list = new ArrayList<>();
        list.add(rvsmap.get("Age"));
        X_0_to_X_1.put(rnage_prior, list);
        List<RandomVariable> list2 = new ArrayList<>();
        list2.add(rvsmap.get("Mileage"));
        X_0_to_X_1.put(rnmileage_prior, list2);
        Set<RandomVariable> E_1 = new HashSet<RandomVariable>();

        for (RandomVariable r : rvsmap.values()) {
            if(!X_0_to_X_1.containsKey(r))
                X_0_to_X_1.put(r, new ArrayList<RandomVariable>());
        }

        E_1.add(rvsmap.get("MedCost"));
        E_1.add(rvsmap.get("ILiCost"));
        E_1.add(rvsmap.get("PropCost"));

        return new MyDynamicBayesNet(priorNetwork, X_0_to_X_1, E_1, age_tm1_prior, mileage_tm1_prior);
    }

    public static MyDynamicBayesianNetwork getInsuranceNetworkMoreEvidences() {
        //Evidences : "MedCost", "ILiCost", "PropCost"

        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        BayesianNetwork bn = BifReader.readBIF("bifNets/insurance.xbif");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            rvsmap.put(rv.getName(), rv);
        }

        RandomVariable rnage = new RandVar("Age_tm-1", new ArbitraryTokenDomain("Adolescent", "Adult", "Senior"));
        RandomVariable rnmileage = new RandVar("Mileage_tm-1", new ArbitraryTokenDomain("FiveThou", "TwentyThou", "FiftyThou", "Domino"));
        FiniteNode age_tm1 = new FullCPTNode(rnage, new double[] { 0.2, 0.6, 0.2 });
        FiniteNode mileage_tm1 = new FullCPTNode(rnmileage, new double[] { 0.1, 0.4, 0.4, 0.1 });

        BayesNet priorNetwork = new BayesNet(age_tm1, mileage_tm1);


        //Prior belief state
        RandomVariable rnage_prior = new RandVar("Age_tm-1", new ArbitraryTokenDomain("Adolescent", "Adult", "Senior"));
        RandomVariable rnmileage_prior = new RandVar("Mileage_tm-1", new ArbitraryTokenDomain("FiveThou", "TwentyThou", "FiftyThou", "Domino"));
        FiniteNode age_tm1_prior = new FullCPTNode(rnage_prior, new double[] { 0.2, 0.6, 0.2 });
        FiniteNode mileage_tm1_prior = new FullCPTNode(rnmileage_prior, new double[] { 0.1, 0.4, 0.4, 0.1 });

        //Transition Model
        Set<Node> ageChildren = bn.getNode(rvsmap.get("Age")).getChildren();
        Set<Node> mileageChildren = bn.getNode(rvsmap.get("Mileage")).getChildren();
        bn.setNode(rvsmap.get("Age"), new FullCPTNode(rvsmap.get("Age"), new double[]{0.79, 0.2, 0.01, 0.01, 0.89, 0.1, 0.01, 0.01, 0.98}, age_tm1_prior));
        bn.getNode(rvsmap.get("Age")).setChildren(ageChildren);
        bn.setNode(rvsmap.get("Mileage"), new FullCPTNode(rvsmap.get("Mileage"), new double[]{ 0.4, 0.4, 0.1, 0.1, 0.01, 0.4, 0.4, 0.19, 0.01, 0.01, 0.5, 0.48, 0.01, 0.01, 0.01, 0.97}, mileage_tm1_prior));
        bn.getNode(rvsmap.get("Mileage")).setChildren(mileageChildren);

        bn.addNode(rnage_prior, age_tm1_prior);
        bn.addNode(rnmileage_prior, mileage_tm1_prior);

        bn.removeRoot(bn.getNode(rvsmap.get("Age")));
        bn.removeRoot(bn.getNode(rvsmap.get("Mileage")));

        bn.addRoot(age_tm1_prior);
        bn.addRoot(mileage_tm1_prior);

        Map<RandomVariable, List<RandomVariable>> X_0_to_X_1 = new HashMap<RandomVariable, List<RandomVariable>>();
        List<RandomVariable> list = new ArrayList<>();
        list.add(rvsmap.get("Age"));
        X_0_to_X_1.put(rnage_prior, list);
        List<RandomVariable> list2 = new ArrayList<>();
        list2.add(rvsmap.get("Mileage"));
        X_0_to_X_1.put(rnmileage_prior, list2);
        Set<RandomVariable> E_1 = new HashSet<RandomVariable>();

        for (RandomVariable r : rvsmap.values()) {
            if(!X_0_to_X_1.containsKey(r))
                X_0_to_X_1.put(r, new ArrayList<RandomVariable>());
        }

        E_1.add(rvsmap.get("MedCost"));
        E_1.add(rvsmap.get("ILiCost"));
        E_1.add(rvsmap.get("PropCost"));
        E_1.add(rvsmap.get("Theft"));
        E_1.add(rvsmap.get("HomeBase"));
        E_1.add(rvsmap.get("OtherCarCost"));


        return new MyDynamicBayesNet(priorNetwork, X_0_to_X_1, E_1, age_tm1_prior, mileage_tm1_prior);
    }
}


