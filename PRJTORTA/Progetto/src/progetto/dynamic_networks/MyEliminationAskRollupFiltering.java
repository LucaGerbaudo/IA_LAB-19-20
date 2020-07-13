package progetto.dynamic_networks;

import probability.CategoricalDistribution;
import probability.Factor;
import probability.RandomVariable;
import probability.bayes.BayesianNetwork;
import probability.bayes.FiniteNode;
import probability.bayes.Node;
import probability.bayes.impl.FullCPTNode;
import probability.proposition.AssignmentProposition;
import probability.util.ProbabilityTable;
import progetto.dynamic_networks.MyDynamicBayesianNetwork;
import progetto.pruning.Pruning;

import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * Classe che implementa il Rollup Filtering per reti bayesiane dinamiche
 */
public class MyEliminationAskRollupFiltering {

    /**
     * Metodo che esegue il RollupFiltering
     * @return
     */
    public CategoricalDistribution eliminationAskRollupFiltering(final RandomVariable[] X,
                                                                 final AssignmentProposition[][] e,
                                                                 final MyDynamicBayesianNetwork bn,
                                                                 Map<String, RandomVariable> rvsmap, List<RandomVariable> order, int irrilevant) {
        List<Factor> factors = new ArrayList<>();
        List<Factor> prec = null;
        int t = 0;

        //Ripetizione rollup per numero evidenze volte
        for (AssignmentProposition[] evidence: e) {
            List<RandomVariable> orders = new ArrayList<>(order);
            if(irrilevant != 0) pruningIrrilevant(bn, X, evidence, irrilevant);

            long startTime = System.nanoTime();

            //Esecuzione V.E tra tempo t-1 e t
            factors = ve_pr2_dynamic(bn, X, evidence, orders, prec);

            long stopTime = System.nanoTime();

            //I fattori al tempo t, vengono usati nello slice di tempo successivo
            prec = factors;

            System.out.println("t = " + t + " (" + Arrays.asList(evidence).toString() + "): " + ((ProbabilityTable)pointwiseProduct(factors)).normalize() + " - time : " + TimeUnit.MILLISECONDS.convert((stopTime - startTime), TimeUnit.NANOSECONDS));
            t++;
        }

        return ((ProbabilityTable)pointwiseProduct(factors)).normalize();
    }

     /**
     * Algoritmo Variable elimination (versione Dalwiche) modificato per reti dinamiche bayesiane
     * @return
     */
    public List<Factor> ve_pr2_dynamic(MyDynamicBayesianNetwork bn,
                                       final RandomVariable[] Q,
                                       final AssignmentProposition[] e,
                                       List<RandomVariable> pi,
                                       List<Factor> prec) {
        int max_factor = Integer.MIN_VALUE;
        List<Factor> S = new ArrayList<>();

        pi.removeAll(Arrays.asList(Q));
        //Se presenti, aggiungo fattori calcolati al tempo precedente
        if (prec != null) {
            S.addAll(prec);
        }

        for (RandomVariable var : bn.getVariablesInTopologicalOrder()) {
            if (prec == null) {
                S.add(0, makeFactor(var, e, bn));
            } else if (!bn.getPriorNetwork().getVariablesInTopologicalOrder().contains(var)) {
                S.add(0, makeFactor(var, e, bn));
            }
        }

        for(Factor f : S) if(f.getArgumentVariables().size() > max_factor) max_factor = f.getArgumentVariables().size();

        for (int i = 0; i < pi.size(); i++) {
            List<Factor> toMultiply = new ArrayList<>();
            for (Factor fk : S) {
                if (fk.getArgumentVariables().contains(pi.get(i))) {
                    toMultiply.add(fk);
                }
            }
            if (toMultiply.size() > 0) {
                Factor f = pointwiseProduct(toMultiply);
                Factor fi = ((ProbabilityTable) f.sumOut(pi.get(i))).normalize();
                S.removeAll(toMultiply);
                S.add(fi);

                if(fi.getArgumentVariables().size() > max_factor) max_factor = fi.getArgumentVariables().size();
            }
        }

        Map<Set<RandomVariable>, List<Factor>> map = new HashMap<>();
        for (Factor factor: S) {
            boolean added = false;
            for (Set<RandomVariable> key: map.keySet()) {
                if (key.containsAll(factor.getArgumentVariables()) || factor.getArgumentVariables().containsAll(key)) {
                    map.get(key).add(factor);
                    added = true;
                    break;
                }
            }

            if (!added) {
                map.put(factor.getArgumentVariables(), new ArrayList<>());
                map.get(factor.getArgumentVariables()).add(factor);
            }
        }
        List<Factor> ret = new ArrayList<>();
        for (Set<RandomVariable> setRa : map.keySet()) {
            Factor f = ((ProbabilityTable) pointwiseProduct(map.get(setRa))).normalize();
            ret.add(f);
        }

        System.out.println("Width ordinamento : O(d^" + max_factor + " * " + bn.getVariablesInTopologicalOrder().size() + ")");
        return ret;
    }

    /**
     * Esecuzione del pruning in base al parametro del rollup filtering
     */
    void pruningIrrilevant(MyDynamicBayesianNetwork bn, RandomVariable[] X, AssignmentProposition[] e,  int irrilevant) {
        switch (irrilevant) {
            case 1 :
                Pruning.nodiIrrilevanti1(bn, X, e);
                break;
            case 2 :
                Pruning.nodiIrrilevantiMoralGraph(bn, X, e);
                break;
            case 3 :
                Pruning.archiIrrilevanti(bn, e);
        }
    }



    // END-BayesInference
    //

    //
    // PROTECTED METHODS
    //
    /**
     * <b>Note:</b>Override this method for a more efficient implementation as
     * outlined in AIMA3e pgs. 527-28. Calculate the hidden variables from the
     * Bayesian Network. The default implementation does not perform any of
     * these.<br>
     * <br>
     * Two calcuations to be performed here in order to optimize iteration over
     * the Bayesian Network:<br>
     * 1. Calculate the hidden variables to be enumerated over. An optimization
     * (AIMA3e pg. 528) is to remove 'every variable that is not an ancestor of
     * a query variable or evidence variable as it is irrelevant to the query'
     * (i.e. sums to 1). 2. The subset of variables from the Bayesian Network to
     * be retained after irrelevant hidden variables have been removed.
     *
     * @param X
     *            the query variables.
     * @param e
     *            observed values for variables E.
     * @param bn
     *            a Bayes net with variables {X} &cup; E &cup; Y /* Y = hidden
     *            variables //
     * @param hidden
     *            to be populated with the relevant hidden variables Y.
     * @param bnVARS
     *            to be populated with the subset of the random variables
     *            comprising the Bayesian Network with any irrelevant hidden
     *            variables removed.
     */
    protected void calculateVariables(final RandomVariable[] X,
                                      final AssignmentProposition[] e, final BayesianNetwork bn,
                                      Set<RandomVariable> hidden, Collection<RandomVariable> bnVARS) {

        bnVARS.addAll(bn.getVariablesInTopologicalOrder());
        hidden.addAll(bnVARS);

        for (RandomVariable x : X) {
            hidden.remove(x);
        }
        for (AssignmentProposition ap : e) {
            hidden.removeAll(ap.getScope());
        }

        return;
    }

    /**
     * <b>Note:</b>Override this method for a more efficient implementation as
     * outlined in AIMA3e pgs. 527-28. The default implementation does not
     * perform any of these.<br>
     *
     * @param bn
     *            the Bayesian Network over which the query is being made. Note,
     *            is necessary to provide this in order to be able to determine
     *            the dependencies between variables.
     * @param vars
     *            a subset of the RandomVariables making up the Bayesian
     *            Network, with any irrelevant hidden variables alreay removed.
     * @return a possibly opimal ordering for the random variables to be
     *         iterated over by the algorithm. For example, one fairly effective
     *         ordering is a greedy one: eliminate whichever variable minimizes
     *         the size of the next factor to be constructed.
     */
    protected List<RandomVariable> order(BayesianNetwork bn,
                                         Collection<RandomVariable> vars) {
        // Note: Trivial Approach:
        // For simplicity just return in the reverse order received,
        // i.e. received will be the default topological order for
        // the Bayesian Network and we want to ensure the network
        // is iterated from bottom up to ensure when hidden variables
        // are come across all the factors dependent on them have
        // been seen so far.
        List<RandomVariable> order = new ArrayList<RandomVariable>(vars);
        Collections.reverse(order);

        return order;
    }

    //
    // PRIVATE METHODS
    //
    private Factor makeFactor(RandomVariable var, AssignmentProposition[] e,
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

    private List<Factor> sumOut(RandomVariable var, List<Factor> factors,
                                BayesianNetwork bn) {
        List<Factor> summedOutFactors = new ArrayList<Factor>();
        List<Factor> toMultiply = new ArrayList<Factor>();
        for (Factor f : factors) {
            if (f.contains(var)) {
                toMultiply.add(f);
            } else {
                // This factor does not contain the variable
                // so no need to sum out - see AIMA3e pg. 527.
                summedOutFactors.add(f);
            }
        }

        summedOutFactors.add(pointwiseProduct(toMultiply).sumOut(var));

        return summedOutFactors;
    }

    public Factor pointwiseProduct(List<Factor> factors) {

        Factor product = factors.get(0);
        for (int i = 1; i < factors.size(); i++) {
            product = product.pointwiseProduct(factors.get(i));
        }

        return product;
    }

    /******************************************************************************************************************/

    public CategoricalDistribution eliminationAskRollupFiltering_old(final RandomVariable[] X,
                                                                 final AssignmentProposition[][] e,
                                                                 final MyDynamicBayesianNetwork bn,
                                                                 Map<String, RandomVariable> rvsmap, List<RandomVariable> order, int irrilevant) {
        List<Factor> factors = new ArrayList<>();
        List<Factor> prec = null;
        int t = 0;

        for (AssignmentProposition[] evidence: e) {
            List<RandomVariable> orders = new ArrayList<>(order);
            if(irrilevant != 0) pruningIrrilevant(bn, X, evidence, irrilevant);

            long startTime = System.nanoTime();

            //Esecuzione V.E al tempo t
            factors = ve_pr2_dynamic_old(bn, X, evidence, orders, prec);

            long stopTime = System.nanoTime();

            prec = new ArrayList<>();
            for (Factor factor: factors) {
                for (RandomVariable var: factor.getArgumentVariables()) {

                    RandomVariable[] toSumout = new RandomVariable[factor.getArgumentVariables().size() - 1];
                    int i = 0;
                    for (RandomVariable arg: factor.getArgumentVariables()) {
                        if (arg != var) {
                            toSumout[i++] = arg;
                        }
                    }
                    Factor newFactor = ((ProbabilityTable)factor.sumOut(toSumout)).normalize();
                    FullCPTNode fullCPTNode = (FullCPTNode) bn.getNode(rvsmap.get(var.getName() + "-1"));
                    if(fullCPTNode != null) // è una var hidden quindi non ha t-1
                        fullCPTNode.setCPT(var, newFactor.getValues(), (Node[]) null);
                    else
                        fullCPTNode = (FullCPTNode) bn.getNode(rvsmap.get(var.getName()));
                    prec.add(fullCPTNode.getCPT().getFactorFor());
                }
            }
            System.out.println("t = " + t + " (" + Arrays.asList(evidence).toString() + "): " + ((ProbabilityTable)pointwiseProduct(factors)).normalize() + " - " + TimeUnit.MILLISECONDS.convert((stopTime - startTime), TimeUnit.NANOSECONDS));
            t++;
        }

        return ((ProbabilityTable)pointwiseProduct(factors)).normalize();
    }

    public List<Factor> ve_pr2_dynamic_old(MyDynamicBayesianNetwork bn,
                                       final RandomVariable[] Q,
                                       final AssignmentProposition[] e,
                                       List<RandomVariable> pi,
                                       List<Factor> prec) {
        int max_factor = Integer.MIN_VALUE;
        List<Factor> S = new ArrayList<>();

        pi.removeAll(Arrays.asList(Q));
        //Se presenti, aggiungo fattori calcolati al tempo precedente
        if (prec != null) {
            S.addAll(prec);
        }

        for (RandomVariable var : bn.getVariablesInTopologicalOrder()) {
            if (prec == null) {
                S.add(0, makeFactor(var, e, bn));
            } else if (!bn.getPriorNetwork().getVariablesInTopologicalOrder().contains(var)) {
                S.add(0, makeFactor(var, e, bn));
            }
        }

        for(Factor f : S) if(f.getArgumentVariables().size() > max_factor) max_factor = f.getArgumentVariables().size();

        for (int i = 0; i < pi.size(); i++) {
            List<Factor> toMultiply = new ArrayList<>();
            for (Factor fk : S) {
                if (fk.getArgumentVariables().contains(pi.get(i))) {
                    toMultiply.add(fk);
                }
            }
            if (toMultiply.size() > 0) {
                Factor f = pointwiseProduct(toMultiply);
                Factor fi = ((ProbabilityTable) f.sumOut(pi.get(i))).normalize();
                S.removeAll(toMultiply);
                S.add(fi);

                if(fi.getArgumentVariables().size() > max_factor) max_factor = fi.getArgumentVariables().size();
            }
        }

        Map<Set<RandomVariable>, List<Factor>> map = new HashMap<>();
        int max = -1;
        for (Factor factor : S) {
            max = Math.max(max, factor.getArgumentVariables().size());
        }
        System.out.println("Width ordinamento : O(d^" + max_factor + " * " + bn.getVariablesInTopologicalOrder().size() + ")");
        for (int i = max; i >= 0; i--) {
            for (Factor factor : S) {
                if (factor.getArgumentVariables().size() == i) {
                    boolean added = false;
                    for (Set<RandomVariable> setRa : map.keySet()) {
                        if (setRa.containsAll(factor.getArgumentVariables())) {
                            map.get(setRa).add(factor);
                            added = true;
                        }
                    }

                    if (!added) {
                        map.put(factor.getArgumentVariables(), new ArrayList<>());
                        map.get(factor.getArgumentVariables()).add(factor);
                    }
                }
            }
        }
        List<Factor> rett = new ArrayList<>();
        for (Set<RandomVariable> setRa : map.keySet()) {
            Factor f = ((ProbabilityTable) pointwiseProduct(map.get(setRa))).normalize();
            rett.add(f);
        }
        return rett;
    }
}
