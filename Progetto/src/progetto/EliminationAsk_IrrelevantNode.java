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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 *
 * @author davide
 */
public class EliminationAsk_IrrelevantNode extends EliminationAsk {
    
    //
    private static final ProbabilityTable _identity = new ProbabilityTable(
                    new double[] { 1.0 });
    
        private List<RandomVariable> irrelevants;
    public EliminationAsk_IrrelevantNode(List<RandomVariable> list){
        this.irrelevants = list;
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

            Set<RandomVariable> hidden = new HashSet<RandomVariable>();
            List<RandomVariable> VARS = new ArrayList<RandomVariable>();
            calculateVariables(X, e, bn, hidden, VARS);
            
            List<AssignmentProposition> evidence = Arrays.asList(e);
            
            // factors <- []
            List<Factor> factors = new ArrayList<Factor>();
            // for each var in ORDER(bn.VARS) do
            for (RandomVariable var : order(bn, VARS)) {
                if(!irrelevants.stream().filter(x -> x == var).findAny().isPresent()) {
                    // factors <- [MAKE-FACTOR(var, e) | factors]
                    factors.add(0, makeFactor(var, e, bn));
                    // if var is hidden variable then factors <- SUM-OUT(var, factors)
                    if (hidden.contains(var)) {
                        factors = sumOut(var, factors, bn);
                    }
                    
                    /*Archi irrilevanti -->
                      Tolgo i figli delle var di evidenza facendo la sumout
                    */
                    if(evidence.stream().filter(x -> x == var).findAny().isPresent()){
                        System.out.println("summout la var " + var);
                        factors = sumOut(var, factors, bn);
                    }
                }
            }
            // return NORMALIZE(POINTWISE-PRODUCT(factors))
            Factor product = pointwiseProduct(factors);
            // Note: Want to ensure the order of the product matches the
            // query variables
            return ((ProbabilityTable) product.pointwiseProductPOS(_identity, X))
                            .normalize();
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
