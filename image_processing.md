## IMAGE PROCESSING UNIT
we have considered luminosity algorithm as our source algorithm 

🌟 What is the Luminosity Algorithm?

The luminosity algorithm is a simple way to convert a color image (RGB) into a grayscale image — but it does it smartly. Instead of just averaging the red, green, and blue values, it takes into account how bright each color appears to our eyes.

Why not just average RGB?

If you simply average red, green, and blue like this: 
## Grayscale = (R + G + B) / 3

Then You’d get a dull result because our eyes don’t treat all colors equally. We see green as brighter than red, and red as brighter than blue.

So we rather use this: 
## Grayscale = 0.299  * R + 0.587 * G +  0.114 * B

 Existing technique of RGB to Gray conversion
 
 ![Screenshot from 2025-07-05 12-19-23](https://github.com/user-attachments/assets/4a8fd876-fb28-4ba8-b156-a61bc6f83999)

Proposed technique of RGB to Gray conversion

![Screenshot from 2025-07-05 12-19-43](https://github.com/user-attachments/assets/654f253b-8fe4-4918-af2e-1814cb9ee04f)

It can be observed
that there is a reduction of 94% and 85.71% in LUT and Flip Flop requirements, respectively, for the proposed architecture.Hence we are using it in our SoC







~The idea was taken from Efficient Hardware of RGB to Gray Conversion Realized on FPGA and ASIC
(Kaushal Kumar ,Ritesh Kumar Mishra ,Durgesh Nandan )
