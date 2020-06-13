/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package progetto;

import aima.core.probability.CategoricalDistribution;
import aima.core.probability.Factor;
import aima.core.probability.RandomVariable;
import aima.core.probability.bayes.*;
import aima.core.probability.bayes.approx.ParticleFiltering;
import aima.core.probability.bayes.exact.EliminationAsk;
import aima.core.probability.bayes.impl.BayesNet;
import aima.core.probability.bayes.impl.CPT;
import aima.core.probability.bayes.impl.DynamicBayesNet;
import aima.core.probability.bayes.impl.FullCPTNode;
import aima.core.probability.example.DynamicBayesNetExampleFactory;
import aima.core.probability.example.ExampleRV;
import aima.core.probability.proposition.AssignmentProposition;
import aima.core.probability.util.ProbabilityTable;
import bnparser.BifReader;

import java.util.*;

/**
 *
 * @author davide
 */
public class Progetto {
    static List<RandomVariable> ancestors = new ArrayList<>();
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        
        BayesianNetwork bn = BifReader.readBIF("earthquake.xml");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            System.out.println(rv.getName());
            rvsmap.put(rv.getName(), rv);       
        }        
        
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("JohnCalls");
        
        AssignmentProposition[] ap = new AssignmentProposition[1];
        ap[0] = new AssignmentProposition(rvsmap.get("Burglary"), "True");
                
        // Nodi irrilevanti
        List<RandomVariable> irrelevants = new ArrayList<>();
        for(RandomVariable v : bn.getVariablesInTopologicalOrder())
        {
            if(isIrrelevant(bn, v, qrv, ap)) {
                irrelevants.add(v);
                System.out.println("IRRELEVANT : " + v.getName());
            }
        }        
        System.out.println(ancestors.toString());
        
        
        BayesInference bi = new EliminationAsk_IrrelevantNode(irrelevants);
        CategoricalDistribution cd = bi.ask(qrv, ap, bn);

        System.out.print("<");
        for (int i = 0; i < cd.getValues().length; i++) {
            System.out.print(cd.getValues()[i]);
            if (i < (cd.getValues().length - 1)) {
                System.out.print(", ");
            } else {
                System.out.println(">");
            }
        }
        
        //Archi Irrilevanti
        /*for(Node v : bn.getNode(ap[0].getTermVariable()).getChildren())
        {
            FiniteNode fn = (FiniteNode) v;
            
            if(fn.getCPT().contains(ap[0].getTermVariable()))
                System.out.println("iii");
            //System.out.println(fn.getCPT().(new AssignmentProposition(rvsmap.get("Burglary"), "True").getValue()));
            //fn.getCPT()
            
            FullCPTNode cptnode = (FullCPTNode)fn;
            CPT c = (CPT) cptnode.getCPT();
            
            System.out.println(fn.getCPT().getFor().toString());
            //fn.getCPT().
            
            //fn.getCPT().getValue("True", "False");
            
            
            c.probabilityFor(fn.getCPT().getFor().toArray());
            System.out.println(fn.getCPD().getClass().toString());
            //System.out.println(fn.getCPT().getConditioningCase(ap[0]).getValues().toString());
            
        }*/

        // Rollup Filtering
        DynamicBayesianNetwork dbn = getRainWindNet();
        List<Factor> lstFactors = new ArrayList<Factor>();
        //System.out.println("Size lstFactors pre-ask: " + lstFactors.size());
        //BayesInference biDBN = new EliminationAsk_RollupFiltering(lstFactors);
        //Factor f = (Factor)biDBN.ask(qrv, ap, bn);


        // CategoricalDistribution cdDBN = biDBN.ask(qrv, ap, bn);
        List<Factor> factors = new EliminationAsk_RollupFiltering(lstFactors).eliminationAskDBN(qrv, ap, dbn);
        // List<Factor> factors = new EliminationAsk_RollupFiltering(lstFactors).getSavedFactors();
        //System.out.println("Size lstFactors post-ask: " + lstFactors.size());
        // System.out.println("AAA" + lstFactors.get(0).getArgumentVariables());
        System.out.println("CPT: " + Arrays.toString(factors.toArray()));
        // numero di predizioni da fare
        int n = Integer.parseInt(args[0]);

        int m = args.length-1;
        System.out.println("Rete Umbrella con stato Rain, Wind");
        ParticleFiltering pf = new ParticleFiltering(20, getRainWindNet());

        AssignmentProposition[][] aps = null;
        if (m > 0) {
            aps = new AssignmentProposition[m][1];
            for (int i=0; i<m; i++) {
                aps[i][0] = new AssignmentProposition(ExampleRV.UMBREALLA_t_RV,
                        Integer.parseInt(args[i+1])==0 ? Boolean.FALSE : Boolean.TRUE);
            }
        }

        for (int i=0; i<m; i++) {
            AssignmentProposition[][] S = pf.particleFiltering(aps[i]);
            System.out.println("Time " + (i+1));
            printSamples(S, n);
        }
    }
    
    // Nodi Irrilevanti 1
    public static boolean isIrrelevant(BayesianNetwork bn, RandomVariable rnv, RandomVariable[] qrv, AssignmentProposition[] ap) {
        List<RandomVariable> query = Arrays.asList(qrv);
        List<AssignmentProposition> evidence = Arrays.asList(ap);
              
        for(RandomVariable q : query)
            getAllAncestors(bn, q);
        
        for(AssignmentProposition e : evidence) 
            getAllAncestors(bn, e.getTermVariable());
        
        if(ancestors.stream().filter(x -> x == rnv).findAny().isPresent() || 
                query.stream().filter(x -> x == rnv).findAny().isPresent() || 
                evidence.stream().filter(x -> x.getTermVariable() == rnv).findAny().isPresent())
            return false;
        else 
            return true;
    }
        
    public static void getAllAncestors(BayesianNetwork bn, RandomVariable rnv)
    {
        for(Node v : bn.getNode(rnv).getParents()) {
            if(!ancestors.stream().filter(x -> x == v.getRandomVariable()).findAny().isPresent())
                ancestors.add(v.getRandomVariable());
            getAllAncestors(bn, v.getRandomVariable());
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
}
