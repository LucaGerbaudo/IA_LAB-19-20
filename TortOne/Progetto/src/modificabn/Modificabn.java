/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package modificabn;

import bnparser.BifReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import probability.CategoricalDistribution;
import probability.Factor;
import probability.RandomVariable;
import probability.bayes.BayesInference;
import probability.bayes.BayesianNetwork;
import probability.bayes.FiniteNode;
import probability.bayes.Node;
import probability.bayes.exact.EliminationAsk;
import probability.bayes.impl.FullCPTNode;
import probability.example.ExampleRV;
import probability.proposition.AssignmentProposition;

/**
 *
 * @author davide
 */
public class Modificabn {
    
    static List<RandomVariable> ancestors = new ArrayList<>();
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        HashMap<String, RandomVariable> rvsmap = new HashMap<>();
        
        BayesianNetwork bn = BifReader.readBIF("testPruning.xml");
        List<RandomVariable> rvs = bn.getVariablesInTopologicalOrder();
        for (RandomVariable rv :rvs) {
            System.out.println(rv.getName());
            rvsmap.put(rv.getName(), rv);       
        }        
                
        RandomVariable[] qrv = new RandomVariable[1];
        qrv[0] = rvsmap.get("A");
        
        AssignmentProposition[] ap = new AssignmentProposition[1];
        ap[0] = new AssignmentProposition(rvsmap.get("C"), "False");
        
        //****************************** Nodi irrilevanti
        
        List<RandomVariable> irrelevants = new ArrayList<>();
        for(RandomVariable v : bn.getVariablesInTopologicalOrder())
        {
            if(isIrrelevant(bn, v, qrv, ap)) {
                irrelevants.add(v);
                System.out.println("IRRELEVANT : " + v.getName());
            }
        }        
        System.out.println(ancestors.toString());
        
        /********************************************************************/
        
        
        //************************** Archi irrilevanti
        for(AssignmentProposition ev : ap) {
            RandomVariable var = ev.getTermVariable();
            for(Node c : bn.getNode(var).getChildren())
            {
                Factor ff = makeFactor(c.getRandomVariable(), ap, bn);
                bn.getNode(c.getRandomVariable()).removeParent(bn.getNode(var));
                bn.setNode(c.getRandomVariable(), new FullCPTNode(c.getRandomVariable(), ff.getValues(), bn.getNode(c.getRandomVariable()).getParents().toArray(new Node[bn.getNode(c.getRandomVariable()).getParents().size()])));
            }
        }
        //*******************************************
        
        
        //VE
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
    }
    
    
//**********************************************************************************************************
    
    private static Factor makeFactor(RandomVariable var, AssignmentProposition[] e,
                    BayesianNetwork bn) {

        Node n = bn.getNode(var);
        if (!(n instanceof FiniteNode)) {
                throw new IllegalArgumentException(
                                "Elimination-Ask only works with finite Nodes.");
        }
        FiniteNode fn = (FiniteNode) n;
        List<AssignmentProposition> evidence = new ArrayList<AssignmentProposition>();
        for (AssignmentProposition ap : e) {
                if (fn.getCPT().contains(ap.getTermVariable())) {
                        evidence.add(ap);
                }
        }

        return fn.getCPT().getFactorFor(
                            evidence.toArray(new AssignmentProposition[evidence.size()]));
    }
    
    /**********************************************************************************************************/
    
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
