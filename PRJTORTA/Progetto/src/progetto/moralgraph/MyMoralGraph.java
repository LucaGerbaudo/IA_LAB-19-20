package progetto.moralgraph;

import org.jgrapht.Graph;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;
import org.jgrapht.traverse.BreadthFirstIterator;
import probability.RandomVariable;
import probability.bayes.BayesianNetwork;
import probability.bayes.Node;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class MyMoralGraph {

    /**
     * Ritorna il set di variabili irrilevanti attraverso l'uso della m-separation
     * @param bayesianNetwork
     * @param queries
     * @param evidences
     * @return
     */
    public static Set<RandomVariable> irrilevantRandomVariable(BayesianNetwork bayesianNetwork,
                                                                Set<RandomVariable> queries,
                                                                Set<RandomVariable> evidences) {

        Set<RandomVariable> irrilevants = new HashSet<>();
        //Variabili eccetto query e evidenze
        Set<RandomVariable> others = new HashSet<>(bayesianNetwork.getVariablesInTopologicalOrder());
        others.removeAll(queries);
        others.removeAll(evidences);

        //Costruzione moralgraph
        Graph<RandomVariable, DefaultEdge> graph = graphFromBayesianNetwork(bayesianNetwork);
        moralizeGraph(graph, bayesianNetwork);

        //Rimozione delle variabili di evidenza dal grafo
        for (RandomVariable evidence: evidences) {
            graph.removeVertex(evidence);
        }

        //Per ogni variabile di query si costruisce il path, una variabile è irrilevante se non ne fa parte
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

    /**
     * Costruizione di un grafo non orientato a partire da una rete bayesiana
     * @param bayesianNetwork
     * @return
     */
    static Graph<RandomVariable, DefaultEdge> graphFromBayesianNetwork(BayesianNetwork bayesianNetwork) {
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

    /**
     * Costruisce il Moral Graph a partire dal grafo della bn
     * @param graph
     * @param bn
     */
    static void moralizeGraph(Graph<RandomVariable, DefaultEdge> graph, BayesianNetwork bn) {
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
}
