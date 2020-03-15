# drawNetwork

![alt text](screenshot)

GUI tool for constructing and viewing tensor networks. Used for constructing (1+1) dimensional networks in the [MERA repo](www.github.com/akuczala/MERA/MERA-1D).

##controls

-Add a tensor:
    - <kbd>w</kbd>: Isometry
    - <kbd>u</kbd>: Disentangler
    - <kbd>h</kbd>: On-site hamiltonian operator
    - <kbd>r</kbd>: Reduced density matrix
- Capitalized letters yield daggered tensors

- <kbd>k</kbd> Delete moused-over tensor

- <kbd>c</kbd> Cancel creation of current link or cut a link by mousing over it

- <kbd>s</kbd> Print tensor positions
- <kbd>p</kbd> Print links 


- <kbd>l</kbd>
	Load saved network from text file. these files currently have to be manually written by copying and pasting from the outputs of  <kbd>p</kbd> and <kbd>s</kbd>. The format should be:
		- line 1: tensor names: `{<t1>,<t2>,<t3>...}`
		- line 2: list of links, i.e: `{[1,2,3],[4,5,6]}`
		- line 3: tensor positions: `100,200:300,400`

screenshot: https://github.com/akuczala/processing-sketches/drawNetwork/network-screenshot.png "screenshot"