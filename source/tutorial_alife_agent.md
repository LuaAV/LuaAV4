# Multi-agent systems (agent-based models)

## What is an agent?

An autonomous agent interacts within an environment populated by other agents, but behaves independently without taking direct commands from other agents nor a global planner or leader. Agent-based models typically operate in parallel within a spatial environment, in which agents are often (but not always) mobile, but interactions are usually limited to local distances. Because of this, with a few simple rules rather complex collective behavior can emerge.

The agent abstraction has arisen somewhat independently in different fields, thus the definition of an agent can vary widely. However the following components are usually present:

- **Properties**: Persistent but variable features of an agent, such as size, color, speed, direction, energy level, and so on. 
- **Input**: Limited capabilities of sensing (or receiving messages from) the environment
- **Output**: Limited capabilities of performing actions on (or sending messages to) the environment, or its own properties. Typically this includes the ability to move through space.
- **Processing**: An information processing capacity to select actions in response to inputs. This capacity may also include information storage (memory).
- **Motivations**: The agent may also incorporate explicit goals or purposes in the form of self-evaluation and self-adaptation; or these may be implict in the design of the processing algorithm.

As a biological approximation, an agent could refer to anything from individual proteins, viruses, cells, bacteria, organisms, or population groups. Agent systems also share similarities with particle systems.

### Agents in LuaAV

Like most things in Lua, we can represent an agent as a table. Similarly, we can represent a whole population of agents as a table!

```lua
local vec2 = require "vec2"

-- a function to construct one new agent:
function agent_make()
	local self = {
		-- insert properties of agent here:
		location = vec2(math.random(), math.random()),
		orientation = math.random() * math.pi * 2,
		size = 0.02,
	}
	return self
end

-- a container for all the agents currently active:
local agents = {}

-- initialize with 10 agents:
for i = 1, 10 do
	agents[i] = agent_make()
end
```

Agents are dynamic, which means we need a function to update the state of all agents. We can trigger this from the global ```update()``` function in LuaAV:

```lua
-- update the state of one agent:
function agent_update(self)
	-- update the state of agent 'self' here
	-- use agent sensors, 
	-- perform information processing, 
	-- update motivations, 
	-- perform information processing, 
	-- produce output and behavior
	-- e.g. random walk to the right:
	self.location.x = self.location.x + (math.random() * 0.01)
end

-- In LuaAV, the update() function is called frequently to update simulation state
-- (the dt argument is the seconds elapsed since the last frame)
function update(dt)
	-- update the state of all agents:
	for i, a in ipairs(agents) do
		agent_update(a)
	end
end
```

We can use a similar mechanism to render agents visible. For convenience, we can use the [draw2D](tutorial_2D.html) module to prepare a coordinate system centered on each agent:

```lua
local draw2D = require "draw2D"

-- update the state of one agent:
function agent_draw(self)
	-- the center of the agent is at (0, 0), and it faces in the positive X direction
	-- e.g. draw a box around the agent that is longer in X than Y:
	draw2D.rect(0, 0, 2, 1)
end

-- In LuaAV, the draw() function is called once per frame
function draw()
	-- update the state of all agents:
	for i, a in ipairs(agents) do
		-- set up a new coordinate system
		draw2D.push()
		-- centered on the agent, in the agent's point of view, at the agent's size
		draw2D.translate(a.location.x, a.location.y)
        draw2D.rotate(a.orientation)
        draw2D.scale(a.size)
        
        -- draw the agent:
		agent_draw(a)
		
		-- restore the previous coordinate system
		draw2D.pop()
	end
end
```

> If you may be randomly adding and removing agents to a population, it may be better to represent the population as a dictionary rather than a list. The important differences are that the agents become the **keys** rather than the **values** of the table. We can just use the boolean ```true``` as the value. Removing an agent is then as simple assigning a value of ```nil``` to the agent key. Iterating the dictionary of agents then will use ```pairs``` rather than ```ipairs```. 

For simple agent behaviors take a look [at the tutorial on vectors and forces](tutorial_vec_force.html).

## Tortoises and Vehicles

In the 1950'sCyberneticist Grey Walter pioneered the engineering of agents, as early examples of autonomous robots, with his *"tortoises"*. Remarkably, this direction of research was largely forgotten as efforts in artificial intelligence concentrated on symbolic thinking. (Brief history [here](http://www.rutherfordjournal.org/article020101.html)).

[![Machina Speculatrix](http://www.rutherfordjournal.org/images/020101-05.jpg) >> video](http://www.youtube.com/watch?v=lLULRlmXkKo)

Nevertheless, Walter's tortoises inspired the turtle graphics of Logo, the situated robotics of Rodney Brooks, the flocking behaviors of Craig Reynolds, and Valentino Braitenberg's Vehicles.

> A Braitenberg vehicle is an agent that can autonomously move around. It has primitive sensors (measuring some stimulus at a point) and wheels (each driven by its own motor) that function as actuators or effectors. A sensor, in the simplest configuration, is directly connected to an effector, so that a sensed signal immediately produces a movement of the wheel. Depending on how sensors and wheels are connected, the vehicle exhibits different behaviors (which can be goal-oriented).  [wikipedia](http://en.wikipedia.org/wiki/Braitenberg_vehicle)

![Vehicle](http://faculty.washington.edu/gmobus/AdaptiveAgents/B-vehicles.gif)

Cyberneticist Valentino Braitenberg argues that his extraordinarily simple mechanical vehicles manifest behaviors that appear identifiable as fear, aggression, love, foresight, and optimism. The vehicle idea was a thought experiment conceived to show that complex, apparently purposive behaviour did not need to depend on complex representations of the environment inside a creature or agents brain. In fact simply by reacting to the environment in a consistent manner was more than enough to explain the low level reactive behaviours exhibited by many animals.

> Braitenberg, V. (1984). Vehicles: Experiments in synthetic psychology. Cambridge, MA: MIT Press. 

Casey Reas (co-author of Processing), Yanni Loukissas, and many others have used populations of Braitenberg-inspired vehicles to create artworks based on their combined paths.

![Reas' Tissue](http://reas.com/tissue_p/reas_tissue_p_13.jpg)

Vehicles have also been constructed in hardware of course -- see examples [here](http://www.ini.uzh.ch/~conradt/research/BraitenbergVehicle/), [here](http://blog.electricbricks.com/en/2010/05/vehiculos-braitenberg-nxt-g/), [here](http://tinkerlog.com/2009/06/07/mini-braitenberg-vehicle/).

### Vehicles in LuaAV

See the [code example](https://github.com/LuaAV/LuaAV4/blob/master/examples/alife/agent_vehicles.lua). 

## Steering Behaviors

Craig Reynolds' work with robotics is strongly inspired by Braitenberg's and Walter's vehicles, and became famous for his work on simulating flocking behavior (see below). His work has been widely used in robotics, game design, special effects and simulation. Reynolds' paper [Steering Behaviors for Autonomous Characters](http://www.red3d.com/cwr/steer/gdc99/) breaks agent movement into three layers:

- **Action Selection**: selecting actions to perform according to environmental input and goals to achieve. 
- **Steering**: path determination according to the action selected. Many different behaviors can be used; the essential strategy is ```steering force = desired_velocity - current_velocity```.
- **Locomotion**: mechanisms of conversion of steering into actual movement.

The paper is well worth exploring as a collection of patterns for autonomous agent movements; and presents the elements that make up his simulation of flocking behavior.

### Boids, flocking, swarms

In the late 1980s Reynolds proposed a model of animal motion to model flocks, herds and schools, which he named *boids*. Each boid follows a set of rules based on simple principles:

- **Avoidance**: Move away from other boids that are too close (avoid collision)
- **Copy**: Fly in the same general direction as other nearby boids
- **Center**: Move toward the center of the flock (avoid exposure)

To make this more realistic, we can consider that each boid can only perceive other boids within a certain distance and viewing angle. We should also restrict how quickly boids can change direction and speed (to account for momentum). Additionally, the avoidance rule may carry greater *weight* or take precedence over the other rules. Gary Flake also recommends adding an influence for *View*: to move laterally away from any boid blocking the view.

In addition, if none of the conditions above apply, i.e. the boid cannot perceive any others, it may move by random walk. 

> A **random walk** involves small random deviations to steering. This produces a **random walk** or **Brownian motion**, a form of movement that is widely utilized by nature. In Reynolds' paper it is the *wander* steering strategy.

Evidently the *properties* of a boid (apart from location) include direction and speed. It could be assumed that viewing angle and range are shared by all boids, or these could also vary per individual. The *sensors* of a boid include an ability to detect the density of boids in different directions (to detect the center of the flock), as well as the average speed and direction of boids, within a viewable area. The *actions* of a boid principally are to alter the direction and speed of flight. 

#### Boids in LuaAV

The behavior of an agent depends on the other agents that it can perceive (the *neighborhood*). The simplest way to detect nearby agents is to simply iterate all agents and apply a distance condition (being careful to exclude the agent itself!). We can also include a view angle condition (easily calculated using vector dot product):

```lua
local view_range = 0.1 	-- how far an agent can see

function agent_update_sensors(self)
	-- create a list of nearby agents:
	local neighbors = {}
	-- test all agents:
	for i, near in ipairs(agents) do
		-- don't compare with ourself!
		if near ~= self then		
			-- near enough?
			local rel = near.location - self.location
			if rel:length() < view_range then
				-- is the neighbor in front of us?
				-- (use dot product of my velocity to determine this)
				if self.velocity:dot(rel) > 0 then
					-- add this to the set of neighbors:
					neighbors[#neighbors+1] = near
				end
			end
		end
	end
	
	if #neighbors > 0 then
		-- now calculate steering influence according to visible neighbors:
		-- ...
	else
		-- no visible neighbors, so we can explore freely...
		-- ...
	end
end
```

> This isn't especially efficient, but for small populations it is quite reasonable; for larger populations we recommend using the ```hashspace``` module. 

Once a set of visible neighbors is calculated, it can be used to derive the steering influences of the agent. The center force depends on the average location of neighbors, relative to the agent. The copy force depends on the average velocity of neighbors. The avoidance force applies if a neighbor is too close.

> Note that since the agents are dependent on each other, it also makes sense to perform movements and information processing in separate steps. Otherwise, the order in which the agent list is iterated may cause unwanted side-effects on the behavior. (This multi-pass approach is similar in motivation to the double buffering required in many cellular automata).

See the full [code example](https://github.com/LuaAV/LuaAV4/blob/master/examples/alife/agent_boids.lua)

### Chemotaxis

However, when we look at microbiology, we find even simpler modes of steering behavior.

> Chemotaxis is the phenomenon whereby somatic cells, bacteria, and other single-cell or multicellular organisms direct their movements according to certain chemicals in their environment. This is important for bacteria to find food (for example, glucose) by swimming towards the highest concentration of food molecules, or to flee from poisons (for example, phenol). In multicellular organisms, chemotaxis is critical to early development (e.g. movement of sperm towards the egg during fertilization) and subsequent phases of development (e.g. migration of neurons or lymphocytes) as well as in normal function. [wikipedia](https://en.wikipedia.org/wiki/Chemotaxis)

A [video example of chemotaxis in E. coli](http://www.youtube.com/watch?v=ZV5CfOkV6ek).

E. coli can use its flagella to move in just two modes (*locomotion*): 

- Move forward more or less straight
- Tumble about randomly

The *goal* is to find the highest sugar concentration. It can sense the local sugar concentration at its current location. However it cannot sense at a distance, and has no sense of direction, never mind which direction is best. 

Instead it uses chemical memory to detect sugar concentration *gradient*, that is, the differential of concentration at the current location compared to how it was just a few moments ago. This gradient tells the E. coli whether things are getting better or worse, which can be used to select between the swimming or tumbling patterns. 

With just a few tuning parameters, this can lead to a very rapid success in finding the higher concentrations of sugar (assuming the environment is smoothly varying).

#### Chemotaxis in LuaAV

The first thing we need is an environment of varying sugar concentrations for the agents to explore. We can use the ```field2D``` module for this purpose. The behavior of the agents will depend on the spatial distribution of sugar in the field; a totally random space is both unrealistic and will defeat chemotactic strategies; a smoothly distributed landscape is needed. For example, we can use the distance from the center:

```
local field2D = require "field2D"
local dim = 128
local sugar = field2D(dim, dim)
local center = vec2(0.5, 0.5)

sugar:set(function(x, y)
	-- convert x, y in to 0..1 range:
	local p = vec2(x / dim, y / dim)
	-- get distance from center:
	local d = #(p - center)
	-- make concentration higher at center, lower with increasing distance:
	return 1 - d
end)
```

Agents can then sample the local field during their update routine as follows:

```lua
	-- in agent_update:
	local sugar_concentration = sugar:sample(self.location.x, self.location.y)
```

See the [code example](https://github.com/LuaAV/LuaAV4/blob/master/examples/alife/agent_chemotaxis.lua)

A variety of other *taxes* worth exploring can be found on the [wikipedia page](http://en.wikipedia.org/wiki/Taxis#Aerotaxis). Note how chemotaxis (and other taxes) can be divided into positive (attractive) and negative (repulsive) characters, just like forces (directly seen in steering forces). 

### Stigmergy

*Stigmergy* is a mechanism of indirect coordination between agents by leaving traces in the environment as a mode of stimulating future action by agents in the same location. For example, ants (and some other social insects) lay down a trace of pheromones when returning to the nest while carrying food. Future ants are attracted to follow these trails, increasing the likelihood of encountering food. This environmental marking constitutes a shared external memory (without needing a map). However if the food source is exhausted, the pheromone trails will gradually fade away, leading to new foraging behavior. 

Traces evidently lead to self-reinforcement and self-organization: complex and seeminly intelligent structures without global planning or control. Since the term stigmergy focuses on self-reinforcing, task-oriented signaling, E. O. Wilson suggested a more general term *sematectonic communication* for environmental communication that is not necessarily task-oriented.

Stigmergy has become a key concept in the field of [swarm intelligence](http://en.wikipedia.org/wiki/Swarm_intelligence), and the method of *ant colony optimization* in particular. In ACO, the landscape is a parameter space (possibly much larger than two or three dimensions) in which populations of virtual agents leave pheromone trails to high-scoring solutions.

Related environmental communication strategies include social nest construction (e.g. termites) and territory marking.

#### Stigmergy in LuaAV

Being able to leave pheromones behind depends on the ability to write into as well as read from fields. This can be achieved using the ```splat``` method of the field:

```lua
	-- in agent update:
	pheromone_field:splat(intensity, self.location.x, self.location.y)
```

To store different pheromones we might want to use different fields. These fields should also probably decay over time (using the ```field:decay()``` method), and possibly diffuse slightly (using the ```field:diffuse()``` method).

To detect field intensites in different directions, we might want to sample with sensors further from the body center (similar to the sensors in the Vehicles model) and compare their results. 



See the [code example](https://github.com/LuaAV/LuaAV4/blob/master/examples/alife/agent_stigmergy.lua)
