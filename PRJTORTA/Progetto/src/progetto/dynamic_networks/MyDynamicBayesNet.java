package progetto.dynamic_networks;

import probability.RandomVariable;
import probability.bayes.BayesianNetwork;
import probability.bayes.Node;
import probability.bayes.impl.BayesNet;

import java.util.*;

public class MyDynamicBayesNet extends BayesNet implements MyDynamicBayesianNetwork {

    private Set<RandomVariable> X_0 = new LinkedHashSet<RandomVariable>();
    private Set<RandomVariable> X_1 = new LinkedHashSet<RandomVariable>();
    private Set<RandomVariable> E_1 = new LinkedHashSet<RandomVariable>();
    private Map<RandomVariable, List<RandomVariable>> X_0_to_X_1 = new LinkedHashMap<RandomVariable, List<RandomVariable>>();
    private Map<List<RandomVariable>, RandomVariable> X_1_to_X_0 = new LinkedHashMap<List<RandomVariable>, RandomVariable>();
    private BayesianNetwork priorNetwork = null;
    private List<RandomVariable> X_1_VariablesInTopologicalOrder = new ArrayList<RandomVariable>();

    public MyDynamicBayesNet(BayesianNetwork priorNetwork,
                           Map<RandomVariable, List<RandomVariable>> X_0_to_X_1,
                           Set<RandomVariable> E_1, Node... rootNodes) {
        super(rootNodes);

        for (Map.Entry<RandomVariable, List<RandomVariable>> x0_x1 : X_0_to_X_1.entrySet()) {
            RandomVariable x0 = x0_x1.getKey();
            List<RandomVariable> allX1 = x0_x1.getValue();

            this.X_0.add(x0);
            for(RandomVariable a : allX1)
                this.X_1.add(a);

            this.X_0_to_X_1.put(x0, allX1);
            this.X_1_to_X_0.put(allX1, x0);
        }
        this.E_1.addAll(E_1);

        // Assert the X_0, X_1, and E_1 sets are of expected sizes
        Set<RandomVariable> combined = new LinkedHashSet<RandomVariable>();
        combined.addAll(X_0);
        combined.addAll(X_1);
        combined.addAll(E_1);
        if (aima.core.util.SetOps.difference(varToNodeMap.keySet(), combined).size() != 0) {
            throw new IllegalArgumentException(
                    "X_0, X_1, and E_1 do not map correctly to the Nodes describing this Dynamic Bayesian Network.");
        }
        this.priorNetwork = priorNetwork;

        X_1_VariablesInTopologicalOrder.addAll(getVariablesInTopologicalOrder());
        X_1_VariablesInTopologicalOrder.removeAll(X_0);
        X_1_VariablesInTopologicalOrder.removeAll(E_1);
    }

    //
    // START-DynamicBayesianNetwork
    @Override
    public BayesianNetwork getPriorNetwork() {
        return priorNetwork;
    }

    @Override
    public Set<RandomVariable> getX_0() {
        return X_0;
    }

    @Override
    public Set<RandomVariable> getX_1() {
        return X_1;
    }

    @Override
    public List<RandomVariable> getX_1_VariablesInTopologicalOrder() {
        return X_1_VariablesInTopologicalOrder;
    }

    @Override
    public Map<RandomVariable, List<RandomVariable>> getX_0_to_X_1() {
        return X_0_to_X_1;
    }

    @Override
    public Map<List<RandomVariable>, RandomVariable> getX_1_to_X_0() {
        return X_1_to_X_0;
    }

    @Override
    public Set<RandomVariable> getE_1() {
        return E_1;
    }

    // END-DynamicBayesianNetwork
    //

    //
    // PRIVATE METHODS
    //
}
