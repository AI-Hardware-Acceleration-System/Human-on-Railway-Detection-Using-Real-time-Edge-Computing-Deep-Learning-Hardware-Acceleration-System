**BRAM_Control**</br>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;本系統之記憶體總共分為以下幾個區塊，如圖十八，分別為Input Image、Model Parameters以及Feature Maps。其中Input Image負責接收由PS端經由AXI協議傳送進來的輸入圖像，Model Parameters中預存了人像偵測CNN模型之模型參數，包括Weight跟Bias等。Feature Maps則是用以儲存模型運算中間產物，即各特徵圖，此區塊特別需與模型計算模組進行緊密的配合，以完成模型的計算。
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;而為了實現邊緣運算的輕量化硬體設計，我們採用了ping-pong buffering概念以完成重複使用硬體的設計，設計理念為以兩組BRAM作為基底，一組為輸入特徵圖，一組接收各層輸出資料，下一層時兩組角色互換，前者變為輸出，後者變為輸入，依此類推。
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;對於各區塊的記憶體，本系統以一個BRAM Control模組進行控制，上述概念可參考以下兩圖。
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/BRAM_Control_1.png) </br>
![image](https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/BRAM_Control_2.png) </br>

</br>

**詳細hierachy如下:**</br>
![image](https://github.com/user-attachments/assets/43146cf6-c350-4291-a83a-746c438ecbdc) </br>
&nbsp;&nbsp;&nbsp;&nbsp;![image](https://github.com/user-attachments/assets/90e6372d-74c3-4d0e-b228-4a3c3e5910a8) </br>

