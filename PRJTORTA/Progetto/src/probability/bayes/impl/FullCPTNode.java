package probability.bayes.impl;

import probability.RandomVariable;
import probability.bayes.ConditionalProbabilityDistribution;
import probability.bayes.ConditionalProbabilityTable;
import probability.bayes.FiniteNode;
import probability.bayes.Node;

import java.util.Set;

/**
 * Default implementation of the FiniteNode interface that uses a fully
 * specified Conditional Probability Table to represent the Node's conditional
 * distribution.
 * 
 * @author Ciaran O'Reilly
 * 
 */
public class FullCPTNode extends AbstractNode implements FiniteNode {
	protected ConditionalProbabilityTable cpt = null;

	public FullCPTNode(RandomVariable var, double[] distribution) {
		this(var, distribution, (Node[]) null);
	}

	public FullCPTNode(RandomVariable var, double[] values, Node... parents) {
		super(var, parents);

		RandomVariable[] conditionedOn = new RandomVariable[getParents().size()];
		int i = 0;
		for (Node p : getParents()) {
			conditionedOn[i++] = p.getRandomVariable();
		}

		cpt = new CPT(var, values, conditionedOn);
	}

	//
	// START-Node
	@Override
	public ConditionalProbabilityDistribution getCPD() {
		return getCPT();
	}

	// END-Node
	//

	//
	// START-FiniteNode

	@Override
	public ConditionalProbabilityTable getCPT() {
		return cpt;
	}
	// END-FiniteNode
	//

	public void setCPT(RandomVariable var, double[] values, Node... parents) {
		RandomVariable[] conditionedOn = new RandomVariable[getParents().size()];
		int i = 0;
		for (Node p : getParents()) {
			conditionedOn[i++] = p.getRandomVariable();
		}
		this.cpt = new CPT(var, values, conditionedOn);
	}

	@Override
	public void setChildren(Set<Node> children) {
		for(Node n : children)
			this.addChild(n);
	}
}
