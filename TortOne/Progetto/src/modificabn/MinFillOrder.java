package modificabn;

import probability.CategoricalDistribution;
import probability.Factor;
import probability.RandomVariable;
import probability.bayes.BayesInference;
import probability.bayes.BayesianNetwork;
import probability.bayes.FiniteNode;
import probability.bayes.Node;
import probability.bayes.exact.EliminationAsk;
import probability.bayes.exact.EnumerationAsk;
import probability.proposition.AssignmentProposition;
import probability.util.ProbabilityTable;
import bnparser.BifReader;

import java.util.*;

import org.jgrapht.Graph;
import org.jgrapht.Graphs;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;


public class MinFillOrder {

    public static List<RandomVariable> minFillOrder(BayesianNetwork bn) {
        Graph<RandomVariable, DefaultEdge> interactionGraph = interactionGraph(bn);
        List<RandomVariable> randomVariables = new ArrayList<>(bn.getVariablesInTopologicalOrder());
        List<RandomVariable> pi = new ArrayList<>();
        int len = randomVariables.size();

        for (int i = 0; i < len; i++) {
            RandomVariable rvSmallestNeighbour = rvWithSmallestNumNeighbor(interactionGraph);
            pi.add(rvSmallestNeighbour);
            addEdgesNonAdjacentNeighbours(interactionGraph, rvSmallestNeighbour);
            interactionGraph.removeVertex(rvSmallestNeighbour);
            randomVariables.remove(rvSmallestNeighbour);
        }

        return pi;
    }

    private static RandomVariable rvWithSmallestNumNeighbor(Graph<RandomVariable, DefaultEdge> graph) {
        RandomVariable rvSmallestNeighbour = null;
        int minNumNeighbor = Integer.MAX_VALUE;
        for (RandomVariable var: graph.vertexSet()) {
            int numAddEdges = getNumEdgesNonAdjacentNeighbours(graph, var);
            if (numAddEdges < minNumNeighbor) {
                rvSmallestNeighbour = var;
                minNumNeighbor = numAddEdges;
            }
        }

        return rvSmallestNeighbour;
    }

    private static void addEdgesNonAdjacentNeighbours(Graph<RandomVariable, DefaultEdge> graph, RandomVariable var) {
        List<RandomVariable> neighbors = Graphs.neighborListOf(graph, var);
        for (int k = 0; k < neighbors.size(); k++) {
            for (int j = k + 1; j < neighbors.size(); j++) {
                if (!graph.containsEdge(neighbors.get(k), neighbors.get(j))) {
                    graph.addEdge(neighbors.get(k), neighbors.get(j));
                }
            }
        }
    }

    private static int getNumEdgesNonAdjacentNeighbours(Graph<RandomVariable, DefaultEdge> graph, RandomVariable var) {
        int i = 0;
        List<RandomVariable> neighbors = Graphs.neighborListOf(graph, var);
        for (int k = 0; k < neighbors.size(); k++) {
            for (int j = k + 1; j < neighbors.size(); j++) {
                if (!graph.containsEdge(neighbors.get(k), neighbors.get(j))) {
                    i++;
                }
            }
        }
        return i;
    }

    private static Graph<RandomVariable, DefaultEdge> interactionGraph(BayesianNetwork bn) {
        Graph<RandomVariable, DefaultEdge> interactionGraph = new SimpleGraph<>(DefaultEdge.class);
        List<Factor> factors = new ArrayList<>();

        for (RandomVariable randomVariable: bn.getVariablesInTopologicalOrder()) {
            factors.add(0, makeFactor(randomVariable, new AssignmentProposition[] {}, bn));
        }


        for (Factor factor: factors) {
            List<RandomVariable> argVars = new ArrayList<>(factor.getArgumentVariables());

            for (int i = 0; i < argVars.size(); i++) {
                if (!interactionGraph.containsVertex(argVars.get(i))) {
                    interactionGraph.addVertex(argVars.get(i));
                }

                for (int j = i + 1; j < argVars.size(); j++) {
                    if (!interactionGraph.containsVertex(argVars.get(j))) {
                        interactionGraph.addVertex(argVars.get(j));
                    }
                    if (!interactionGraph.containsEdge(argVars.get(i), argVars.get(j))) {
                        interactionGraph.addEdge(argVars.get(i), argVars.get(j));
                    }
                }
            }
        }

        return interactionGraph;
    }

    //
    // PRESO DA ELIMINATIONASK
    //
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
