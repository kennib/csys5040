import math
import random
from enum import Enum
from collections import Counter
from itertools import islice

import networkx as nx
from networkx.algorithms import bipartite

from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.datacollection import DataCollector
from mesa.space import NetworkGrid


class Opinion(Enum):
  NEUTRAL = 0
  YES = 1
  NO = 2


def opinion_count(model, opinion):
  return sum([1 for a in model.grid.get_all_cell_contents() if a.opinion is opinion])

class OpinionNetworkModel(Model):
  """A model of opinions on a network with some nodes"""

  def __init__(self, background_opinion=Opinion.NO, seeded_opinion=Opinion.YES,
                     num_people=50, num_subcultures=10, avg_node_degree=5, initial_seed_size=3,
                     opinion_change_chance=0.4, opinion_check_frequency=0.4):

    self.num_people = num_people
    self.num_subcultures = num_subcultures
    total_degrees = avg_node_degree*self.num_people
    subculture_degrees = []
    for i in range(self.num_subcultures):
      degrees_left = total_degrees-sum(subculture_degrees)
      subcultures_left = self.num_subcultures - i
      subculture_degrees.append(random.randrange(1, degrees_left - subcultures_left) if subcultures_left > 1 else degrees_left)

    self.G = bipartite.configuration_model([avg_node_degree]*self.num_people, subculture_degrees)
    people, subcultures = bipartite.sets(self.G)

    self.grid = NetworkGrid(self.G)
    self.schedule = RandomActivation(self)

    self.background_opinion = next((opinion for opinion in Opinion if opinion.name == background_opinion), None)
    self.seeded_opinion = next((opinion for opinion in Opinion if opinion.name == seeded_opinion), None) 
    self.initial_seed_size = min(initial_seed_size, self.num_people+self.num_subcultures)
    self.opinion_change_chance = opinion_change_chance
    self.opinion_check_frequency = opinion_check_frequency

    self.datacollector = DataCollector({"Neutral": lambda model: opinion_count(model, Opinion.NEUTRAL),
                                        "Yes": lambda model: opinion_count(model, Opinion.YES),
                                        "No": lambda model: opinion_count(model, Opinion.NO)})

    # Create People
    for i, node in enumerate(people):
      p = Person(i, self, self.background_opinion, self.opinion_change_chance, self.opinion_check_frequency)
      self.schedule.add(p)
      # Add the Person to the node
      self.grid.place_agent(p, node)

    # Create SubCultures
    for i, node in enumerate(subcultures):
      s = SubCulture(i, self)
      self.schedule.add(s)
      # Add the SubCulture to the node
      self.grid.place_agent(s, node)

    # Seed some opinions
    seed = self.random.sample(subcultures, 1)[0]
    seed_network = nx.algorithms.traversal.depth_first_search.dfs_preorder_nodes(self.G, seed)
    for node in islice(seed_network, initial_seed_size):
      person = self.G.nodes[node]['agent'][0]
      person.opinion = self.seeded_opinion

    self.running = True
    self.datacollector.collect(self)

  def seeded_opinion_ratio(self):
    try:
      return opinion_count(self, self.seeded_opinion) / opinion_count(self, self.background_opinion)
    except ZeroDivisionError:
      return math.inf

  def step(self):
    self.schedule.step()
    self.datacollector.collect(self)

  def run_model(self, n):
    for i in range(n):
      self.step()


class Person(Agent):
  def __init__(self, unique_id, model, initial_opinion, opinion_change_chance, opinion_check_frequency):
    super().__init__(unique_id, model)

    self.opinion = initial_opinion 

    self.opinion_change_chance = opinion_change_chance
    self.opinion_check_frequency = opinion_check_frequency

  def try_to_change_opinion(self):
    neighbour_nodes = self.model.grid.get_neighbors(self.pos, include_center=False)

    if neighbour_nodes:
      opinions = Counter([agent.opinion for agent in self.model.grid.get_cell_list_contents(neighbour_nodes)])
      majority_opinion, majority_opinion_count = opinions.most_common()[0]
       
      if self.random.random() < self.opinion_change_chance:
        self.opinion = majority_opinion

  def step(self):
    if self.random.random() < self.opinion_check_frequency:
      self.try_to_change_opinion()


class SubCulture(Person):
  def __init__(self, unique_id, model):
    super().__init__(unique_id, model, Opinion.NEUTRAL, 1, 1)
