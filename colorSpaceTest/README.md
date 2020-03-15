# colorSpaceTest

<img src="https://raw.githubusercontent.com/akuczala/processing-sketches/master/colorSpaceTest/color-screenshot.png" width="400">

This Processing sketch serves as a kind of colorblindness test, which attempts to map the perceptual color space. Participants are asked to look at fields of dots and report the range of hues perceived. Color space is (very simplistically) modeled as a disk, with the hue depending on the angle and the saturation depending on the radius. The included python notebook seeks to determine the most confused axes through this disk.

Includes data from four participants. Independently of the results, we know the following about the participants:
- "Mario" likely has Protanopia or Deuteranopia
- "Luigi" likely has Protanomaly or Deuteranomaly
- "Peach" - unknown 
- "Toad" has normal color vision.

The clearest result from this test was that colorblindness was strongly correlated with the amount of frustration expressed during the test.

## Controls
Drag the sliders to set the range of perceived hues.
- <kbd>space</kbd> Submit answer for a given trial, and move to the next trial
- <kbd>s</kbd> Save results to a .csv file
