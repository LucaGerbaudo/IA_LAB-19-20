/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package progetto.pruning;

import java.util.*;
import java.util.concurrent.TimeUnit;

import org.jgrapht.Graph;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;
import org.jgrapht.traverse.BreadthFirstIterator;
import probability.CategoricalDistribution;
import probability.Factor;
import probability.RandomVariable;
import probability.bayes.BayesianNetwork;
import probability.bayes.FiniteNode;
import probability.bayes.Node;
import probability.bayes.exact.EliminationAsk;
import probability.bayes.impl.BayesNet;
import probability.bayes.impl.FullCPTNode;
import probability.domain.ArbitraryTokenDomain;
import probability.proposition.AssignmentProposition;
import probability.util.ProbabilityTable;
import progetto.moralgraph.MyMoralGraph;
import progetto.ordinamenti.MinDegreeOrder;
import progetto.ordinamenti.MinFillOrder;

/**
 * CLASSE che implementa i metodi di pruning sulle BN
 * @author davide
 */
public class Pruning {

     /**
     * Metodo che rimuove i nodi irrilevanti dalla BN con il metodo degli ancestor
     */
    public static void nodiIrrilevanti1(BayesianNetwork bn, RandomVariable [] qrv, AssignmentProposition [] ap) {
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

        for(RandomVariable v: irrelevants)
            bn.removeNode(bn.getNode(v));
    }

    /**
     * Metodo che rimuove i nodi irrilevanti con il metodo della m-separation
     */
    public static void nodiIrrilevantiMoralGraph(BayesianNetwork bn, RandomVariable [] qrv, AssignmentProposition [] ap) {
        Set<RandomVariable> queries = Set.of(qrv);
        Set<RandomVariable> evidences = new HashSet<>();
        for(AssignmentProposition e : ap)
            evidences.add(e.getTermVariable());
        //Nodi irrilevanti dal moralgraph
        Set<RandomVariable> nodiIrrilevanti = MyMoralGraph.irrilevantRandomVariable(bn, queries, evidences);

        List<RandomVariable> nuoveCPT = new ArrayList<>();
        //Creo evidenza per le var irrilevanti
        List<AssignmentProposition> ap2 = new ArrayList<>();
        for(RandomVariable v : nodiIrrilevanti) {
            System.out.println("IRRELEVANT_2 : " + v.getName());
            ArbitraryTokenDomain t = (ArbitraryTokenDomain) v.getDomain();
            for(Object valDomain : t.getPossibleValues()) {
                ap2.add(new AssignmentProposition(v, valDomain));
            }

            //Elimino collegamento var irrilevanti -> figli e me le segno per ricalcolare i fattori
            for(Node child : bn.getNode(v).getChildren()) {
                child.removeParent(bn.getNode(v));
                nuoveCPT.add(child.getRandomVariable());
            }
        }

        //Ricalcolo le CPT delle var
        for(RandomVariable c : nuoveCPT) {
            Factor tab = ((FullCPTNode) bn.getNode(c)).getCPT().getFactorFor();
            double[] newValues = ((ProbabilityTable)tab).sumOut(nodiIrrilevanti.toArray(new RandomVariable[nodiIrrilevanti.size()])).normalize().getValues();
            ((FullCPTNode) bn.getNode(c)).setCPT(c, newValues, (Node[]) null);
        }

        for(RandomVariable v: nodiIrrilevanti)
            bn.removeNode(bn.getNode(v));
    }

    /**
     * Metodo che rimuove gli archi irrilevanti
     */
    public static void archiIrrilevanti(BayesianNetwork bn, AssignmentProposition [] ap) {
        int eliminati = 0;

        List<RandomVariable> nuoveCPT = new ArrayList<>();
        Set<RandomVariable> evidences = new HashSet<>();
        for(AssignmentProposition e : ap)
            evidences.add(e.getTermVariable());

        for(AssignmentProposition ev : ap) {
            RandomVariable var = ev.getTermVariable();
            for(Node c : bn.getNode(var).getChildren())
            {
                eliminati++;

                //Rimozione del collegamento nodo parent-figlio
                c.removeParent(bn.getNode(var));
                FullCPTNode tab = ((FullCPTNode) c);
                tab.removeParent(bn.getNode(var));
                tab.getCPT().getParents().remove(var);

                if(!nuoveCPT.contains(c.getRandomVariable()) && !evidences.contains(c.getRandomVariable())) nuoveCPT.add(c.getRandomVariable());
            }
        }

        //Ricalcolo CPT
        for(RandomVariable r : nuoveCPT) {
            Node c = bn.getNode(r);
            Node [] parents = c.getParents().toArray(new Node[c.getParents().size()]);
            Factor ff = makeFactor(c.getRandomVariable(), ap, bn);
            ((FullCPTNode) c).setCPT(c.getRandomVariable(), ff.getValues(), parents);
        }

        System.out.println("Archi eliminati : " + eliminati);
    }

    /**********************************************************************************************************/

    static List<RandomVariable> ancestors = new ArrayList<>();

    /**
     * Restituisce true se una variabile è IRRILEVANTE
     */
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


    /******************************************RICREAZIONE BN ***************************************************************/

    public static BayesianNetwork ricrea(Set<RandomVariable> irrelevants, BayesianNetwork bn, List<RandomVariable> rvs){
        /*
         * COSTRUISCO LA NUOVA RETE
         */
        List<Node> newNodes = new ArrayList<>();
        for (RandomVariable var: rvs) {
            if (irrelevants.contains(var)) {

            }
            else {
                Set<Node> parents = bn.getNode(var).getParents();
                List<RandomVariable> irrilevantParents = new ArrayList<>();
                Factor factor = ((FullCPTNode) bn.getNode(var)).getCPT().getFactorFor();
                Node[] parentsArray = new Node[parents.size()];

                for (RandomVariable irr: irrelevants) {
                    for (Node p: parents) {
                        if (p.getRandomVariable().equals(irr)) {
                            irrilevantParents.add(irr);
                        }
                    }
                }

                if (irrilevantParents.size() > 0) {
                    AssignmentProposition[] ap = new AssignmentProposition[irrilevantParents.size() * 2];
                    int i = 0;
                    for (RandomVariable irrPar : irrilevantParents) {
                        ap[i++] = new AssignmentProposition(irrPar, "State0");
                        ap[i++] = new AssignmentProposition(irrPar, "State1");
                    }

                    factor = makeFactor(var, ap, bn);

                    parentsArray = null;
                }


                int i = 0;
                for (Node p: parents) {
                    for (Node node: newNodes) {
                        if (node.getRandomVariable().getName().equals(p.getRandomVariable().getName())) {
                            parentsArray[i++] = node;
                        }
                    }
                }

                newNodes.add(new FullCPTNode(var, factor.getValues(), parentsArray));
            }
        }

        List<Node> roots = new ArrayList<>();
        for (Node node: newNodes) {
            if (node.getParents().size() == 0) {
                roots.add(node);
            }
        }
        Node[] rootsArray = new Node[roots.size()];
        rootsArray = roots.toArray(rootsArray);
        return new BayesNet(rootsArray);
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
    
}
