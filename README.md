# Fast flow prediction along airfoils operating at transonic conditions using Machine Learning

## Abstract
This Thesis's main focus is how we can couple Fluid Dynamics with Artificial Intelligence. This work is not an original idea as many other scientists
have already explored this field, yet it is fascinating to further research and experiment as it shows immense potential. Based on the work of Hui
et al., a system of Convolutional Neural Networks will be created where each Network would be responsible for predicting the Coefficient of
Pressure distribution for an airfoil's  two sides (top and bottom sides). The airfoil of choice is the RAE-2822, operating under subsonic
conditions close to the Critical Mach number. This way we can also study whether the Neural Network can predict the formation of sonic waves,
phenomena    with great mathematical and physical interest because of their extremely non-linear behavior.

Also, an interesting concept used by
Hui et al. is utilizing the Signed     Distance Function to colorize the input image's pixels. Signed Distance Function enables us to describe
more complex geometry with less image resolution. It achieves that by     colorizing each pixel according to the distance information between the
pixel's center and its nearest geometry point. That leads to packing more information into fewer pixels     by utilizing almost the entirety of
available pixels. To train and test the Neural Networks, the RAE-2822 is randomly uniformly deformed for deformation percentages     $\in [-20,20]\
\%$, with 1000 specimens being used for training and 500 for testing. Each variant's Cp distribution was calculated using the CFD solver MaPFlow.
Then the Cp distribution's values were extracted at specific length intervals for each side, thus creating a file storing these values for each
side. This process, along with the creation of the SDF formatted images, constitute the data generation process. Then this data were used to train
the Neural Network. After training the Networks, we study their accuracy in predicting the Cp distribution of previously unknown specimens and
repeat the process for 4000 Epochs. Finally, the Networks' error convergence per Epoch history would be studied both for the training and the
testing sets. Also, the time per Epoch data as long as the single case prediction time data would be studied to validate the Networks' prediction
speed.

Following the verification of the Neural Networks' accuracy, we will study the influence of the minibatch size in the training-testing precision
and speed. Also, we will examine the Networks' precision in predicting Cp Distribution for airfoils out of the original training and testing
range. Finally, a short and simplistic application of the trained Networks' will be presented; a simple geometry optimizer, whose purpose is to
maximize the Lift capacity by optimizing the original RAE-2822 geometry for specific Free-flow conditions.


### Time History of the Neural Networks' accuracy per epoch
https://user-images.githubusercontent.com/62998716/145610775-4e6adba5-be30-4120-bb6d-cf0eed26301f.mp4



