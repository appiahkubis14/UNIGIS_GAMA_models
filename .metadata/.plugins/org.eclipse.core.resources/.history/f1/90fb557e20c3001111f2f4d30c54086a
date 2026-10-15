/**
* Name: NewModel
* Based on the internal empty template. 
* Author: samuel-appiah-kubi
* Tags: 
*/


model NewModel

/* Insert your model definition here */

global{
	int num_1 <- 1;
	
	init{
		create my_agents number:10 {
			speed <- 2.0;
		}
	}
}

species my_agents skills:[moving]{
	reflex move{
		do wander;
	}
	aspect default{
		draw circle(3) color:#red;
	}
}

experiment  maain_experiment type:gui{
	parameter "My Variable" var: num_1;
	output{
		display map {
			species my_agents aspect:default;
		}
	}
}