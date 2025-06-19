**#Pooling**<br/>
>池化層可以降低特徵圖的空間維度，同時保留重要的資訊。<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在平均池化的硬體設計中，上列的資料要等到下列資料進來時才可運算，這也因此需要很多暫存器。而本專題的設計理念為平均池化採兩列一組處理的運行方式，上列每進來兩個值便會將其加起來並存到暫存器內，到下列時同樣每兩個值便會將結果加起來，但同時也會加上上列對應的加起來的值以及乘上0.25即得到一個輸出結果，示意圖如下。<br/>
<img src="https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/Pooling_3.png" width="60%"><br/>

>池化層電路圖如下:<br/>
<img src="https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/Pooling_4.png" width="100%"><br/>
>考慮到整體系統的運作時間和硬體使用資源，我們設計讓4個單通道平均池化處理核心同時運作，如下圖所示。<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/Pooling_1.png)<br/>


<br/>

**詳細hierachy如下:**<br/>
![image](https://github.com/user-attachments/assets/7a3b392a-8bb9-4f13-9c45-09d8954a9ddc)

