**#人像辨識CNN模型**<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;本專題所使用的開發板為 PYNQ-Z2。鑒於有限的硬體資源，我們在軟體端選擇設計兩個輕量化的分類模型，最終比較了兩個版本的硬體使用資源和模型準確率，決定使用3x3的convolution版本為我們的CNN模型。<br/>
>以下為3x3的convolution的架構圖<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/3x3_Convolution.png)<br/>
>以下為5x5的convolution的架構圖<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/5x5_Convolution.png)<br/>
