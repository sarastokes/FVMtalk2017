# Fall Vision Meeting 2017
The following code was used in a talk I gave at the 2017 Fall Vision Meeting.


## Implications of the S-OFF midget pathway for yellow sensations


Sara Patterson<sup>1</sup>, James Kuchenbecker<sup>1</sup>, Andrea Bordt<sup>2</sup>, James Anderson<sup>3</sup>, David Marshak<sup>2</sup>, Michael Manookin<sup>1</sup>, Maureen Neitz<sup>1</sup>, Jay Neitz<sup>1</sup>

<sup>1</sup> Department of Ophthalmology, University of Washington, Seattle, WA, 98109

<sup>2</sup> Department of Neurobiology and Anatomy, University of Houston Health Science Center, Houston, TX, 77030

<sup>3</sup> John Moran Eye Center, University of Utah Health Science Center, Salt Lake City, UT, 84132

## Use
This repository contains the following code:
* Spike and stimulus demo videos (spikeDemo.m)
* Simulation of OFF-midget responses to drifting gratings
* Image filtering with center-surround receptive fields (dogDemo.m)
* Ganglion cell spectral RF model (a very simple version of Brian Schmidt's excellent work - [color][briancode])
* Code for viewing stacks of EM images and creating videos (ImageStackApp.m)
* Analysis of cone outline tracings (coneAnalysis.m)


The rest of the code depends on my EM analysis repository, [sbfsem-tools][sbfsem-tools]
* Synapse counts are part of the base neuron analysis [->][neuron]
* Horizontal cell dendrite diameter [->][pridend]

I intend to add the slides and raw data after publication.

## Software
Almost all the code requires Matlab. The EM annotations used [Viking][viking] a software developed by Jamie Anderson in the Marc lab. 3D reconstructions were rendered in [Blender][blender], which is open-source. The electrophysiology data was collected with protocols and analyses ([sara-package][sarapack]) written for [Symphony][symphony] and [Stage][stage].

For more information:
* [Neitz Lab website][neitz]
* Contact sarap44@uw.edu

## References
Anderson, J. R., Mohammed, S., Grimm, B., Jones, B. W., Koshevoy, P., Tasdizen, T., Whitaker, R., Marc, R. E. (2011) The Viking viewer for connectomics: scalable multi-user annotation and summarization of large volume data sets. *Journal of Microscopy*, 241(1), 13-28 [->][anderson2011]

Calkins, D. J., Tsukamoto, Y., Sterling, P. (1998) Microcircuitry and mosaic of a blue-yellow ganglion cell in the primate retina *Journal of Neuroscience*, 18(9), 3373-3385 [->][calkins1998]

Calkins, D.J. & Sterling, P. (1999) Evidence that circuits for spatial and color vision segregate at the first retinal synapse. *Neuron*, 24(2), 313-321 [->][calkins1999]

Klug, K., Herr, S., Ngo, I.T., Sterling, P. & Schein, S. (2003) Macaque retina contains an S-cone OFF midget pathway. *Journal of Neuroscience*, 23(30), 9881-9887 [->][klug2003]

Neitz, J. & Neitz, M. (2017) Evolution of the circuitry for conscious color vision in primates. *Eye*, 31, 286-300 [->][neitz2017]

Puller, C., Haverkamp, S., Neitz, M., & Neitz, J. (2015) Synaptic elements for GABAergic feed-forward signaling between HII horizontal cells and blue cone bipolar cells are enriched beneath primate S-cones. *PLoS One*, 9(2), e88963 [->][puller2015]

Sabesan, R., Schmidt, B.P., Tuten, W.S. & Roorda, A. (2016) The elementary representation of spatial and color vision in the human retina. *Science Reports* [->][sabesan2016]

Schmidt, B.P., Neitz, M. & Neitz, J. et al (2014) Neurobiological hypothesis of color and hue perception. *JOSA A*, 31(4), A195-A207 [->][schmidt2014]


   [neitz]: <http://www.neitzvision.com/>

   [blender]: <http://www.blender.com>
   [symphony]: <http://symphony-das.github.io/>
   [stage]: <http://stage-vss.github.io/>
   [tulip]: <http://tulip.labri.fr/TulipDrupal/>
   [viking]: <https://connectomes.utah.edu/>

   [sarapack]: <http://github.com/sarastokes/sara-package>
   [sbfsem-tools]:<http://github.com/sarastokes/sbfsem-tools>
   [briancode]: <https://github.com/bps10/color>

   [imagestack]: <https://github.com/sarastokes/SBFSEM-tools/tree/master/images>
   [neuron]: <https://github.com/sarastokes/SBFSEM-tools/tree/master/neuron>
   [pridend]:<https://github.com/sarastokes/SBFSEM-tools/blob/master/analysis/PrimaryDendriteDiameter.m>

   [anderson2011]: <http://onlinelibrary.wiley.com/doi/10.1111/j.1365-2818.2010.03402.x/full>
   [calkins1999]: <http://www.sciencedirect.com/science/article/pii/S0896627300808466>
   [calkins1998]: <http://www.jneurosci.org/content/18/9/3373.short>
   [klug2003]: <http://www.jneurosci.org/content/23/30/9881.short>
   [neitz2017]: <https://www.nature.com/eye/journal/v31/n2/abs/eye2016257a.html>
   [puller2015]: <http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0088963>
   [sabesan2016]: <http://advances.sciencemag.org/content/2/9/e1600797.full>
   [schmidt2014]: <https://www.osapublishing.org/josaa/abstract.cfm?uri=josaa-31-4-A195>