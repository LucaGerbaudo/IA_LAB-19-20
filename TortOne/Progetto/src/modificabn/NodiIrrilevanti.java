/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package modificabn;

import bnparser.BifReader;

import java.util.*;

import org.jgrapht.Graph;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;
import org.jgrapht.traverse.BreadthFirstIterator;
import probability.CategoricalDistribution;
import probability.Factor;
import probability.RandomVariable;
import probability.bayes.BayesInference;
import probability.bayes.BayesianNetwork;
import probability.bayes.FiniteNode;
import probability.bayes.Node;
import probability.bayes.exact.EliminationAsk;
import probability.bayes.impl.FullCPTNode;
import probability.proposition.AssignmentProposition;

/**
 *
 * @author davide
 */
public class NodiIrrilevanti {
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
        ap[0] = new AssignmentProposition(rvsmap.get("Alarm"), "True");
        
        /*********************************************** Nodi irrilevanti ********************************************/
        
        List<RandomVariable> irrelevants = new ArrayList<>();
        for(RandomVariable v : bn.getVariablesInTopologicalOrder())
        {
            if(isIrrelevant(bn, v, qrv, ap)) {
                irrelevants.add(v);
                System.out.println("IRRELEVANT_1 : " + v.getName());
                
                //Elimino il collegamento variabile irrilevante <-- padri
                for(Node parent : bn.getNode(v).getParents()) {
                    parent.removeChildren(bn.getNode(v));
                }
            }
        }
                
        /***************************************** Nodi irrilevanti Moral Graph *****************************/

        Set<RandomVariable> queries = Set.of(qrv);
        Set<RandomVariable> evidences = new HashSet<>();
        for(AssignmentProposition e : ap)
            evidences.add(e.getTermVariable());
        Set<RandomVariable> nodiIrrilevanti2 = irrilevantRandomVariable(bn, queries, evidences);
        
        List<RandomVariable> nuoveCPT = new ArrayList<>();
        
        //Creo evidenza per le var irrilevanti
        AssignmentProposition[] ap2 = new AssignmentProposition[nodiIrrilevanti2.size()*2];
        int k=0;
        for(RandomVariable v : nodiIrrilevanti2) {
            System.out.println("IRRELEVANT_2 : " + v.getName());
            ap2[k++] = new AssignmentProposition(v, "True");
            ap2[k++] = new AssignmentProposition(v, "False"); 
                
            //Elimino collegamento var irrilevanti -> figli e me le segno per ricalcolare i fattori
            for(Node child : bn.getNode(v).getChildren()) {
                child.removeParent(bn.getNode(v));
                nuoveCPT.add(child.getRandomVariable());
            }
        }
        
        //Ricalcolo le CPT delle var
        for(RandomVariable c : nuoveCPT) {
            Factor ff = makeFactor(c, ap2, bn);
            bn.setNode(c, new FullCPTNode(c, ff.getValues(), bn.getNode(c).getParents().toArray(new Node[bn.getNode(c).getParents().size()])));
        }
        
        /************************************************* Archi irrilevanti********************************************/
        
        for(AssignmentProposition ev : ap) {
            RandomVariable var = ev.getTermVariable();
            for(Node c : bn.getNode(var).getChildren())
            {
                Factor ff = makeFactor(c.getRandomVariable(), ap, bn);
                bn.getNode(c.getRandomVariable()).removeParent(bn.getNode(var));
                bn.setNode(c.getRandomVariable(), new FullCPTNode(c.getRandomVariable(), ff.getValues(), bn.getNode(c.getRandomVariable()).getParents().toArray(new Node[bn.getNode(c.getRandomVariable()).getParents().size()])));
            }
        }


        /******************************************* V.E. con ORDINAMENTI ************************************************************/

        // 1. MinDegree
        EliminationAsk minDegreeOrderAsk = new EliminationAsk() {
            @Override
            protected List<RandomVariable> order(BayesianNetwork bn, Collection<RandomVariable> vars) {
                return MinDegreeOrder.minDegreeOrder(bn);
            }
        };

        // 2. MinFill
        EliminationAsk minFillOrderAsk = new EliminationAsk() {
            @Override
            protected List<RandomVariable> order(BayesianNetwork bn, Collection<RandomVariable> vars) {
                return MinFillOrder.minFillOrder(bn);
            }
        };

        BayesInference[] allbi = new BayesInference[] {new EliminationAsk(), minDegreeOrderAsk, minFillOrderAsk};
        for (BayesInference bayesInference: allbi) {
            System.out.println("Simple query con " + bayesInference.getClass());
            long startTime = System.nanoTime();
            CategoricalDistribution cd = bayesInference.ask(qrv, ap, bn);
            long stopTime = System.nanoTime();
            System.out.println(cd + ": " + (stopTime - startTime));
        }

        System.out.println("MinDegreeOrder : " + MinDegreeOrder.minDegreeOrder(bn));
        System.out.println("MinFillOrder : " + MinFillOrder.minFillOrder(bn));
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
    
    /*******************************************************************************************************************************/
    
    private static Graph<RandomVariable, DefaultEdge> graphFromBayesianNetwork(BayesianNetwork bayesianNetwork) {
        Graph<RandomVariable, DefaultEdge> graph = new SimpleGraph<>(DefaultEdge.class);

        // aggiungo i nodi al grafo
        for (RandomVariable randomVariable: bayesianNetwork.getVariablesInTopologicalOrder()) {

            if (!graph.containsVertex(randomVariable)) {
                graph.addVertex(randomVariable);
            }

            for (Node child: bayesianNetwork.getNode(randomVariable).getChildren()) {
                RandomVariable rvChild = child.getRandomVariable();
                if (!graph.containsVertex(rvChild)) {
                    graph.addVertex(rvChild);
                }
                graph.addEdge(randomVariable, rvChild);
            }
        }

        return graph;
    }

    private static void moralizeGraph(Graph<RandomVariable, DefaultEdge> graph, BayesianNetwork bn) {
        for (RandomVariable randomVariable: graph.vertexSet()) {
            List<RandomVariable> parents = new ArrayList<>();
            for (Node node: bn.getNode(randomVariable).getParents()) {
                parents.add(node.getRandomVariable());
            }

            for (int i = 0; i < parents.size() - 1; i++) {
                graph.addEdge(parents.get(i), parents.get(i + 1));
            }
        }
    }

    private static Set<RandomVariable> irrilevantRandomVariable(BayesianNetwork bayesianNetwork,
                                                                Set<RandomVariable> queries,
                                                                Set<RandomVariable> evidences) {
        Set<RandomVariable> irrilevants = new HashSet<>();
        Set<RandomVariable> others = new HashSet<>(bayesianNetwork.getVariablesInTopologicalOrder());
        others.removeAll(queries);
        others.removeAll(evidences);

        Graph<RandomVariable, DefaultEdge> graph = graphFromBayesianNetwork(bayesianNetwork);
        moralizeGraph(graph, bayesianNetwork);

        for (RandomVariable evidence: evidences) {
            graph.removeVertex(evidence);
        }

        for (RandomVariable query: queries) {
            BreadthFirstIterator<RandomVariable, DefaultEdge> breadth = new BreadthFirstIterator<>(graph, query);

            Set<RandomVariable> path = new HashSet<>();
            while (breadth.hasNext()) {
                path.add(breadth.next());
            }

            for (RandomVariable y: others) {
                if (!path.contains(y)) {
                    irrilevants.add(y);
                }
            }
        }

        return irrilevants;
    }
    
}
