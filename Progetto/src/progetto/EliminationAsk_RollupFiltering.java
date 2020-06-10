/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package progetto;

import aima.core.probability.CategoricalDistribution;
import aima.core.probability.Factor;
import aima.core.probability.RandomVariable;
import aima.core.probability.bayes.BayesianNetwork;
import aima.core.probability.bayes.FiniteNode;
import aima.core.probability.bayes.Node;
import aima.core.probability.bayes.exact.EliminationAsk;
import aima.core.probability.proposition.AssignmentProposition;
import aima.core.probability.util.ProbabilityTable;

import java.util.*;

/**
 *
 * @author davide
 */
public class EliminationAsk_RollupFiltering extends EliminationAsk {

    //
    private static final ProbabilityTable _identity = new ProbabilityTable(
                    new double[] { 1.0 });

        private List<RandomVariable> irrelevants;
    public EliminationAsk_RollupFiltering(){
        // this.irrelevants = list;
    }
    // function ELIMINATION-ASK(X, e, bn) returns a distribution over X
    /**
     * The ELIMINATION-ASK algorithm in Figure 14.11.
     * 
     * @param X
     *            the query variables.
     * @param e
     *            observed values for variables E.
     * @param bn
     *            a Bayes net with variables {X} &cup; E &cup; Y /* Y = hidden
     *            variables //
     * @return a distribution over the query variables.
     */
    public CategoricalDistribution eliminationAsk(final RandomVariable[] X,
                    final AssignmentProposition[] e, final BayesianNetwork bn) {

        Set<RandomVariable> hidden = new HashSet();
        List<RandomVariable> VARS = new ArrayList();
        this.calculateVariables(X, e, bn, hidden, VARS);
        List<Factor> factors = new ArrayList();
        Iterator i$ = this.order(bn, VARS).iterator();

        while(i$.hasNext()) {
            RandomVariable var = (RandomVariable)i$.next();
            ((List)factors).add(0, this.makeFactor(var, e, bn));
            if (hidden.contains(var)) {
                factors = this.sumOut(var, (List)factors, bn);
            }
        }

        Factor product = this.pointwiseProduct((List)factors);
        return ((ProbabilityTable)product.pointwiseProductPOS(_identity, X)).normalize();
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

    private Factor pointwiseProduct(List<Factor> factors) {

            Factor product = factors.get(0);
            for (int i = 1; i < factors.size(); i++) {
                    product = product.pointwiseProduct(factors.get(i));
            }

            return product;
    }
}
