import math

from mesa.visualization.ModularVisualization import ModularServer
from mesa.visualization.UserParam import UserSettableParameter
from mesa.visualization.modules import NetworkModule, ChartModule
from mesa.visualization.modules import TextElement

from visualisations import CustomNetworkModule
from model import OpinionNetworkModel, Opinion, SubCulture, opinion_count 


OPINION_COLOURS ={
  Opinion.NEUTRAL: '#AAAAAA',
  Opinion.YES: '#8888FF',
  Opinion.NO: '#FF8888'
} 

def network_portrayal(G):
  def node_color(agent):
    return OPINION_COLOURS.get(agent.opinion, '#333333')

  def edge_color(agent1, agent2):
    subculture = agent1 if agent1 is SubCulture else agent2
    return OPINION_COLOURS.get(subculture.opinion, '#333333')

  def edge_width(agent1, agent2):
    return 2

  def get_agents(source, target):
    return G.node[source]['agent'][0], G.node[target]['agent'][0]

  portrayal = dict()
  portrayal['nodes'] = [{'size': 6,
                         'x': (node['agent'][0].unique_id-20)*10,
                         'y': (node['bipartite']-0.5)*200,
                         'color': node_color(node["agent"][0]),
                         'tooltip': f'id: {node["agent"][0].unique_id}<br>opinion: {node["agent"][0].opinion.name}',
                         'id': id
                        }
                        for (id, node) in G.nodes.data()]

  portrayal['edges'] = [{'source': source,
                         'target': target,
                         'color': edge_color(*get_agents(source, target)),
                         'width': edge_width(*get_agents(source, target)),
                         'id': f'{source}-{target}',
                         }
                        for (source, target, _) in G.edges]

  return portrayal


network = NetworkModule(network_portrayal, 500, 500, library='d3')
bipartite = CustomNetworkModule(network_portrayal, 500, 500, library='d3')
chart = ChartModule([{'Label': 'Neutral', 'Color': OPINION_COLOURS.get(Opinion.NEUTRAL)},
                     {'Label': 'Yes',     'Color': OPINION_COLOURS.get(Opinion.YES)},
                     {'Label': 'No',      'Color': OPINION_COLOURS.get(Opinion.NO)}])


class Results(TextElement):
  def render(self, model):
    ratio = model.seeded_opinion_ratio()
    return f'Seeded/Background Ratio: {ratio:.2f}'


model_params = {
    'background_opinion': UserSettableParameter('choice', 'Background Opinion', value=Opinion.NEUTRAL.name, choices=[opinion.name for opinion in Opinion],
                                       description='The opinion most people have'),
    'seeded_opinion': UserSettableParameter('choice', 'Seeded Opinion', value=Opinion.YES.name, choices=[opinion.name for opinion in Opinion],
                                       description='The minority opinion'),
    'num_people': UserSettableParameter('slider', 'Number of people', 50, 10, 100, 1,
                                       description='Choose how many people to include in the model'),
    'num_subcultures': UserSettableParameter('slider', 'Number of subcultures', 10, 2, 50, 1,
                                       description='Choose how many subcultures to include in the model'),
    'avg_node_degree': UserSettableParameter('slider', 'Avg Node Degree', 5, 2, 8, 1,
                                             description='Average number of connections per person'),
    'initial_seed_size': UserSettableParameter('slider', 'Initial Seed Size', 10, 1, 20, 1,
                                                   description='Initial number of people with the seeded opinion'),
    'opinion_change_chance': UserSettableParameter('slider', 'Opinion change Chance', 0.4, 0.0, 1.0, 0.1,
                                                 description='Probability that a person will change their opinion to the majority of their neighbours'),
    'opinion_check_frequency': UserSettableParameter('slider', 'Opinion Check Frequency', 0.4, 0.0, 1.0, 0.1,
                                                   description='Frequency at which the people check their opinions'),
}

server = ModularServer(OpinionNetworkModel, [network, bipartite, Results(), chart], 'Opinion Network Model', model_params)
server.port = 8521
server.launch()
