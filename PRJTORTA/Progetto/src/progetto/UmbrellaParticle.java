package progetto;

import probability.RandomVariable;
import probability.bayes.DynamicBayesianNetwork;
import probability.bayes.FiniteNode;
import probability.bayes.approx.ParticleFiltering;
import probability.bayes.impl.BayesNet;
import probability.bayes.impl.DynamicBayesNet;
import probability.bayes.impl.FullCPTNode;
import probability.domain.BooleanDomain;
import probability.example.DynamicBayesNetExampleFactory;
import probability.example.ExampleRV;
import probability.proposition.AssignmentProposition;
import probability.util.RandVar;
import progetto.dynamic_networks.MyDynamicBayesNet;
import progetto.dynamic_networks.MyDynamicBayesianNetwork;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 *
 * @author torta
 */
public class UmbrellaParticle {
    public static final RandVar WIND_tm1_RV = new RandVar("Wind_t-1",
            new BooleanDomain());
    public static final RandVar WIND_t_RV = new RandVar("Wind_t",
            new BooleanDomain());

    public static void main(String[] args) {
        DynamicBayesianNetwork bn1 = UmbrellaParticle.getRainWindNet();

        // numero di predizioni da fare
        int n = Integer.parseInt(args[0]);

        int m = args.length-1;
        AssignmentProposition[][] aps = null;
        if (m > 0) {
            aps = new AssignmentProposition[m][1];
            for (int i=0; i<m; i++) {
                aps[i][0] = new AssignmentProposition(ExampleRV.UMBREALLA_t_RV,
                        Integer.parseInt(args[i+1])==0 ? Boolean.FALSE : Boolean.TRUE);
            }
        }

        System.out.println("Rete Umbrella con stato Rain");
        ParticleFiltering pf = new ParticleFiltering(n,
                DynamicBayesNetExampleFactory.getUmbrellaWorldNetwork());

        for (int i=0; i<m; i++) {
            AssignmentProposition[][] S = pf.particleFiltering(aps[i]);
            System.out.println("Time " + (i+1));
            printSamples(S, n);
        }

        System.out.println("Rete Umbrella con stato Rain, Wind");
        pf = new ParticleFiltering(n,
                UmbrellaParticle.getRainWindNet());

        for (int i=0; i<m; i++) {
            AssignmentProposition[][] S = pf.particleFiltering(aps[i]);
            System.out.println("Time " + (i+1));
            printSamples(S, n);
        }

    }

    private static void printSamples(AssignmentProposition[][] S, int n) {
        HashMap<String,Integer> hm = new HashMap<String,Integer>();

        int nstates = S[0].length;

        for (int i = 0; i < n; i++) {
            String key = "";
            for (int j = 0; j < nstates; j++) {
                AssignmentProposition ap = S[i][j];
                key += ap.getValue().toString();
            }
            Integer val = hm.get(key);
            if (val == null) {
                hm.put(key, 1);
            } else {
                hm.put(key, val + 1);
            }
        }

        for (String key : hm.keySet()) {
            System.out.println(key + ": " + hm.get(key)/(double)n);
        }
    }

    private static DynamicBayesianNetwork getRainWindNet() {
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

        Map<RandomVariable, RandomVariable> X_0_to_X_1 = new HashMap<RandomVariable, RandomVariable>();
        X_0_to_X_1.put(ExampleRV.RAIN_tm1_RV, ExampleRV.RAIN_t_RV);
        X_0_to_X_1.put(UmbrellaParticle.WIND_tm1_RV, ExampleRV.RAIN_t_RV);
        X_0_to_X_1.put(UmbrellaParticle.WIND_tm1_RV, UmbrellaParticle.WIND_t_RV);
        Set<RandomVariable> E_1 = new HashSet<RandomVariable>();
        E_1.add(ExampleRV.UMBREALLA_t_RV);

        return new DynamicBayesNet(priorNetwork, X_0_to_X_1, E_1, rain_tm1, wind_tm1);

    }

    private static MyDynamicBayesianNetwork getRainWindNet2() {
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
        E_1.add(ExampleRV.UMBREALLA_t_RV);

        return new MyDynamicBayesNet(priorNetwork, X_0_to_X_1, E_1, rain_tm1, wind_tm1);
    }

    public static DynamicBayesianNetwork getEarthquakeNet() {
        FiniteNode prior_burglary = new FullCPTNode(ExampleRV.BURGLARY_RV1,
                new double[] { 0.001, 0.999 });
        FiniteNode prior_earthquake = new FullCPTNode(ExampleRV.EARTHQUAKE_RV1,
                new double[] { 0.002, 0.998 });

        BayesNet priorNetwork = new BayesNet(prior_burglary, prior_earthquake);

        FiniteNode burglary_tm1 = new FullCPTNode(ExampleRV.BURGLARY_RV1,
                new double[] { 0.001, 0.999 });
        FiniteNode earthquake_tm1 = new FullCPTNode(ExampleRV.EARTHQUAKE_RV1,
                new double[] { 0.002, 0.998 });

        FiniteNode burglary_t = new FullCPTNode(ExampleRV.BURGLARY_RV,
                    new double[] { 0.0005, 0.9995, 0.0001, 0.9999 }, burglary_tm1);
        FiniteNode earthquake_t = new FullCPTNode(ExampleRV.EARTHQUAKE_RV,
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
                0.999 }, burglary_t, earthquake_t);
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

        Map<RandomVariable, RandomVariable> X_0_to_X_1 = new HashMap<RandomVariable, RandomVariable>();
        X_0_to_X_1.put(ExampleRV.EARTHQUAKE_RV1, ExampleRV.EARTHQUAKE_RV);
        //X_0_to_X_1.put(ExampleRV.EARTHQUAKE_RV1, ExampleRV.BURGLARY_RV);
        X_0_to_X_1.put(ExampleRV.BURGLARY_RV1, ExampleRV.BURGLARY_RV);
        X_0_to_X_1.put(ExampleRV.ALARM_RV, ExampleRV.ALARM_RV);
        Set<RandomVariable> E_1 = new HashSet<RandomVariable>();
        E_1.add(ExampleRV.JOHN_CALLS_RV);
        E_1.add(ExampleRV.MARY_CALLS_RV);

        return new DynamicBayesNet(priorNetwork, X_0_to_X_1, E_1, burglary_tm1, earthquake_tm1);

    }
}
