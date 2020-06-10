/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package progetto;

import aima.core.probability.CategoricalDistribution;
import aima.core.probability.RandomVariable;
import aima.core.probability.bayes.BayesInference;
import aima.core.probability.bayes.BayesianNetwork;
import aima.core.probability.bayes.FiniteNode;
import aima.core.probability.bayes.Node;
import aima.core.probability.bayes.exact.EliminationAsk;
import aima.core.probability.bayes.impl.CPT;
import aima.core.probability.bayes.impl.FullCPTNode;
import aima.core.probability.proposition.AssignmentProposition;
import aima.core.probability.util.ProbabilityTable;
import bnparser.BifReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

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
        BayesInference biDBN = new EliminationAsk_RollupFiltering();
        CategoricalDistribution cdDBN = biDBN.ask(qrv, ap, bn);
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
    
    
}
