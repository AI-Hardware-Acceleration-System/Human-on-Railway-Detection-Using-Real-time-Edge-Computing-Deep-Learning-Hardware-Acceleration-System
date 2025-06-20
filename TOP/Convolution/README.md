**Convolution**<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在Convolution的部分，我們使用了Systolic Array為運算核心， Systolic Array能以高效能、低延遲的方式，對多列輸入資料並行運算，同時減少資料暫存空間。其運行方式如下圖一所示，最右方的白色格子由乘法器、加法器組成，會將權重與輸入的乘積由上往下進行累加，而左邊一欄一欄分別為輸入列在不同時脈進入的順序(由右到左)，其在輸入層上的位置如下圖一最左方所示(同一時脈輸入以同一顏色表示)。輸入列進入乘加器的順序如下圖二所示，在第一次出現有效輸出時將其全部相加，即可得輸出層的結果。<br/>
>圖一:<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/Systolic_Array_1.png)<br/>
>圖二:<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/Systolic_Array_2.png)<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;考量到整體系統的運作時間和硬體資源，我們設計多個Systolic Array運算核心並行處理。在下圖的右方，Conv_Compute中會看到4個Systolic Array，這4個Systolic Array會同時做計算，計算結束後，將4個結果相加，存進BRAM裡。整體Convolution的運作如下圖所示:<br/>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/Convolution.png)<br/>

<br/>

**#詳細hierachy如下:**</br>
>![image](https://github.com/user-attachments/assets/3254fa52-832c-4b59-a9ce-a16030327cae)<br/>
>![image](https://github.com/user-attachments/assets/b9ee1b72-a6cd-4b96-af6f-3f057248a289)<br/>

