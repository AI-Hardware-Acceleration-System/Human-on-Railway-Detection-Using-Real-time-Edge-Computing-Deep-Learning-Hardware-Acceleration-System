**#Finite State Machine**<br/>
>在整體系統的最上層我們設計了Finite State Machine，其State Diagram如下圖。<br/>
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;起始狀態會在 “Reset”，等待圖片欲處理，直到開始傳送圖片至BRAM時 ，即PS_BRAM_ Busy 為1，會變換至Idle的狀態，然後等到圖片傳完，即PS_BRAM_ Busy 為0，則可開始進行卷積運算。接著每個Layer結束時會輸出一個done訊號以表示此Layer的結束，當FSM收到這個訊號後會再切換到下一個Layer。<br/>
<img src="https://github.com/AI-Hardware-Acceleration-System/Human-on-Railway-Detection-Using-Real-time-Edge-Computing-Deep-Learning-Hardware-Acceleration-System/blob/main/CNN_Software/image/Finite_Sate_Machine.png" width="60%"><br/>
